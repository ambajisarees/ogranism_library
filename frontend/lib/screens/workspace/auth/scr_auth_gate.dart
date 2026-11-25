/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Top-level authentication & approval gate router located under
     `lib/screens/admin/auth/scr_auth_gate.dart`.
   - Listens to Supabase auth state and `AuthService().activeProfileNotifier`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Unauthenticated / Signed Out -> [ScrAdminAuthLogin].
   - Authenticated & `approvalStatus == 'PENDING'` (or `isApproved == false`)
     -> Minimal Centered Holding Card over [TextileWeaveBackground] until
     Admin approves the onboarding request.
   - Authenticated & Approved -> [HomeScreen] wrapped in 60-minute
     [InactivityWrapper], where [HomeScreen] switches between Desktop (`>= 768px`)
     and Mobile Root Shell (`< 768px` or `mobileFloorModeNotifier == true`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Fetches profile automatically when auth session user changes without
     calling setState synchronously during build.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None currently.
================================================================================
*/

library;

import 'dart:async';
import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../dynamic_ai/micro/dy_dhaaga_logo.dart';
import '../../../models/workspace/mdl_auth.dart';
import '../../../services/workspace/srv_auth.dart';
import '../../../services/workspace/srv_inactivity_tracker.dart';
import '../../../services/core/service_supabase.dart';
import '../../home.dart';
import 'scr_admin_auth_login.dart';
import 'widgets/textile_weave_background.dart';

class ScrAuthGate extends StatefulWidget {
  const ScrAuthGate({super.key});

  @override
  State<ScrAuthGate> createState() => _ScrAuthGateState();
}

class _ScrAuthGateState extends State<ScrAuthGate> {
  late final Stream<AuthState> _authStateStream;
  late final StreamSubscription<AuthState> _authSub;
  bool _isProfileLoading = false;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _authStateStream = SupabaseService().client.auth.onAuthStateChange;
    _authSub = _authStateStream.listen((state) {
      if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.tokenRefreshed ||
          state.event == AuthChangeEvent.initialSession) {
        final activeProfile = AuthService().activeProfileNotifier.value;
        final user = state.session?.user;
        if (user != null &&
            (activeProfile == null || activeProfile.id != user.id)) {
          _loadProfile();
        }
      }
    });
    _loadProfile();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!AuthService().isAuthenticated) return;
    if (mounted) {
      setState(() => _isProfileLoading = true);
    }
    await AuthService().fetchUserProfile();
    if (!mounted) return;
    setState(() => _isProfileLoading = false);
  }

  Future<void> _refreshApprovalStatus() async {
    setState(() => _isCheckingStatus = true);
    final profile = await AuthService().fetchUserProfile();
    if (!mounted) return;
    setState(() => _isCheckingStatus = false);

    if (profile != null && profile.isApproved) {
      shad.showToast(
        context: context,
        builder: (ctx, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Account approved! Entering workspace...'),
          ),
        ),
      );
    } else {
      shad.showToast(
        context: context,
        builder: (ctx, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Still awaiting Admin approval.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        final session = SupabaseService().client.auth.currentSession;
        final user = SupabaseService().client.auth.currentUser;

        // 1. Unauthenticated / signed out
        if (session == null || user == null) {
          return const ScrAdminAuthLogin();
        }

        // 2. React to profile changes (e.g. approval check, sign-out)
        return ValueListenableBuilder<AppProfileModel?>(
          valueListenable: AuthService().activeProfileNotifier,
          builder: (context, profile, child) {
            if (_isProfileLoading && profile == null) {
              return _buildLoadingView(context);
            }

            // 3. Pending Admin Approval / Rejected Holding Screen
            if (profile != null && !profile.isApproved) {
              return _buildPendingApprovalScreen(context, profile);
            }

            // 4. Approved & Active -> Unified Responsive HomeScreen (Desktop & Mobile)
            return InactivityWrapper(
              onTimeout: () {
                if (mounted) {
                  shad.showToast(
                    context: context,
                    builder: (context, show) => const shad.Card(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Session expired due to 1 hour of inactivity. Please sign in again.',
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const HomeScreen(),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.background,
      body: TextileWeaveBackground(
        child: Center(
          child: shad.OutlinedContainer(
            backgroundColor: colors.card.withValues(alpha: 0.94),
            borderColor: colors.border,
            borderRadius: theme.borderRadiusLg,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: shad.CircularProgressIndicator(),
                ),
                const shad.DensityGap(shad.gapMd),
                Text(
                  'Verifying User ID...',
                  style: theme.typography.textSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingApprovalScreen(
    BuildContext context,
    AppProfileModel profile,
  ) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final double scale = theme.scaling;
    final double pad = theme.density.baseContainerPadding * scale;
    final bool isRejected = profile.isRejected;

    return Scaffold(
      backgroundColor: colors.background,
      body: TextileWeaveBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * scale),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 440 * scale),
                child: shad.OutlinedContainer(
                  backgroundColor: colors.card.withValues(alpha: 0.95),
                  borderColor: colors.border,
                  borderRadius: theme.borderRadiusXl,
                  padding: EdgeInsets.all(pad * 1.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          DyDhaagaLogo(animated: true),
                          shad.DensityGap(shad.gapSm),
                          DyDhaagaWordmark(fontSize: 18.0),
                        ],
                      ),
                      const shad.DensityGap(shad.gapXl),
                      Row(
                        children: [
                          isRejected
                              ? const shad.DestructiveBadge(
                                  child: Text('REQUEST DECLINED'),
                                )
                              : const shad.PrimaryBadge(
                                  child: Text('PENDING ADMIN APPROVAL'),
                                ),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Text(
                        isRejected
                            ? 'Access Not Approved'
                            : 'Waiting for Admin Approval',
                        style: theme.typography.h3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.foreground,
                        ),
                      ),
                      const shad.DensityGap(shad.gapXs),
                      Text(
                        isRejected
                            ? 'Your access request for User ID ${profile.username} was declined. Please contact Subham Mittal.'
                            : 'User ID "${profile.username}" (${profile.fullName}) has been submitted to Admin for activation.',
                        style: theme.typography.textSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                      if (profile.mobileNo.isNotEmpty) ...[
                        const shad.DensityGap(shad.gapMd),
                        shad.OutlinedContainer(
                          backgroundColor: colors.muted.withValues(alpha: 0.45),
                          borderColor: colors.border,
                          borderRadius: theme.borderRadiusMd,
                          padding: EdgeInsets.all(10 * scale),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'User ID: ${profile.username}',
                                style: theme.typography.xSmall.copyWith(
                                  fontFamily: 'JetBrains Mono',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                profile.mobileNo,
                                style: theme.typography.xSmall.copyWith(
                                  fontFamily: 'JetBrains Mono',
                                  color: colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const shad.DensityGap(shad.gapXl),
                      Row(
                        children: [
                          Expanded(
                            child: shad.OutlineButton(
                              onPressed: () => AuthService().signOut(),
                              child: const Text('Sign Out'),
                            ),
                          ),
                          if (!isRejected) ...[
                            const shad.DensityGap(shad.gapSm),
                            Expanded(
                              child: shad.PrimaryButton(
                                onPressed: _isCheckingStatus
                                    ? null
                                    : _refreshApprovalStatus,
                                child: Text(
                                  _isCheckingStatus
                                      ? 'Checking...'
                                      : 'Check Status',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
