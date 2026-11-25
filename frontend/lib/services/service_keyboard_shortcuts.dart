/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized global desktop & web keyboard shortcut registry (`IMMBE2627` ERP shell).
   - Maps modifier + key activators to semantic Flutter `Intent`s consumed by `KeyboardManagerWidget`
     for zero-mouse ERP navigation across the left `NavigationRail` (`Alt + Letter`) and top
     workspace `TabPane` tabs (`Alt + 1..9`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Tier 1 (`Alt` = App Shell):
     * Solo `Alt` tap toggles App KeyCaps (`H, Q, M, P, S, F, W`, `1..9`, `K, N, T, D, U`) ON/OFF.
     * Solo `Alt` hold (`>= 400ms`) toggles left `NavigationRail` expanded/collapsed once.
     * `Alt + Letter` / `Alt + 1..9` navigates across rail modules and top workspace tabs.
   - Tier 2 (`Shift` = Active Module Page):
     * Solo `Shift` tap or hold reveals module region badges (`1..9`) & page section keycaps.
     * `Shift + 1..9` or `Shift + Letter` jumps to page regions or triggers page actions.
   - `Tab` / `Shift + Tab`: Pure focus traversal; `Esc` & tab switching clear all KeyCaps & focus.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Never hijack browser/OS shortcuts (`Ctrl+T`, `Ctrl+W`, `Ctrl+R`, `Ctrl+N`, `Ctrl+1..9`, `F5`, `Ctrl+F`).
   - `Alt+B` is intentionally removed in favor of `400ms` solo `Alt` hold for sidebar expansion/collapse.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: expose user-customizable mnemonic keycaps from user profile preferences.
================================================================================
*/

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ============================================================
// KEYBOARD INTENTS
// ============================================================

/// Intent to open the Global Command Palette Search (Ctrl + K)
class GlobalSearchIntent extends Intent {
  const GlobalSearchIntent();
}

/// Intent to switch directly to a Workspace Tab (Alt + 1..9)
class WorkspaceTabIntent extends Intent {
  final int tabIndex;
  const WorkspaceTabIntent(this.tabIndex);
}

/// Intent to cycle through Workspace Tabs (Ctrl + Tab / Ctrl + Shift + Tab)
class CycleTabIntent extends Intent {
  final bool forward;
  const CycleTabIntent({this.forward = true});
}

/// Intent to save active transaction or form (Ctrl + S)
class SaveFormIntent extends Intent {
  const SaveFormIntent();
}

/// Intent to close active overlay, popover, or modal (Esc)
class EscapeOverlayIntent extends Intent {
  const EscapeOverlayIntent();
}

/// Intent to trigger a left NavigationRail item or category folder via Alt + Letter.
class SidebarShortcutIntent extends Intent {
  final String keyChar;
  const SidebarShortcutIntent(this.keyChar);
}

/// Registered per-module shortcut callbacks active while a linear module shell is visible.
class ModuleShortcutBinding {
  final bool Function() isActive;
  final ValueChanged<int>? onRegionTeleport;
  final bool Function(String keyChar)? onPageActionKey;
  final VoidCallback? onNewEntry;
  final bool Function()? onBackspace;

  const ModuleShortcutBinding({
    required this.isActive,
    this.onRegionTeleport,
    this.onPageActionKey,
    this.onNewEntry,
    this.onBackspace,
  });
}

// ============================================================
// SERVICE KEYBOARD SHORTCUTS REGISTRY
// ============================================================

class ServiceKeyboardShortcuts {
  ServiceKeyboardShortcuts._();
  static final ServiceKeyboardShortcuts instance = ServiceKeyboardShortcuts._();

  /// Reactive notifier reflecting whether physical Alt key is currently held down.
  final ValueNotifier<bool> isAltPressedNotifier = ValueNotifier<bool>(false);

  /// Reactive notifier reflecting whether a sidebar submodule flyout popover is open.
  final ValueNotifier<bool> isFlyoutOpenNotifier = ValueNotifier<bool>(false);

  /// Reactive notifier reflecting whether Shift module-page KeyCaps/Regions (`1..9`, letters) are visible.
  final ValueNotifier<bool> isTabHeldNotifier = ValueNotifier<bool>(false);

  /// Optional direct hooks and multi-tab active module bindings.
  ValueChanged<int>? activeRegionTeleportHandler;
  VoidCallback? activeNewEntryHandler;
  bool Function()? activeBackspaceHandler;
  VoidCallback? onResetWorkspaceKeyboardState;
  FocusScopeNode? activeTabFocusScope;
  final List<ModuleShortcutBinding> _moduleBindings = [];

  void registerModuleBinding(ModuleShortcutBinding binding) {
    if (!_moduleBindings.contains(binding)) {
      _moduleBindings.add(binding);
    }
  }

  void unregisterModuleBinding(ModuleShortcutBinding binding) {
    _moduleBindings.remove(binding);
  }

  ModuleShortcutBinding? get _activeModuleBinding {
    for (int i = _moduleBindings.length - 1; i >= 0; i--) {
      final b = _moduleBindings[i];
      if (b.isActive()) return b;
    }
    return null;
  }

  bool dispatchRegionTeleport(int regionIndex) {
    if (activeRegionTeleportHandler != null) {
      activeRegionTeleportHandler!(regionIndex);
      return true;
    }
    final handler = _activeModuleBinding?.onRegionTeleport;
    if (handler != null) {
      handler(regionIndex);
      return true;
    }
    return false;
  }

  bool dispatchNewEntry() {
    if (activeNewEntryHandler != null) {
      activeNewEntryHandler!();
      return true;
    }
    final handler = _activeModuleBinding?.onNewEntry;
    if (handler != null) {
      handler();
      return true;
    }
    return false;
  }

  bool dispatchPageActionKey(String keyChar) {
    final normalized = keyChar.trim().toUpperCase();
    if (normalized.isEmpty) return false;
    final handler = _activeModuleBinding?.onPageActionKey;
    if (handler != null && handler(normalized)) {
      return true;
    }
    if (normalized == 'N') {
      return dispatchNewEntry();
    }
    return false;
  }

  void resetWorkspaceKeyboardState() {
    syncAltState(false);
    syncTabHoldState(false);
    onResetWorkspaceKeyboardState?.call();
  }

  bool dispatchModuleBackspace() {
    if (activeBackspaceHandler != null) {
      return activeBackspaceHandler!();
    }
    final handler = _activeModuleBinding?.onBackspace;
    if (handler != null) {
      return handler();
    }
    return false;
  }

  void syncAltState(bool isAltPressed) {
    if (isAltPressedNotifier.value != isAltPressed) {
      isAltPressedNotifier.value = isAltPressed;
    }
  }

  void syncFlyoutState(bool isOpen) {
    if (isFlyoutOpenNotifier.value != isOpen) {
      isFlyoutOpenNotifier.value = isOpen;
    }
  }

  void syncTabHoldState(bool isHeld) {
    if (isTabHeldNotifier.value != isHeld) {
      isTabHeldNotifier.value = isHeld;
    }
  }

  /// Default application shortcut key combinations map
  Map<ShortcutActivator, Intent> get defaultShortcuts {
    return {
      // Global Search (Alt + K)
      const SingleActivator(LogicalKeyboardKey.keyK, alt: true):
          const GlobalSearchIntent(),

      // Quick Workspace Tabs (Alt + 1..9)
      const SingleActivator(LogicalKeyboardKey.digit1, alt: true):
          const WorkspaceTabIntent(0),
      const SingleActivator(LogicalKeyboardKey.digit2, alt: true):
          const WorkspaceTabIntent(1),
      const SingleActivator(LogicalKeyboardKey.digit3, alt: true):
          const WorkspaceTabIntent(2),
      const SingleActivator(LogicalKeyboardKey.digit4, alt: true):
          const WorkspaceTabIntent(3),
      const SingleActivator(LogicalKeyboardKey.digit5, alt: true):
          const WorkspaceTabIntent(4),
      const SingleActivator(LogicalKeyboardKey.digit6, alt: true):
          const WorkspaceTabIntent(5),
      const SingleActivator(LogicalKeyboardKey.digit7, alt: true):
          const WorkspaceTabIntent(6),
      const SingleActivator(LogicalKeyboardKey.digit8, alt: true):
          const WorkspaceTabIntent(7),
      const SingleActivator(LogicalKeyboardKey.digit9, alt: true):
          const WorkspaceTabIntent(8),

      // Left NavigationRail Direct & Folder Shortcuts (Alt + Letter)
      const SingleActivator(LogicalKeyboardKey.keyH, alt: true):
          const SidebarShortcutIntent('H'),
      const SingleActivator(LogicalKeyboardKey.keyQ, alt: true):
          const SidebarShortcutIntent('Q'),
      const SingleActivator(LogicalKeyboardKey.keyM, alt: true):
          const SidebarShortcutIntent('M'),
      const SingleActivator(LogicalKeyboardKey.keyP, alt: true):
          const SidebarShortcutIntent('P'),
      const SingleActivator(LogicalKeyboardKey.keyS, alt: true):
          const SidebarShortcutIntent('S'),
      const SingleActivator(LogicalKeyboardKey.keyF, alt: true):
          const SidebarShortcutIntent('F'),
      const SingleActivator(LogicalKeyboardKey.keyW, alt: true):
          const SidebarShortcutIntent('W'),

      // Cycle Workspace Tabs (Ctrl + Tab / Ctrl + Shift + Tab)
      const SingleActivator(LogicalKeyboardKey.tab, control: true):
          const CycleTabIntent(forward: true),
      const SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true):
          const CycleTabIntent(forward: false),

      // Save Transaction (Ctrl + S)
      const SingleActivator(LogicalKeyboardKey.keyS, control: true):
          const SaveFormIntent(),

      // Escape Overlay (Esc)
      const SingleActivator(LogicalKeyboardKey.escape):
          const EscapeOverlayIntent(),
    };
  }
}
