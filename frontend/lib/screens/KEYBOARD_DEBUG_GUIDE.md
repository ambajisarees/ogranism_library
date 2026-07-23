# Keyboard Focus & Debugging System Guide

This guide documents the keyboard navigation system, focus policy, debug logging signatures, and step-by-step instructions to modify or revert keyboard logging in the **Ambaji Sarees ERP** codebase.

---

## 1. Keyboard Traversal & Focus Policy

1. **Default Focus on Page Load**: **`NONE`**
   - No widget receives automatic focus when a page or workspace tab mounts.
2. **First `Tab` Press**:
   - Pressing `Tab` for the first time moves focus to the **first available component in the Page Header** (Module Switcher trigger if available, or header action buttons).
3. **Sequential Traversal**:
   - Focus cycles through: `Page Header Controls` $\longrightarrow$ `DAB Search & Filters` $\longrightarrow$ `DAB Date & Sort` $\longrightarrow$ `Page Header Actions`.
4. **Individual Component `skipTraversal` Focus Strategy**:
   - Instead of wrapping entire layout containers in `Focus(descendantsAreFocusable: false)` (which broke `shad.TabPane` layout metrics), top bar buttons (`+` Add Tab button, Tab Close `x` buttons, Ctrl+K Search, Notifications bell, Theme toggle, Profile avatar) pass `focusNode: FocusNode(skipTraversal: true)` directly.
   - **Result**: Zero layout crashes (`RenderBox was not laid out`) while ensuring `Tab` completely skips workspace tab buttons and top bar utilities.
5. **Tap-to-Unfocus Dismissal**:
   - Tapping anywhere on empty screen space unfocuses form inputs cleanly while keeping `KeyboardManagerWidget`'s root `FocusScope` active so `Alt + 1..9` and `Ctrl + Tab` shortcuts stay permanently responsive.

---

## 2. Global Shortcuts Reference

| Shortcut | Intent | Action Description |
| :--- | :--- | :--- |
| `Ctrl + K` | `GlobalSearchIntent` | Opens Global Command Palette Search Overlay |
| `Alt + 1..9` | `WorkspaceTabIntent` | Switches directly to workspace tab `1` through `9` |
| `Ctrl + Tab` | `CycleTabIntent(forward: true)` | Cycles to next workspace tab |
| `Ctrl + Shift + Tab` | `CycleTabIntent(forward: false)` | Cycles to previous workspace tab |
| `Ctrl + S` | `SaveFormIntent` | Triggers form save action |
| `Esc` | `EscapeOverlayIntent` | Closes active popovers / unfocuses primary focus |

---

## 3. Terminal Debug Log Signatures

When running `flutter run -d windows`, keyboard actions emit the following structured logs:

- `[KeyboardManager] Global search (Ctrl+K) invoked`
- `[KeyboardManager] Switch workspace tab (Alt+1..9): Index X`
- `[KeyboardManager] Cycle workspace tab (Ctrl+Tab): forward=true`
- `[KeyboardManager] Unfocused primary focus via pointer down`
- `[PageHeader] Module expanded: Shifting focus to 1st module button`
- `[PageHeader] Module selected: Unfocusing focus`

---

## 4. How to Undo / Revert Keyboard Logging

If you want to mute or remove debug logging in the future:

1. **In [keyboard_manager_widget.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/core/keyboard_manager_widget.dart)**:
   - Search for `debugPrint('[KeyboardManager]...')` and comment out or remove the `debugPrint` calls inside `CallbackAction` and `Listener`.

2. **In [page_header.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/dynamic_ai/components/page_level/page_header.dart)**:
   - Search for `debugPrint('[PageHeader]...')` and comment out or remove the `debugPrint` statements inside `_toggleExpand` and `_selectModule`.

3. **Restoring Automatic Initial Focus (If desired)**:
   - In `_PageHeaderState.initState()` in `page_header.dart`, uncomment:
     ```dart
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted && _moduleTriggerFocusNode.canRequestFocus) {
         _moduleTriggerFocusNode.requestFocus();
       }
     });
     ```
