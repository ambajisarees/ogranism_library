/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized authentication, User ID resolution, self-registration, and
     Admin Approval Queue service (`IMMBE2627.sb_APP_PROFILES` &
     `IMMBE2627.sb_onboarding_requests`).
   - Manages sign-in with User ID + Password, new profile creation (Full Name,
     Mobile No, Optional Email, Password), pending-approval gating, and
     one-click Admin Approve/Reject workflows (Internal Staff now, Vendors later).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target schema: `IMMBE2627`.
   - `signInWithUserId(...)` resolves `username` / `mobile_no` -> `auth_email`
     via `IMMBE2627.fn_resolve_login_identity` before invoking Supabase
     `signInWithPassword`.
   - `registerWithUserId(...)` creates the `auth.users` identity using a
     deterministic synthetic internal email (`<userid>@internal.ambajisarees.erp`),
     auto-confirms it via `IMMBE2627.fn_complete_user_registration`, and flags
     the profile as `approval_status = 'PENDING'` / `is_active = false`.
   - Only users with `isApproved == true` enter the workspace; pending users see
     a holding card until an Admin approves via `reviewOnboardingRequest(...)`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_APP_PROFILES` previously omitted `app_type` & `approval_status`; added
     in migration `upgrade_auth_userid_and_onboarding_queue`.
   - `SUBHAM` -> `sub.ambaji@gmail.com` and `JATIN` -> `jatin.mitfam@gmail.com`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Vendor self-onboarding will call `registerWithUserId(..., requestType: 'VENDOR')`.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workspace/mdl_auth.dart';
import '../core/service_supabase.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = SupabaseService().client;
  final SharedPreferencesLocalStorage _lastUserStorage =
      SharedPreferencesLocalStorage(
    persistSessionKey: 'ambaji_last_login_user_id',
  );
  bool _storageInitialized = false;

  /// Last User ID used on this device (defaults to `SUBHAM` until overwritten).
  String lastLoginUserId = 'SUBHAM';

  final ValueNotifier<AppProfileModel?> activeProfileNotifier =
      ValueNotifier<AppProfileModel?>(null);

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<int> pendingApprovalsCountNotifier =
      ValueNotifier<int>(0);

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Loads the most recently used User ID stored on this device.
  Future<String> loadLastLoginUserId() async {
    try {
      if (!_storageInitialized) {
        await _lastUserStorage.initialize();
        _storageInitialized = true;
      }
      final saved = (await _lastUserStorage.accessToken())?.trim() ?? '';
      if (saved.isNotEmpty) {
        lastLoginUserId = saved.toUpperCase();
      }
    } catch (e) {
      debugPrint('[AuthService] Could not read last User ID: $e');
    }
    return lastLoginUserId;
  }

  Future<void> _persistLastLoginUserId(String userId) async {
    final clean = userId.trim().toUpperCase();
    if (clean.isEmpty) return;
    lastLoginUserId = clean;
    try {
      if (!_storageInitialized) {
        await _lastUserStorage.initialize();
        _storageInitialized = true;
      }
      await _lastUserStorage.persistSession(clean);
    } catch (e) {
      debugPrint('[AuthService] Could not persist last User ID: $e');
    }
  }

  /// Fetch active user profile from `IMMBE2627.sb_APP_PROFILES` + `sb_USER_ROLES`.
  Future<AppProfileModel?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) {
      activeProfileNotifier.value = null;
      pendingApprovalsCountNotifier.value = 0;
      return null;
    }

    try {
      isLoadingNotifier.value = true;
      final response = await _client
          .schema('IMMBE2627')
          .from('sb_APP_PROFILES')
          .select('*, sb_USER_ROLES(name, description)')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        String? roleName;
        if (response['sb_USER_ROLES'] != null &&
            response['sb_USER_ROLES'] is Map) {
          roleName = response['sb_USER_ROLES']['name'] as String?;
        }

        final profile = AppProfileModel.fromJson(
          response,
          roleNameOverride: roleName,
        );

        activeProfileNotifier.value = profile;
        if (profile.username.isNotEmpty) {
          await _persistLastLoginUserId(profile.username);
        }
        if (profile.isAdmin && profile.isApproved) {
          await refreshPendingApprovalsCount();
        }
        return profile;
      } else {
        final fallbackProfile = AppProfileModel(
          id: user.id,
          fullName: user.userMetadata?['full_name'] as String? ??
              user.email ??
              'ERP User',
          username: (user.userMetadata?['username'] as String? ??
                  user.email?.split('@').first ??
                  'USER')
              .toUpperCase(),
          mobileNo: user.userMetadata?['mobile_no'] as String? ?? '',
          email: user.email,
          authEmail: user.email,
          roleId: 3,
          roleName: 'STAFF',
          permissions: const {},
          isActive: false,
          approvalStatus: 'PENDING',
          appType: 'INTERNAL',
        );

        activeProfileNotifier.value = fallbackProfile;
        return fallbackProfile;
      }
    } catch (e) {
      debugPrint('[AuthService] Error fetching user profile: $e');
      final emergencyProfile = AppProfileModel(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String? ??
            user.email ??
            'ERP User',
        username: (user.userMetadata?['username'] as String? ??
                user.email?.split('@').first ??
                'USER')
            .toUpperCase(),
        roleId: 3,
        roleName: 'STAFF',
        permissions: const {},
        isActive: false,
        approvalStatus: 'PENDING',
        appType: 'INTERNAL',
      );
      activeProfileNotifier.value = emergencyProfile;
      return emergencyProfile;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Resolve a User ID (or mobile no) via Postgres RPC and sign in with Password.
  Future<AuthResponse> signInWithUserId({
    required String userId,
    required String password,
  }) async {
    final cleanId = userId.trim();
    if (cleanId.isEmpty) {
      throw Exception('Please enter your User ID.');
    }
    if (password.trim().isEmpty) {
      throw Exception('Please enter your password.');
    }

    try {
      isLoadingNotifier.value = true;
      final dynamic rpcRes = await _client
          .schema('IMMBE2627')
          .rpc('fn_resolve_login_identity', params: {'p_user_id': cleanId});

      final Map<String, dynamic> identity = rpcRes is Map
          ? Map<String, dynamic>.from(rpcRes)
          : <String, dynamic>{};

      if (identity['found'] != true) {
        throw Exception(
          'User ID "${cleanId.toUpperCase()}" was not found. Check your ID or create a new User ID.',
        );
      }

      final String? authEmail =
          (identity['auth_email'] as String?)?.trim().toLowerCase();
      if (authEmail == null || authEmail.isEmpty) {
        throw Exception('Account auth mapping is incomplete. Contact Admin.');
      }

      final res = await _client.auth.signInWithPassword(
        email: authEmail,
        password: password.trim(),
      );

      if (res.user != null) {
        final String? resolvedUsername =
            (identity['username'] as String?)?.trim();
        await _persistLastLoginUserId(
          (resolvedUsername != null && resolvedUsername.isNotEmpty)
              ? resolvedUsername
              : cleanId,
        );
        await fetchUserProfile();
      }
      return res;
    } on AuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Legacy email login preserved for backwards compatibility.
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      signInWithUserId(userId: email, password: password);

  /// Create a new User ID profile (Full Name, Mobile No, Optional Email, Password)
  /// and enqueue an Admin Approval request in `IMMBE2627.sb_onboarding_requests`.
  Future<void> registerWithUserId({
    required String userId,
    required String fullName,
    required String mobileNo,
    String? email,
    required String password,
    String requestType = 'INTERNAL_USER',
  }) async {
    final String normalizedUsername = userId.trim().toUpperCase();
    final String safeEmailLocal = userId
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    final String cleanMobile = mobileNo.trim();
    final String cleanFullName = fullName.trim();
    final String? cleanOptionalEmail =
        (email != null && email.trim().isNotEmpty) ? email.trim() : null;

    if (safeEmailLocal.length < 3) {
      throw Exception(
        'User ID must have at least 3 letters or numbers (e.g. RAMESH01).',
      );
    }

    try {
      isLoadingNotifier.value = true;

      // 1. Check User ID availability
      final dynamic existingUserRpc = await _client
          .schema('IMMBE2627')
          .rpc('fn_resolve_login_identity', params: {
        'p_user_id': normalizedUsername,
      });
      if (existingUserRpc is Map && existingUserRpc['found'] == true) {
        throw Exception(
          'User ID "$normalizedUsername" is already registered. Try signing in instead.',
        );
      }

      // 2. Check Mobile No uniqueness
      final dynamic existingMobileRpc = await _client
          .schema('IMMBE2627')
          .rpc('fn_resolve_login_identity', params: {
        'p_user_id': cleanMobile,
      });
      if (existingMobileRpc is Map && existingMobileRpc['found'] == true) {
        throw Exception(
          'Mobile number "$cleanMobile" is already linked to User ID "${existingMobileRpc['username']}".',
        );
      }

      // 3. Create auth user using deterministic internal auth email
      final String syntheticAuthEmail =
          '$safeEmailLocal@internal.ambajisarees.erp';

      final AuthResponse signUpRes = await _client.auth.signUp(
        email: syntheticAuthEmail,
        password: password.trim(),
        data: {
          'username': normalizedUsername,
          'full_name': cleanFullName,
          'mobile_no': cleanMobile,
        },
      );

      final User? createdUser = signUpRes.user;
      if (createdUser == null) {
        throw Exception('Unable to create user credentials. Please retry.');
      }

      // 4. Auto-confirm auth user, create PENDING profile, and notify Admin queue
      await _client
          .schema('IMMBE2627')
          .rpc('fn_complete_user_registration', params: {
        'p_user_id': createdUser.id,
        'p_username': normalizedUsername,
        'p_full_name': cleanFullName,
        'p_mobile_no': cleanMobile,
        'p_email': cleanOptionalEmail,
        'p_auth_email': syntheticAuthEmail,
        'p_request_type': requestType,
      });

      // 5. Ensure active session exists so ScrAuthGate shows the live Pending Approval screen
      if (signUpRes.session == null) {
        await _client.auth.signInWithPassword(
          email: syntheticAuthEmail,
          password: password.trim(),
        );
      }

      await _persistLastLoginUserId(normalizedUsername);
      await fetchUserProfile();
    } on AuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Fetch count of pending onboarding requests for Admin Notification Bell badge.
  Future<int> refreshPendingApprovalsCount() async {
    try {
      final rows = await _client
          .schema('IMMBE2627')
          .from('sb_onboarding_requests')
          .select('id')
          .eq('status', 'PENDING');
      final int count = (rows as List<dynamic>?)?.length ?? 0;
      pendingApprovalsCountNotifier.value = count;
      return count;
    } catch (e) {
      debugPrint('[AuthService] Error counting pending approvals: $e');
      return pendingApprovalsCountNotifier.value;
    }
  }

  /// Fetch all onboarding requests (`PENDING` first, then recent history).
  Future<List<OnboardingRequestModel>> fetchOnboardingRequests() async {
    try {
      final response = await _client
          .schema('IMMBE2627')
          .from('sb_onboarding_requests')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);

      final list = response as List<dynamic>? ?? [];
      final requests = list
          .map((e) => OnboardingRequestModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();

      pendingApprovalsCountNotifier.value =
          requests.where((r) => r.isPending).length;
      return requests;
    } catch (e) {
      debugPrint('[AuthService] Error fetching onboarding requests: $e');
      return [];
    }
  }

  /// Admin approves or rejects an onboarding request and updates profile status.
  Future<bool> reviewOnboardingRequest({
    required String requestId,
    required String decision,
    int roleId = 3,
    String? note,
  }) async {
    try {
      await _client
          .schema('IMMBE2627')
          .rpc('fn_review_onboarding_request', params: {
        'p_request_id': requestId,
        'p_decision': decision.toUpperCase(),
        'p_role_id': roleId,
        'p_reviewer_id': currentUser?.id,
        'p_note': note,
      });
      await refreshPendingApprovalsCount();
      return true;
    } catch (e) {
      debugPrint('[AuthService] Error reviewing onboarding request: $e');
      return false;
    }
  }

  /// Cleanly sign out current user and clear local session state.
  Future<void> signOut() async {
    try {
      isLoadingNotifier.value = true;
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign out error: $e');
    } finally {
      activeProfileNotifier.value = null;
      pendingApprovalsCountNotifier.value = 0;
      isLoadingNotifier.value = false;
    }
  }

  String _friendlyAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Incorrect User ID or Password. Please try again.';
    }
    if (msg.contains('user already registered')) {
      return 'This User ID is already registered. Sign in with your password.';
    }
    if (msg.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }
    return e.message;
  }
}
