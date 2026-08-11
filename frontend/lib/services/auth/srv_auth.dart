/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized authentication & user session service wrapping Supabase auth & sb_APP_PROFILES table.
   - Manages login, logout, OAuth SSO, active profile loading, and auth state listeners.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target schema: IMMBE2627.
   - Queries sb_APP_PROFILES where id = currentUserId.
   - Updates activeProfileNotifier whenever auth state or profile changes.
   - Enforces fallback profile creation if user exists in auth.users but is missing from sb_APP_PROFILES.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - sq_ and sb_ tables target IMMBE2627.
   - Google SSO on Flutter Windows desktop requires browser PKCE OAuth flow or standard Supabase OAuth launcher.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Multi-device active session tokens handled directly via Supabase Auth session refresh.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/auth/mdl_auth.dart';
import '../core/service_supabase.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = SupabaseService().client;

  final ValueNotifier<AppProfileModel?> activeProfileNotifier =
      ValueNotifier<AppProfileModel?>(null);

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Fetch user profile from sb_APP_PROFILES joined with sb_USER_ROLES
  Future<AppProfileModel?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) {
      activeProfileNotifier.value = null;
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
        if (response['sb_USER_ROLES'] != null && response['sb_USER_ROLES'] is Map) {
          roleName = response['sb_USER_ROLES']['name'] as String?;
        }

        final profile = AppProfileModel.fromJson(
          response,
          roleNameOverride: roleName,
        );

        activeProfileNotifier.value = profile;
        return profile;
      } else {
        // Fallback profile if record doesn't exist yet in sb_APP_PROFILES
        final fallbackProfile = AppProfileModel(
          id: user.id,
          fullName: user.userMetadata?['full_name'] as String? ?? user.email ?? 'ERP User',
          username: user.email?.split('@').first ?? 'USER',
          roleId: 3,
          roleName: 'STAFF',
          permissions: const {},
          isActive: true,
          appType: 'INTERNAL',
        );

        // Attempt defensive self-provisioning insert
        await _client.schema('IMMBE2627').from('sb_APP_PROFILES').upsert({
          'id': user.id,
          'full_name': fallbackProfile.fullName,
          'username': fallbackProfile.username,
          'role_id': 3,
          'app_type': 'INTERNAL',
          'is_active': true,
        });

        activeProfileNotifier.value = fallbackProfile;
        return fallbackProfile;
      }
    } catch (e) {
      debugPrint('[AuthService] Error fetching user profile: $e');
      // Create fallback profile in memory on network/permission error
      final emergencyProfile = AppProfileModel(
        id: user.id,
        fullName: user.email ?? 'ERP User',
        username: user.email?.split('@').first ?? 'USER',
        roleId: 3,
        roleName: 'STAFF',
        permissions: const {},
        isActive: true,
        appType: 'INTERNAL',
      );
      activeProfileNotifier.value = emergencyProfile;
      return emergencyProfile;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Sign In using Email & Password credentials
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoadingNotifier.value = true;
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user != null) {
        await fetchUserProfile();
      }

      return res;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Trigger Google OAuth SSO authentication flow
  Future<bool> signInWithGoogle() async {
    try {
      isLoadingNotifier.value = true;
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.ambajisarees.erp://login-callback',
      );
      return launched;
    } catch (e) {
      debugPrint('[AuthService] Google OAuth Launch Error: $e');
      rethrow;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Cleanly sign out current user and clear local session state
  Future<void> signOut() async {
    try {
      isLoadingNotifier.value = true;
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign out error: $e');
    } finally {
      activeProfileNotifier.value = null;
      isLoadingNotifier.value = false;
    }
  }
}
