import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import '../../organism_design/index.dart';
import '../../services/service_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSigningUp = false;
  bool _emailExists = true;
  Timer? _debounce;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailExists = true;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final exists = await AuthService().checkEmailExists(email);
      if (mounted) {
        setState(() {
          _emailExists = exists;
        });
      }
    });
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email/username and password.';
      });
      return;
    }

    setState(() {
      _isSigningUp = true;
      _errorMessage = null;
    });

    try {
      final res = await AuthService().signUp(email, password);
      if (res.user == null) {
        throw Exception('Signup failed.');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Verification email has been sent.'),
            backgroundColor: OrganismTheme.colorsOf(context).success,
          ),
        );
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email/username and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signIn(email, password);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(OrganismTheme.spacing2Xl),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: OrganismTheme.borderLg,
              border: Border.all(color: colors.border),
              boxShadow: OrganismTheme.shadowsOf(context, elevation: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: colors.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.shieldCheck,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacingLg),
                Text(
                  'Ambaji Sarees ERP',
                  textAlign: TextAlign.center,
                  style: OrganismTheme.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacingXs),
                Text(
                  'Sign in to access your dashboard',
                  textAlign: TextAlign.center,
                  style: OrganismTheme.bodyMedium(context).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacing2Xl),

                // Error Message Panel
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: colors.errorSubtle,
                      border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                      borderRadius: OrganismTheme.borderSm,
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle, color: colors.error, size: 16),
                        const SizedBox(width: OrganismTheme.spacingSm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: OrganismTheme.bodySmall(context).copyWith(
                              color: colors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: OrganismTheme.spacingLg),
                ],

                // Form Fields
                Text(
                  'Email or Username',
                  style: OrganismTheme.labelMedium(context).copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacingXs),
                CellInput(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  placeholder: 'name@ambajisarees.com',
                  prefixIcon: LucideIcons.mail,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: OrganismTheme.spacingLg),

                Text(
                  'Password',
                  style: OrganismTheme.labelMedium(context).copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacingXs),
                CellInput(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  placeholder: '••••••••',
                  prefixIcon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  onSuffixPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: OrganismTheme.spacing2Xl),

                // Submit Buttons
                Row(
                  children: [
                    Expanded(
                      child: CellButton(
                        text: 'Sign In',
                        isLoading: _isLoading,
                        icon: LucideIcons.logIn,
                        variant: CellButtonVariant.primary,
                        onPressed: _isLoading || _isSigningUp ? null : _handleLogin,
                      ),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: CellButton(
                        text: 'Sign Up',
                        isLoading: _isSigningUp,
                        icon: LucideIcons.userPlus,
                        variant: CellButtonVariant.outline,
                        onPressed: (_isLoading || _isSigningUp || _emailExists) 
                            ? null 
                            : _handleSignUp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
