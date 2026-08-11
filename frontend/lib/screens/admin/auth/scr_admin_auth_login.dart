/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Admin Auth Login Screen for Internal Team App under lib/screens/admin/auth/scr_admin_auth_login.dart.
   - Provides ultra-premium dual-pane desktop interface for Email/Password and Google OAuth SSO authentication.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Authenticates via AuthService().signInWithEmailAndPassword() or signInWithGoogle().
   - Handles login feedback, validation errors, and password visibility toggle.
   - Pre-fills email options for convenience (e.g. sub.ambaji@gmail.com, jatin.mitfam@gmail.com).

3. UI & SHADCN FLUTTER COMPLIANCE:
   - Strict native token usage: shad.Theme.of(context).colorScheme, theme.typography, shad.DensityGap.
   - Dual-pane layout on desktop/tablet, single scrollable column on narrow viewports.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Deep link redirection for desktop Google SSO handled via custom URL scheme.
================================================================================
*/

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../main.dart';
import '../../../services/auth/srv_auth.dart';

class ScrAdminAuthLogin extends StatefulWidget {
  const ScrAdminAuthLogin({super.key});

  @override
  State<ScrAdminAuthLogin> createState() => _ScrAdminAuthLoginState();
}

class _ScrAdminAuthLoginState extends State<ScrAdminAuthLogin> {
  final TextEditingController _emailController = TextEditingController(text: 'sub.ambaji@gmail.com');
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberEmail = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your account password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await AuthService().signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (res.user != null) {
        shad.showToast(
          context: context,
          builder: (context, show) => const shad.Card(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Login successful! Loading workspace...'),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSSO() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signInWithGoogle();
      if (!mounted) return;
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Opening Google SSO in browser...'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Google SSO failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Row(
            children: [
              // Left Pane: Ambient Brand & Telemetry Showcase
              if (isWide)
                Expanded(
                  flex: 5,
                  child: Container(
                    color: colors.muted,
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Header
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  shad.LucideIcons.shirt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const shad.DensityGap(shad.gapLg),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AMBAJI SAREES',
                                  style: theme.typography.h2.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.foreground,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Enterprise Resource Planning • FY 26-27',
                                  style: theme.typography.textMuted.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Hero Text
                        Text(
                          'Integrated Textile Production & ERP Workspace',
                          style: theme.typography.h1.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            color: colors.foreground,
                          ),
                        ),
                        const shad.DensityGap(shad.gapLg),
                        Text(
                          'Streamlining Mill Programs, Inward Receipts, Cutting Cards, Stitching Job Work, and Multi-Channel Sales with real-time Supabase telemetry.',
                          style: theme.typography.p.copyWith(
                            color: colors.mutedForeground,
                            fontSize: 15,
                          ),
                        ),
                        const shad.DensityGap(shad.gapXl),
                        // Feature Pills
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildFeatureChip(
                              context,
                              theme,
                              colors,
                              shad.LucideIcons.shieldCheck,
                              'Role-Based RBAC Security',
                            ),
                            _buildFeatureChip(
                              context,
                              theme,
                              colors,
                              shad.LucideIcons.scissors,
                              '3-Tier Cutting Engine',
                            ),
                            _buildFeatureChip(
                              context,
                              theme,
                              colors,
                              shad.LucideIcons.database,
                              'Supabase FY 26-27 Sync',
                            ),
                            _buildFeatureChip(
                              context,
                              theme,
                              colors,
                              shad.LucideIcons.timer,
                              '60m Inactivity Protection',
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Footer Copyright
                        Text(
                          '© 2026 Ambaji Sarees. All rights reserved.',
                          style: theme.typography.xSmall.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Right Pane: Login Form Container
              Expanded(
                flex: 4,
                child: Container(
                  color: colors.background,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Row: Theme Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const shad.PrimaryBadge(
                                  child: Text('Internal App v2.0'),
                                ),
                                ValueListenableBuilder<shad.ThemeMode>(
                                  valueListenable: themeModeNotifier,
                                  builder: (context, mode, child) {
                                    final isDark = mode == shad.ThemeMode.dark;
                                    return shad.IconButton.ghost(
                                      icon: Icon(
                                        isDark ? shad.LucideIcons.moon : shad.LucideIcons.sun,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        themeModeNotifier.value = isDark
                                            ? shad.ThemeMode.light
                                            : shad.ThemeMode.dark;
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const shad.DensityGap(shad.gapXl),

                            // Heading
                            Text(
                              'Sign In to ERP',
                              style: theme.typography.h2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.foreground,
                              ),
                            ),
                            const shad.DensityGap(shad.gapSm),
                            Text(
                              'Enter your credentials or use Google SSO to access the internal workspace.',
                              style: theme.typography.textMuted.copyWith(fontSize: 13),
                            ),
                            const shad.DensityGap(shad.gapXl),

                            // Error Alert
                            if (_errorMessage != null) ...[
                              shad.Alert.destructive(
                                title: const Text('Authentication Error'),
                                content: Text(_errorMessage!),
                              ),
                              const shad.DensityGap(shad.gapLg),
                            ],

                            // Quick Select Accounts (User Hint)
                            Text(
                              'Active Accounts:',
                              style: theme.typography.xSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.mutedForeground,
                              ),
                            ),
                            const shad.DensityGap(shad.gapSm),
                            Row(
                              children: [
                                Expanded(
                                  child: shad.OutlineButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () {
                                      setState(() {
                                        _emailController.text = 'sub.ambaji@gmail.com';
                                      });
                                    },
                                    child: const Text('sub.ambaji'),
                                  ),
                                ),
                                const shad.DensityGap(shad.gapSm),
                                Expanded(
                                  child: shad.OutlineButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () {
                                      setState(() {
                                        _emailController.text = 'jatin.mitfam@gmail.com';
                                      });
                                    },
                                    child: const Text('jatin.mitfam'),
                                  ),
                                ),
                              ],
                            ),
                            const shad.DensityGap(shad.gapLg),

                            // Email Field
                            Text(
                              'Email Address',
                              style: theme.typography.textSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const shad.DensityGap(shad.gapSm),
                            shad.TextField(
                              controller: _emailController,
                              placeholder: const Text('name@ambajisarees.com'),
                              features: [
                                shad.InputFeature.leading(
                                  Icon(
                                    shad.LucideIcons.mail,
                                    size: 16,
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                            const shad.DensityGap(shad.gapLg),

                            // Password Field
                            Text(
                              'Password',
                              style: theme.typography.textSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const shad.DensityGap(shad.gapSm),
                            shad.TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              placeholder: const Text('••••••••••••'),
                              features: [
                                shad.InputFeature.leading(
                                  Icon(
                                    shad.LucideIcons.lock,
                                    size: 16,
                                    color: colors.mutedForeground,
                                  ),
                                ),
                                shad.InputFeature.trailing(
                                  shad.IconButton.ghost(
                                    icon: Icon(
                                      _obscurePassword
                                          ? shad.LucideIcons.eye
                                          : shad.LucideIcons.eyeOff,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const shad.DensityGap(shad.gapLg),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    shad.Checkbox(
                                      state: _rememberEmail
                                          ? shad.CheckboxState.checked
                                          : shad.CheckboxState.unchecked,
                                      onChanged: (shad.CheckboxState state) {
                                        setState(() => _rememberEmail = state == shad.CheckboxState.checked);
                                      },
                                    ),
                                    const shad.DensityGap(shad.gapSm),
                                    Text(
                                      'Remember email',
                                      style: theme.typography.textSmall,
                                    ),
                                  ],
                                ),
                                shad.Button.link(
                                  onPressed: () {
                                    shad.showToast(
                                      context: context,
                                      builder: (context, show) => const shad.Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Password reset link will be sent to your registered email address.',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Forgot password?'),
                                ),
                              ],
                            ),
                            const shad.DensityGap(shad.gapXl),

                            // Sign In Button
                            shad.PrimaryButton(
                              onPressed: _isLoading ? null : _handleEmailLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Sign In to Workspace'),
                            ),
                            const shad.DensityGap(shad.gapLg),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: shad.Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    'OR',
                                    style: theme.typography.xSmall.copyWith(
                                      color: colors.mutedForeground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Expanded(child: shad.Divider()),
                              ],
                            ),
                            const shad.DensityGap(shad.gapLg),

                            // Google SSO Button
                            shad.OutlineButton(
                              onPressed: _isLoading ? null : _handleGoogleSSO,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    shad.LucideIcons.globe,
                                    size: 18,
                                  ),
                                  const shad.DensityGap(shad.gapMd),
                                  const Text('Sign In with Google SSO'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureChip(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const shad.DensityGap(shad.gapSm),
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
