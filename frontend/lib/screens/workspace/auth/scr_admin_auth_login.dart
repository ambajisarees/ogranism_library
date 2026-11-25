/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Keyboard-first centered Login & User ID Registration screen located under
     `lib/screens/workspace/auth/scr_admin_auth_login.dart`.
   - Responsive across Desktop (`width >= 768`, 2-column centered card) and
     Mobile / Samsung S26 Ultra (`width < 768`, single-column centered card).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly User ID + Password sign-in (`AuthService().signInWithUserId`).
   - Prefills & selects the last logged-in User ID on the device
     (`AuthService().loadLastLoginUserId()`), auto-focused on load.
   - Keyboard-first 3-stop Tab traversal on login:
     1) `User ID` -> 2) `Password` -> 3) `Sign In` (`OrderedTraversalPolicy`).
     Theme switch, native `InputFeature.passwordToggle`, and `Create Account`
     secondary button skip traversal so `Tab` flows strictly to `Sign In`.
   - Profile creation (`AuthService().registerWithUserId`) asks for:
     User ID, Full Name, Mobile No, Optional Email ID, and Password, enqueuing
     an Admin approval request in `IMMBE2627.sb_onboarding_requests`.

3. UI & SHADCN FLUTTER COMPLIANCE:
   - Strict native `dynamic_ai` & `DyColorSystem` tokens: `colors.card`,
     `colors.border`, `theme.borderRadiusMd`, `theme.density.baseContainerPadding`,
     `shad.DensityGap`, `shad.OutlinedContainer`, `shad.SecondaryButton`,
     `shad.PrimaryButton`, `shad.Switch`, `shad.TextField`.
   - Zero custom `Container` wrappers or `BoxShadow` theme violations.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None currently.
================================================================================
*/

library;

import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/services.dart'
    show
        HardwareKeyboard,
        KeyDownEvent,
        KeyRepeatEvent,
        LogicalKeyboardKey,
        TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../dynamic_ai/micro/dy_dhaaga_logo.dart';
import '../../../main.dart';
import '../../../services/workspace/srv_auth.dart';
import 'widgets/textile_weave_background.dart';

class ScrAdminAuthLogin extends StatefulWidget {
  const ScrAdminAuthLogin({super.key});

  @override
  State<ScrAdminAuthLogin> createState() => _ScrAdminAuthLoginState();
}

class _ScrAdminAuthLoginState extends State<ScrAdminAuthLogin> {
  // Mode Toggle: false = Sign In, true = Create Account
  bool _isCreateMode = false;

  // Controllers
  late final TextEditingController _userIdCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  // Enclosed focus fence + ordered traversal focus nodes
  final FocusScopeNode _formScopeNode = FocusScopeNode();
  final FocusNode _userIdFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _signInBtnFocus = FocusNode();

  // Skipped-from-Tab utility focus nodes
  final FocusNode _createAccountBtnFocus = FocusNode(skipTraversal: true);

  bool _isLoading = false;
  bool _userEditedId = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userIdCtrl = TextEditingController(text: AuthService().lastLoginUserId);
    _userIdCtrl.addListener(_onUserIdChanged);
    _hydrateLastUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _userIdFocus.requestFocus();
      _selectAllUserId();
    });
  }

  void _onUserIdChanged() {
    if (_userIdFocus.hasFocus) {
      _userEditedId = true;
    }
  }

  Future<void> _hydrateLastUserId() async {
    final saved = await AuthService().loadLastLoginUserId();
    if (!mounted || _userEditedId) return;
    if (saved.isNotEmpty && _userIdCtrl.text != saved) {
      _userIdCtrl.text = saved;
      _selectAllUserId();
    }
  }

  void _selectAllUserId() {
    final text = _userIdCtrl.text;
    if (text.isEmpty) return;
    _userIdCtrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: text.length,
    );
  }

  @override
  void dispose() {
    _userIdCtrl.removeListener(_onUserIdChanged);
    _userIdCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _formScopeNode.dispose();
    _userIdFocus.dispose();
    _fullNameFocus.dispose();
    _mobileFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _signInBtnFocus.dispose();
    _createAccountBtnFocus.dispose();
    super.dispose();
  }

  void _toggleMode(bool createMode) {
    setState(() {
      _isCreateMode = createMode;
      _errorMessage = null;
      _passwordCtrl.clear();
      if (createMode) {
        _userIdCtrl.clear();
      } else if (_userIdCtrl.text.trim().isEmpty) {
        _userIdCtrl.text = AuthService().lastLoginUserId;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _userIdFocus.requestFocus();
      if (!createMode) {
        _selectAllUserId();
      }
    });
  }

  Future<void> _handleSignIn() async {
    final userId = _userIdCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (userId.isEmpty) {
      setState(() => _errorMessage = 'Enter your User ID.');
      _userIdFocus.requestFocus();
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Enter your password.');
      _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signInWithUserId(
        userId: userId,
        password: password,
      );
      if (!mounted) return;
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Signed in to Dhaaga.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCreateProfile() async {
    final userId = _userIdCtrl.text.trim();
    final fullName = _fullNameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (userId.length < 3) {
      setState(() => _errorMessage = 'User ID must be at least 3 characters.');
      _userIdFocus.requestFocus();
      return;
    }
    if (fullName.isEmpty) {
      setState(() => _errorMessage = 'Full Name is required.');
      _fullNameFocus.requestFocus();
      return;
    }
    final digitsOnly = mobile.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      setState(() => _errorMessage = 'Enter a valid 10-digit Mobile No.');
      _mobileFocus.requestFocus();
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      setState(
        () => _errorMessage = 'Enter a valid Email ID or leave it blank.',
      );
      _emailFocus.requestFocus();
      return;
    }
    if (password.length < 6) {
      setState(
        () => _errorMessage = 'Password must be at least 6 characters.',
      );
      _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().registerWithUserId(
        userId: userId,
        fullName: fullName,
        mobileNo: digitsOnly,
        email: email.isEmpty ? null : email,
        password: password,
      );
      if (!mounted) return;
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Profile request sent to Admin for approval.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  KeyEventResult _handleFormKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey != LogicalKeyboardKey.tab) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final List<FocusNode> orderedNodes = _isCreateMode
          ? [
              _userIdFocus,
              _fullNameFocus,
              _mobileFocus,
              _emailFocus,
              _passwordFocus,
              _signInBtnFocus,
            ]
          : [
              _userIdFocus,
              _passwordFocus,
              _signInBtnFocus,
            ];

      final int currentIdx = orderedNodes.indexWhere((n) => n.hasFocus);
      final bool reverse = HardwareKeyboard.instance.isShiftPressed;
      final int nextIdx;
      if (currentIdx == -1) {
        nextIdx = 0;
      } else if (reverse) {
        nextIdx = (currentIdx - 1 + orderedNodes.length) % orderedNodes.length;
      } else {
        nextIdx = (currentIdx + 1) % orderedNodes.length;
      }

      final targetNode = orderedNodes[nextIdx];
      targetNode.requestFocus();
      if (targetNode == _userIdFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _selectAllUserId();
        });
      }
    }

    // Consume all Tab events (Down/Repeat/Up) so Chrome Web never moves focus
    // out of the canvas into the browser address/top bar.
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final double scale = theme.scaling;
    final double basePad = theme.density.baseContainerPadding * scale;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: FocusScope(
        node: _formScopeNode,
        autofocus: true,
        onKeyEvent: _handleFormKeyEvent,
        child: TextileWeaveBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 768;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: (isWide ? 32.0 : 16.0) * scale,
                      vertical: 20.0 * scale,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (isWide ? 820.0 : 420.0) * scale,
                      ),
                      child: shad.OutlinedContainer(
                        theme: shad.OutlinedContainerTheme(
                          backgroundColor: colors.card,
                          borderColor: colors.border,
                          borderWidth: 1.0,
                          borderRadius: theme.borderRadiusMd,
                          surfaceOpacity: 1.0,
                          surfaceBlur: 0.0,
                          padding: EdgeInsets.all(
                            isWide ? basePad * 2.0 : basePad * 1.4,
                          ),
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: isWide
                              ? _buildDesktopSplitCard(theme, colors, scale)
                              : _buildMobileStackedCard(theme, colors, scale),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSplitCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Side: Prominent Dhaaga Brand + Single-line Workspace Title + Theme Switch
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandMarkRow(),
                const shad.DensityGap(shad.gapLg),
                Text(
                  _isCreateMode
                      ? 'Create your workspace account'
                      : 'Sign in to your workspace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.h4.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.mutedForeground,
                  ),
                ),
                const Spacer(),
                _buildThemeSwitch(theme, colors, scale),
              ],
            ),
          ),
          const shad.DensityGap(shad.gap2xl),
          // Right Side: Keyboard-First Minimal Form
          Expanded(
            flex: 6,
            child: _buildFormSection(theme, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStackedCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildBrandMarkRow()),
            _buildThemeSwitch(theme, colors, scale),
          ],
        ),
        const shad.DensityGap(shad.gapLg),
        Text(
          _isCreateMode
              ? 'Create your workspace account'
              : 'Sign in to your workspace',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.h4.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.mutedForeground,
          ),
        ),
        const shad.DensityGap(shad.gapLg),
        _buildFormSection(theme, colors),
      ],
    );
  }

  Widget _buildBrandMarkRow() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DyDhaagaLogo(size: 48.0, animated: true),
        shad.DensityGap(shad.gapMd),
        DyDhaagaWordmark(fontSize: 26.0),
      ],
    );
  }

  Widget _buildThemeSwitch(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    return ValueListenableBuilder<shad.ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, child) {
        final bool isDark = mode == shad.ThemeMode.dark;
        return ExcludeFocusTraversal(
          child: shad.Switch(
            value: isDark,
            onChanged: (nextDark) {
              themeModeNotifier.value =
                  nextDark ? shad.ThemeMode.dark : shad.ThemeMode.light;
            },
            theme: shad.SwitchTheme(
              gap: theme.density.baseGap * scale * shad.gapSm,
              inactiveColor: colors.border,
              inactiveThumbColor: colors.foreground,
            ),
            leading: Icon(
              shad.LucideIcons.sun,
              size: 14 * scale,
              color: isDark ? colors.mutedForeground : colors.foreground,
            ),
            trailing: Icon(
              shad.LucideIcons.moon,
              size: 14 * scale,
              color: isDark ? colors.foreground : colors.mutedForeground,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    return shad.Form(
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              shad.Alert.destructive(
                title: Text(
                  _isCreateMode ? 'Registration Error' : 'Sign In Failed',
                ),
                content: Text(_errorMessage!),
              ),
              const shad.DensityGap(shad.gapMd),
            ],

            _buildFieldLabel(theme, colors, 'User ID'),
            const shad.DensityGap(shad.gapXs),

            // Stop 1: User ID (auto-focused + prefilled)
            FocusTraversalOrder(
              order: const NumericFocusOrder(1.0),
              child: shad.TextField(
                controller: _userIdCtrl,
                focusNode: _userIdFocus,
                autofocus: true,
                placeholder: Text(
                  _isCreateMode
                      ? 'Choose a User ID (e.g. RAMESH01)'
                      : 'User ID',
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  if (_isCreateMode) {
                    _fullNameFocus.requestFocus();
                  } else {
                    _passwordFocus.requestFocus();
                  }
                },
              ),
            ),

            // Create Account extra fields
            if (_isCreateMode) ...[
              const shad.DensityGap(shad.gapMd),
              _buildFieldLabel(theme, colors, 'Full Name'),
              const shad.DensityGap(shad.gapXs),
              FocusTraversalOrder(
                order: const NumericFocusOrder(2.0),
                child: shad.TextField(
                  controller: _fullNameCtrl,
                  focusNode: _fullNameFocus,
                  placeholder: const Text('Your full name'),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _mobileFocus.requestFocus(),
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              _buildFieldLabel(theme, colors, 'Mobile No'),
              const shad.DensityGap(shad.gapXs),
              FocusTraversalOrder(
                order: const NumericFocusOrder(3.0),
                child: shad.TextField(
                  controller: _mobileCtrl,
                  focusNode: _mobileFocus,
                  keyboardType: TextInputType.phone,
                  placeholder: const Text('10-digit mobile number'),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              _buildFieldLabel(theme, colors, 'Email ID (Optional)'),
              const shad.DensityGap(shad.gapXs),
              FocusTraversalOrder(
                order: const NumericFocusOrder(4.0),
                child: shad.TextField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  placeholder: const Text('Optional email address'),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
              ),
            ],

            const shad.DensityGap(shad.gapMd),
            _buildFieldLabel(theme, colors, 'Password'),
            const shad.DensityGap(shad.gapXs),

            // Stop 2: Password (native passwordToggle skips focus traversal)
            FocusTraversalOrder(
              order: NumericFocusOrder(_isCreateMode ? 5.0 : 2.0),
              child: shad.TextField(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                skipInputFeatureFocusTraversal: true,
                obscureText: true,
                placeholder: const Text('Password'),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (_isLoading) return;
                  if (_isCreateMode) {
                    _handleCreateProfile();
                  } else {
                    _handleSignIn();
                  }
                },
                features: const [
                  shad.InputFeature.passwordToggle(
                    skipFocusTraversal: true,
                  ),
                ],
              ),
            ),

            const shad.DensityGap(shad.gapXl),

            // End-aligned action buttons: Secondary (skipped by Tab) -> Primary (Stop 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shad.SecondaryButton(
                  focusNode: _createAccountBtnFocus,
                  onPressed: _isLoading
                      ? null
                      : () => _toggleMode(!_isCreateMode),
                  child: Text(
                    _isCreateMode ? 'Back to Sign In' : 'Create Account',
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                FocusTraversalOrder(
                  order: NumericFocusOrder(_isCreateMode ? 6.0 : 3.0),
                  child: shad.PrimaryButton(
                    focusNode: _signInBtnFocus,
                    onPressed: _isLoading
                        ? null
                        : (_isCreateMode
                            ? _handleCreateProfile
                            : _handleSignIn),
                    leading: _isLoading
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: shad.CircularProgressIndicator(),
                          )
                        : null,
                    child: Text(_isCreateMode ? 'Request Access' : 'Sign In'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String text,
  ) {
    return Text(
      text,
      style: theme.typography.xSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.foreground,
      ),
    );
  }
}
