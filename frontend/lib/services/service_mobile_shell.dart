/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized mobile TopBar coordinator (`ServiceMobileShell`) linking the
     active module canvas (`DyLinearLandingCanvas`) to the root mobile TopBar
     (`DynamicMobileShell` in `dy_module_tabs.dart`).
   - Allows the 2nd-row region `shad.TabList` (`Metrics | Data | Tasks | Reports`),
     module `+ Add` trigger, and nested List -> Details `[←]` back header to
     live cleanly inside the TopBar above the divider instead of inside the body.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Holds `ValueNotifier<MobileTopBarConfig?>` (`configNotifier`).
   - Only the active visible tab should push updates (`TickerMode.enabled`);
     disposing or switching to a non-tabbed module clears the config cleanly.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Updates should be scheduled post-frame when invoked during `build()` to
     prevent `setState() or markNeedsBuild() called during build`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: expose contextual search or filter count badges inside
     `MobileTopBarConfig` when rolling out across Masters & Sales modules.
================================================================================
*/

import 'package:flutter/widgets.dart';

/// TopBar configuration pushed by the active mobile module shell.
@immutable
class MobileTopBarConfig {
  final List<String> tabLabels;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabChanged;
  final String? subviewTitle;
  final VoidCallback? onBackFromSubview;
  final VoidCallback? onAddPressed;

  const MobileTopBarConfig({
    this.tabLabels = const [],
    this.selectedTabIndex = 0,
    this.onTabChanged,
    this.subviewTitle,
    this.onBackFromSubview,
    this.onAddPressed,
  });
}

/// Singleton mobile shell state bridge between active module bodies and `DynamicMobileShell`.
class ServiceMobileShell {
  ServiceMobileShell._();

  static final ServiceMobileShell instance = ServiceMobileShell._();

  final ValueNotifier<MobileTopBarConfig?> configNotifier =
      ValueNotifier<MobileTopBarConfig?>(null);

  /// Updates the active TopBar configuration.
  void update(MobileTopBarConfig? config) {
    configNotifier.value = config;
  }

  /// Clears custom module tabs / subview state back to standard Home TopBar mode.
  void clear() {
    if (configNotifier.value != null) {
      configNotifier.value = null;
    }
  }
}
