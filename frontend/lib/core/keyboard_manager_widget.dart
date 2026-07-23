import 'package:flutter/widgets.dart';
import '../services/service_keyboard_shortcuts.dart';

/// Top-level wrapper widget binding global keyboard shortcuts to application intent handlers.
class KeyboardManagerWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onGlobalSearch;
  final ValueChanged<int>? onWorkspaceTab;
  final ValueChanged<bool>? onCycleTab;
  final VoidCallback? onSaveForm;
  final VoidCallback? onEscapeOverlay;

  const KeyboardManagerWidget({
    super.key,
    required this.child,
    this.onGlobalSearch,
    this.onWorkspaceTab,
    this.onCycleTab,
    this.onSaveForm,
    this.onEscapeOverlay,
  });

  @override
  State<KeyboardManagerWidget> createState() => _KeyboardManagerWidgetState();
}

class _KeyboardManagerWidgetState extends State<KeyboardManagerWidget> {
  bool _hasActiveKeyboardSelection = false;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      onFocusChange: (focused) {
        if (focused) {
          _hasActiveKeyboardSelection = true;
        }
      },
      child: Shortcuts(
        shortcuts: ServiceKeyboardShortcuts.instance.defaultShortcuts,
        child: Actions(
          actions: <Type, Action<Intent>>{
            GlobalSearchIntent: CallbackAction<GlobalSearchIntent>(
              onInvoke: (_) {
                debugPrint('[KeyboardManager] Global search (Ctrl+K) invoked');
                widget.onGlobalSearch?.call();
                return null;
              },
            ),
            WorkspaceTabIntent: CallbackAction<WorkspaceTabIntent>(
              onInvoke: (intent) {
                debugPrint('[KeyboardManager] Switch workspace tab (Alt+1..9): Index ${intent.tabIndex}');
                widget.onWorkspaceTab?.call(intent.tabIndex);
                return null;
              },
            ),
            CycleTabIntent: CallbackAction<CycleTabIntent>(
              onInvoke: (intent) {
                debugPrint('[KeyboardManager] Cycle workspace tab (Ctrl+Tab): forward=${intent.forward}');
                widget.onCycleTab?.call(intent.forward);
                return null;
              },
            ),
            SaveFormIntent: CallbackAction<SaveFormIntent>(
              onInvoke: (_) {
                debugPrint('[KeyboardManager] Save form (Ctrl+S) invoked');
                widget.onSaveForm?.call();
                return null;
              },
            ),
            EscapeOverlayIntent: CallbackAction<EscapeOverlayIntent>(
              onInvoke: (_) {
                debugPrint('[KeyboardManager] Escape / Unfocus (Esc) invoked');
                widget.onEscapeOverlay?.call();
                return null;
              },
            ),
          },
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              final primaryFocus = FocusManager.instance.primaryFocus;
              if (_hasActiveKeyboardSelection && primaryFocus != null && primaryFocus.hasFocus) {
                debugPrint('[KeyboardManager] 1st Pointer Down -> Disabling active selection & unfocusing element');
                primaryFocus.unfocus();
                _hasActiveKeyboardSelection = false;
              } else {
                debugPrint('[KeyboardManager] Pointer Down -> Ignored (FocusScope unaffected)');
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
