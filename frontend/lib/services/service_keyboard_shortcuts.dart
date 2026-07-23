import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ================= ==========================================
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

// ================= ==========================================
// SERVICE KEYBOARD SHORTCUTS REGISTRY
// ============================================================

class ServiceKeyboardShortcuts {
  ServiceKeyboardShortcuts._();
  static final ServiceKeyboardShortcuts instance = ServiceKeyboardShortcuts._();

  /// Default application shortcut key combinations map
  Map<ShortcutActivator, Intent> get defaultShortcuts {
    return {
      // Global Search (Ctrl + K)
      const SingleActivator(LogicalKeyboardKey.keyK, control: true): const GlobalSearchIntent(),

      // Quick Workspace Tabs (Alt + 1..9)
      const SingleActivator(LogicalKeyboardKey.digit1, alt: true): const WorkspaceTabIntent(0),
      const SingleActivator(LogicalKeyboardKey.digit2, alt: true): const WorkspaceTabIntent(1),
      const SingleActivator(LogicalKeyboardKey.digit3, alt: true): const WorkspaceTabIntent(2),
      const SingleActivator(LogicalKeyboardKey.digit4, alt: true): const WorkspaceTabIntent(3),
      const SingleActivator(LogicalKeyboardKey.digit5, alt: true): const WorkspaceTabIntent(4),
      const SingleActivator(LogicalKeyboardKey.digit6, alt: true): const WorkspaceTabIntent(5),
      const SingleActivator(LogicalKeyboardKey.digit7, alt: true): const WorkspaceTabIntent(6),
      const SingleActivator(LogicalKeyboardKey.digit8, alt: true): const WorkspaceTabIntent(7),
      const SingleActivator(LogicalKeyboardKey.digit9, alt: true): const WorkspaceTabIntent(8),

      // Cycle Workspace Tabs (Ctrl + Tab / Ctrl + Shift + Tab)
      const SingleActivator(LogicalKeyboardKey.tab, control: true): const CycleTabIntent(forward: true),
      const SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true): const CycleTabIntent(forward: false),

      // Save Transaction (Ctrl + S)
      const SingleActivator(LogicalKeyboardKey.keyS, control: true): const SaveFormIntent(),

      // Escape Overlay (Esc)
      const SingleActivator(LogicalKeyboardKey.escape): const EscapeOverlayIntent(),
    };
  }
}
