/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Engine-level global two-tier keyboard shortcut dispatcher (`KeyboardManagerWidget`)
     for Ambaji ERP:
       * Tier 1 (`Alt` = App Shell): Solo tap toggles App KeyCaps ON/OFF
         (`H, Q, M, P, S, F, W`, `1..9`, `K, N, T, D, U`); solo hold (`>= 400ms`)
         expands/collapses left `NavigationRail` once; `Alt + Letter/1..9` navigates
         modules & tabs.
       * Tier 2 (`Shift` = Current Module Page): Solo tap or hold activates page
         region badges (`1..9`) & page section keycaps; `Shift + 1..9` / `Shift + Letter`
         jumps to module sections/elements.
       * `Tab` / `Shift + Tab`: Pure focus traversal (`1` step forward/back).
       * `Esc` & Workspace Tab Switch: Clears KeyCaps, region badges & focus ring.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Guardrail 1: Any non-Alt key pressed during an `Alt` hold cancels the `400ms`
     sidebar toggle timer immediately (`_altComboUsed = true`).
   - Guardrail 2: Sidebar expand/collapse triggers at most once per physical `Alt`
     hold (`_altHoldFired = true`).
   - Guarded by `!_isEditingText()` so typing in search/form fields never misfires
     Shift page jumps or latched Alt shortcuts.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Checks both `logicalKey` and `physicalKey` for digits `1..9` so `Shift + 1..9`
     matches cleanly even when `logicalKey` maps to `! @ # ...`.
   - `_syncPhysicalModifiersOnPointer()` resets dropped physical holds without
     erasing intentional tap-latched states (`_altLatched`, `_shiftLatched`).

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future form-scoped focus traversal (`Tab` / `Enter` / `Esc`) can bind locally inside
     dedicated form dialogs and canvases.
================================================================================
*/

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../services/service_keyboard_shortcuts.dart';

/// Top-level wrapper widget binding two-tier global & module shortcuts.
class KeyboardManagerWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onGlobalSearch;
  final ValueChanged<int>? onWorkspaceTab;
  final ValueChanged<bool>? onCycleTab;
  final ValueChanged<String>? onSidebarShortcut;
  final ValueChanged<String>? onHeaderShortcut;
  final bool Function(String keyChar)? onSubmoduleShortcut;
  final ValueChanged<int>? onRegionTeleport;
  final VoidCallback? onBackspaceBacktrack;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onSaveForm;
  final VoidCallback? onEscapeOverlay;

  const KeyboardManagerWidget({
    super.key,
    required this.child,
    this.onGlobalSearch,
    this.onWorkspaceTab,
    this.onCycleTab,
    this.onSidebarShortcut,
    this.onHeaderShortcut,
    this.onSubmoduleShortcut,
    this.onRegionTeleport,
    this.onBackspaceBacktrack,
    this.onToggleSidebar,
    this.onSaveForm,
    this.onEscapeOverlay,
  });

  @override
  State<KeyboardManagerWidget> createState() => _KeyboardManagerWidgetState();
}

class _KeyboardManagerWidgetState extends State<KeyboardManagerWidget>
    with WidgetsBindingObserver {
  static final Map<LogicalKeyboardKey, String> _altSidebarKeys = {
    LogicalKeyboardKey.keyH: 'H',
    LogicalKeyboardKey.keyQ: 'Q',
    LogicalKeyboardKey.keyM: 'M',
    LogicalKeyboardKey.keyP: 'P',
    LogicalKeyboardKey.keyS: 'S',
    LogicalKeyboardKey.keyF: 'F',
    LogicalKeyboardKey.keyW: 'W',
  };

  static final Map<LogicalKeyboardKey, String> _altHeaderKeys = {
    LogicalKeyboardKey.keyK: 'K',
    LogicalKeyboardKey.keyN: 'N',
    LogicalKeyboardKey.keyT: 'T',
    LogicalKeyboardKey.keyD: 'D',
    LogicalKeyboardKey.keyU: 'U',
  };

  static final Map<LogicalKeyboardKey, int> _altTabIndexKeys = {
    LogicalKeyboardKey.digit1: 0,
    LogicalKeyboardKey.digit2: 1,
    LogicalKeyboardKey.digit3: 2,
    LogicalKeyboardKey.digit4: 3,
    LogicalKeyboardKey.digit5: 4,
    LogicalKeyboardKey.digit6: 5,
    LogicalKeyboardKey.digit7: 6,
    LogicalKeyboardKey.digit8: 7,
    LogicalKeyboardKey.digit9: 8,
    LogicalKeyboardKey.numpad1: 0,
    LogicalKeyboardKey.numpad2: 1,
    LogicalKeyboardKey.numpad3: 2,
    LogicalKeyboardKey.numpad4: 3,
    LogicalKeyboardKey.numpad5: 4,
    LogicalKeyboardKey.numpad6: 5,
    LogicalKeyboardKey.numpad7: 6,
    LogicalKeyboardKey.numpad8: 7,
    LogicalKeyboardKey.numpad9: 8,
  };

  static final Map<PhysicalKeyboardKey, int> _physicalDigitKeys = {
    PhysicalKeyboardKey.digit1: 0,
    PhysicalKeyboardKey.digit2: 1,
    PhysicalKeyboardKey.digit3: 2,
    PhysicalKeyboardKey.digit4: 3,
    PhysicalKeyboardKey.digit5: 4,
    PhysicalKeyboardKey.digit6: 5,
    PhysicalKeyboardKey.digit7: 6,
    PhysicalKeyboardKey.digit8: 7,
    PhysicalKeyboardKey.digit9: 8,
    PhysicalKeyboardKey.numpad1: 0,
    PhysicalKeyboardKey.numpad2: 1,
    PhysicalKeyboardKey.numpad3: 2,
    PhysicalKeyboardKey.numpad4: 3,
    PhysicalKeyboardKey.numpad5: 4,
    PhysicalKeyboardKey.numpad6: 5,
    PhysicalKeyboardKey.numpad7: 6,
    PhysicalKeyboardKey.numpad8: 7,
    PhysicalKeyboardKey.numpad9: 8,
  };

  final FocusScopeNode _workspaceFocusScope = FocusScopeNode(
    debugLabel: 'AmbajiWorkspaceFocusScope',
  );

  // Tier 1: Alt state machine
  Timer? _altHoldTimer;
  bool _altDownActive = false;
  bool _altLatched = false;
  bool _altWasLatchedOnPress = false;
  bool _altComboUsed = false;
  bool _altHoldFired = false;

  // Tier 2: Shift state machine
  bool _shiftDownActive = false;
  bool _shiftLatched = false;
  bool _shiftWasLatchedOnPress = false;
  bool _shiftComboUsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
    ServiceKeyboardShortcuts.instance.onResetWorkspaceKeyboardState =
        resetKeyboardAndFocusState;
    ServiceKeyboardShortcuts.instance.syncAltState(false);
    ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _parkScopeUnselected();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (ServiceKeyboardShortcuts.instance.onResetWorkspaceKeyboardState ==
        resetKeyboardAndFocusState) {
      ServiceKeyboardShortcuts.instance.onResetWorkspaceKeyboardState = null;
    }
    _resetModifierStates();
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _workspaceFocusScope.dispose();
    super.dispose();
  }

  void resetKeyboardAndFocusState() {
    _resetModifierStates();
    _parkScopeUnselected();
  }

  FocusScopeNode get _activeTargetFocusScope {
    final tabScope = ServiceKeyboardShortcuts.instance.activeTabFocusScope;
    if (tabScope != null && tabScope.context != null) {
      return tabScope;
    }
    return _workspaceFocusScope;
  }

  void _parkScopeUnselected() {
    final targetScope = _activeTargetFocusScope;
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary != targetScope) {
      primary.unfocus(disposition: UnfocusDisposition.scope);
    }
    if (!targetScope.hasFocus) {
      targetScope.requestFocus();
    }
  }

  void _advanceFocus({required bool reverse}) {
    final targetScope = _activeTargetFocusScope;
    final descendants = targetScope.traversalDescendants.toList();
    if (descendants.isEmpty) return;

    final current = FocusManager.instance.primaryFocus;
    final currentIndex = current != null ? descendants.indexOf(current) : -1;
    if (currentIndex == -1) {
      final target = reverse ? descendants.last : descendants.first;
      target.requestFocus();
      return;
    }

    final nextIndex = reverse
        ? (currentIndex - 1 + descendants.length) % descendants.length
        : (currentIndex + 1) % descendants.length;
    descendants[nextIndex].requestFocus();
  }

  void _clearAltState() {
    _altHoldTimer?.cancel();
    _altHoldTimer = null;
    _altDownActive = false;
    _altLatched = false;
    _altWasLatchedOnPress = false;
    _altComboUsed = false;
    _altHoldFired = false;
    ServiceKeyboardShortcuts.instance.syncAltState(false);
  }

  void _clearShiftState() {
    _shiftDownActive = false;
    _shiftLatched = false;
    _shiftWasLatchedOnPress = false;
    _shiftComboUsed = false;
    ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
  }

  void _resetModifierStates() {
    _clearAltState();
    _clearShiftState();
  }

  void _syncPhysicalModifiersOnPointer() {
    final hw = HardwareKeyboard.instance;
    if (_altDownActive && !hw.isAltPressed) {
      _clearAltState();
    } else if (!_altLatched &&
        ServiceKeyboardShortcuts.instance.isAltPressedNotifier.value &&
        !hw.isAltPressed) {
      ServiceKeyboardShortcuts.instance.syncAltState(false);
    }

    if (_shiftDownActive && !hw.isShiftPressed) {
      _clearShiftState();
    } else if (!_shiftLatched &&
        ServiceKeyboardShortcuts.instance.isTabHeldNotifier.value &&
        !hw.isShiftPressed) {
      ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resetModifierStates();
  }

  bool _isAltKey(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight;

  bool _isShiftKey(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.shiftLeft ||
      key == LogicalKeyboardKey.shiftRight;

  int? _digitIndexForEvent(KeyEvent event) =>
      _altTabIndexKeys[event.logicalKey] ??
      _physicalDigitKeys[event.physicalKey];

  String? _letterForKey(LogicalKeyboardKey key) {
    final label = key.keyLabel.trim().toUpperCase();
    if (label.length == 1 &&
        label.codeUnitAt(0) >= 65 &&
        label.codeUnitAt(0) <= 90) {
      return label;
    }
    return null;
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (!mounted) return false;

    final hw = HardwareKeyboard.instance;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.tab && hw.isAltPressed) {
      resetKeyboardAndFocusState();
      return false;
    }

    // ── TIER 1: ALT KEY DOWN / UP / 400MS SIDEBAR TOGGLE ─────────────────
    if (_isAltKey(key)) {
      if (event is KeyDownEvent) {
        if (!_altDownActive &&
            !hw.isControlPressed &&
            !hw.isMetaPressed &&
            !hw.isShiftPressed) {
          _clearShiftState();
          _altWasLatchedOnPress = _altLatched;
          _altDownActive = true;
          _altComboUsed = false;
          _altHoldFired = false;
          ServiceKeyboardShortcuts.instance.syncAltState(true);

          _altHoldTimer?.cancel();
          _altHoldTimer = Timer(const Duration(milliseconds: 400), () {
            if (!mounted ||
                !_altDownActive ||
                _altComboUsed ||
                _altHoldFired ||
                ServiceKeyboardShortcuts.instance.isFlyoutOpenNotifier.value) {
              return;
            }
            _altHoldFired = true;
            widget.onToggleSidebar?.call();
          });
        }
        return false;
      }
      if (event is KeyUpEvent) {
        _altHoldTimer?.cancel();
        _altHoldTimer = null;
        if (_altDownActive) {
          _altDownActive = false;
          if (!_altComboUsed && !_altHoldFired) {
            _altLatched = !_altWasLatchedOnPress;
            ServiceKeyboardShortcuts.instance.syncAltState(_altLatched);
          } else {
            _altLatched = false;
            ServiceKeyboardShortcuts.instance.syncAltState(false);
          }
        }
        return false;
      }
      return false;
    }

    // Guardrail 1: Any non-Alt keypress during Alt hold cancels the 400ms timer.
    if ((_altDownActive || hw.isAltPressed) && event is KeyDownEvent) {
      _altHoldTimer?.cancel();
      _altHoldTimer = null;
      _altComboUsed = true;
    }

    // ── TIER 2: SHIFT KEY DOWN / UP (MODULE PAGE REGIONS & ACTIONS) ───────
    if (_isShiftKey(key)) {
      if (event is KeyDownEvent) {
        if (!_shiftDownActive &&
            !hw.isAltPressed &&
            !hw.isControlPressed &&
            !hw.isMetaPressed &&
            !_isEditingText()) {
          _clearAltState();
          _shiftWasLatchedOnPress = _shiftLatched;
          _shiftDownActive = true;
          _shiftComboUsed = false;
          ServiceKeyboardShortcuts.instance.syncTabHoldState(true);
        }
        return false;
      }
      if (event is KeyUpEvent && _shiftDownActive) {
        _shiftDownActive = false;
        if (!_shiftComboUsed && !_isEditingText()) {
          _shiftLatched = !_shiftWasLatchedOnPress;
          ServiceKeyboardShortcuts.instance.syncTabHoldState(_shiftLatched);
        } else {
          _shiftLatched = false;
          ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
        }
        return false;
      }
      return false;
    }

    // ── PURE TAB / SHIFT+TAB TRAVERSAL ────────────────────────────────────
    if (key == LogicalKeyboardKey.tab &&
        !hw.isAltPressed &&
        !hw.isControlPressed &&
        !hw.isMetaPressed &&
        _workspaceFocusScope.hasFocus) {
      if (_shiftDownActive || _shiftLatched) {
        _shiftComboUsed = true;
        _shiftLatched = false;
        ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
      }
      if (event is KeyDownEvent || event is KeyRepeatEvent) {
        _advanceFocus(reverse: hw.isShiftPressed);
      }
      return true;
    }

    if (event is! KeyDownEvent) return false;

    // ── ESCAPE RESET ──────────────────────────────────────────────────────
    if (key == LogicalKeyboardKey.escape) {
      resetKeyboardAndFocusState();
      widget.onEscapeOverlay?.call();
      return false;
    }

    // ── BACKSPACE STRUCTURAL BACKTRACK ────────────────────────────────────
    if (key == LogicalKeyboardKey.backspace &&
        !hw.isAltPressed &&
        !hw.isControlPressed &&
        !hw.isMetaPressed &&
        !hw.isShiftPressed &&
        !_isEditingText()) {
      if (ServiceKeyboardShortcuts.instance.dispatchModuleBackspace()) {
        return true;
      }
      widget.onBackspaceBacktrack?.call();
      return true;
    }

    // ── TIER 1 EXECUTION: ALT (PHYSICAL OR LATCHED) ───────────────────────
    final altModifierActive = hw.isAltPressed || (_altLatched && !_isEditingText());
    if (altModifierActive &&
        !hw.isControlPressed &&
        !hw.isMetaPressed &&
        !hw.isShiftPressed) {
      final sidebarKey = _altSidebarKeys[key];
      if (sidebarKey != null && widget.onSidebarShortcut != null) {
        _altComboUsed = true;
        _altLatched = false;
        ServiceKeyboardShortcuts.instance.syncAltState(false);
        widget.onSidebarShortcut!(sidebarKey);
        return true;
      }

      final headerKey = _altHeaderKeys[key];
      if (headerKey != null && widget.onHeaderShortcut != null) {
        _altComboUsed = true;
        _altLatched = false;
        ServiceKeyboardShortcuts.instance.syncAltState(false);
        widget.onHeaderShortcut!(headerKey);
        return true;
      }

      final tabIndex = _digitIndexForEvent(event);
      if (tabIndex != null && widget.onWorkspaceTab != null) {
        _altComboUsed = true;
        _altLatched = false;
        ServiceKeyboardShortcuts.instance.syncAltState(false);
        widget.onWorkspaceTab!(tabIndex);
        return true;
      }
    }

    // ── CTRL SHORTCUTS (SAVE / CYCLE TABS) ────────────────────────────────
    if (hw.isControlPressed && !hw.isAltPressed && !hw.isMetaPressed) {
      if (key == LogicalKeyboardKey.keyS &&
          !hw.isShiftPressed &&
          widget.onSaveForm != null) {
        widget.onSaveForm!();
        return true;
      }
      if (key == LogicalKeyboardKey.tab && widget.onCycleTab != null) {
        widget.onCycleTab!(!hw.isShiftPressed);
        return true;
      }
    }

    // ── TIER 2 EXECUTION: SHIFT (PHYSICAL OR LATCHED) ON MODULE PAGE ──────
    final shiftModeActive =
        (hw.isShiftPressed || _shiftLatched) &&
        !hw.isAltPressed &&
        !hw.isControlPressed &&
        !hw.isMetaPressed &&
        !_isEditingText();

    if (shiftModeActive) {
      final regionIdx = _digitIndexForEvent(event);
      if (regionIdx != null) {
        final region = regionIdx + 1;
        _shiftComboUsed = true;
        _shiftLatched = false;
        ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
        final handled =
            ServiceKeyboardShortcuts.instance.dispatchRegionTeleport(region);
        if (!handled) widget.onRegionTeleport?.call(region);
        return true;
      }

      final label = _letterForKey(key);
      if (label != null) {
        if (widget.onSubmoduleShortcut != null &&
            widget.onSubmoduleShortcut!(label)) {
          _shiftComboUsed = true;
          _shiftLatched = false;
          ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
          return true;
        }
        if (ServiceKeyboardShortcuts.instance.dispatchPageActionKey(label)) {
          _shiftComboUsed = true;
          _shiftLatched = false;
          ServiceKeyboardShortcuts.instance.syncTabHoldState(false);
          return true;
        }
      }
    }

    // ── UNMODIFIED BARE LETTER PASS-THROUGH (ARMED SIDEBAR / [N] ADD) ─────
    if (!hw.isAltPressed &&
        !hw.isControlPressed &&
        !hw.isMetaPressed &&
        !hw.isShiftPressed &&
        !_isEditingText()) {
      final label = _letterForKey(key);
      if (label != null) {
        if (widget.onSubmoduleShortcut != null &&
            widget.onSubmoduleShortcut!(label)) {
          return true;
        }
        if (key == LogicalKeyboardKey.keyN &&
            ServiceKeyboardShortcuts.instance.dispatchNewEntry()) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isEditingText() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    if (ctx.widget is EditableText) return true;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _syncPhysicalModifiersOnPointer(),
      onPointerHover: (_) => _syncPhysicalModifiersOnPointer(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: (_) => null),
          PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
            onInvoke: (_) => null,
          ),
        },
        child: FocusScope(
          node: _workspaceFocusScope,
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}
