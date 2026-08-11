/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Top-level authentication gate router located under lib/screens/admin/auth/scr_auth_gate.dart.
   - Listens to Supabase.instance.client.auth.onAuthStateChange and dynamically routes between ScrAdminAuthLogin and HomeScreen.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Unauthenticated / Signed Out -> Renders ScrAdminAuthLogin.
   - Authenticated & Active Internal User -> Fetches profile and renders HomeScreen wrapped with InactivityWrapper.
   - Session Timeout -> Triggers auth.signOut() and returns user to ScrAdminAuthLogin cleanly.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Listens continuously to auth state changes to react instantly when user signs in or signs out from any popover or module.
================================================================================
*/

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth/srv_auth.dart';
import '../../../services/auth/srv_inactivity_tracker.dart';
import '../../../services/core/service_supabase.dart';
import '../../home.dart';
import 'scr_admin_auth_login.dart';

class ScrAuthGate extends StatefulWidget {
  const ScrAuthGate({super.key});

  @override
  State<ScrAuthGate> createState() => _ScrAuthGateState();
}

class _ScrAuthGateState extends State<ScrAuthGate> {
  late final Stream<AuthState> _authStateStream;
  bool _isProfileLoading = false;

  @override
  void initState() {
    super.initState();
    _authStateStream = SupabaseService().client.auth.onAuthStateChange;
    _checkInitialProfile();
  }

  Future<void> _checkInitialProfile() async {
    if (AuthService().isAuthenticated) {
      setState(() => _isProfileLoading = true);
      await AuthService().fetchUserProfile();
      if (mounted) {
        setState(() => _isProfileLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        final session = SupabaseService().client.auth.currentSession;
        final user = SupabaseService().client.auth.currentUser;

        // 1. Unauthenticated or signed out
        if (session == null || user == null) {
          return const ScrAdminAuthLogin();
        }

        // 2. Profile loading state
        if (_isProfileLoading) {
          final theme = shad.Theme.of(context);
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Ambaji ERP Profile...',
                    style: theme.typography.textMuted,
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Authenticated: Wrap HomeScreen in 60-Minute Inactivity Tracker
        return InactivityWrapper(
          onTimeout: () {
            if (mounted) {
              shad.showToast(
                context: context,
                builder: (context, show) => const shad.Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Session expired due to 1 hour of inactivity. Please sign in again.'),
                  ),
                ),
              );
            }
          },
          child: const HomeScreen(),
        );
      },
    );
  }
}
