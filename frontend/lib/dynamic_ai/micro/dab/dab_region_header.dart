/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Shared 4-region primitives for `DynamicActionBar` (`dab_region_header.dart`):
     * `DabRegion` (`metrics [1]`, `data [2]`, `tasks [3]`, `reports [4]`)
     * `DabTimeHorizon` (`thisYear`, `thisMonth`, `thisWeek`, `today`)
     * `DabRegionLeading` (Mandatory leading 36px `shad.OutlineButton` Expand /
       Collapse control with animated `Shift` KeyCap `1..4` swap)
     * `DabCompactTabs` / `DabTimeHorizonTabs` (36px native `shad.ButtonGroup` selector)
     * `DabRegionTrailingActions` (Optional trailing 36px `shad.OutlineButton`
       3-dots overflow menu via native `shad.showDropdown`)

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `DabRegionLeading` renders the 36x36 native `shad.OutlineButton` Expand/Collapse
     control whose icon smoothly morphs (`120ms` `Scale` + `Fade`) between
     `maximize2`/`minimize2` (`colors.mutedForeground`) and `_DabRegionKeyCap`
     (`1..4`) whenever `Shift` is active in the focused tab.
   - `DabRegionTrailingActions` renders the optional 36x36 native 3-dots
     `shad.OutlineButton` triggering `shad.showDropdown` (`DabOverflowPopover`).
   - `DabCompactTabs` uses native `shad.ButtonGroup` + `shad.SelectedButton` matching
     global `OutlineButtonTheme` (`colors.background` / `colors.accent` / `radiusMd`)
     and `colors.mutedForeground` text.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Pure native `shadcn_flutter` widgets (`shad.ButtonGroup`, `shad.SelectedButton`,
     `shad.OutlineButton`, `shad.OutlinedContainer`, `shad.Tooltip`,
     `shad.showDropdown`) with Rule 8 focus isolation on inner icons & KeyCaps.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None at this stage.
================================================================================
*/

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../services/service_keyboard_shortcuts.dart';
import 'dab_overflow_pop.dart';

bool get _isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

/// Canonical 4-region types rendered on Linear Landing canvases & Action Bars.
enum DabRegion {
  metrics,
  data,
  tasks,
  reports,
}

extension DabRegionMeta on DabRegion {
  int get regionNumber {
    switch (this) {
      case DabRegion.metrics:
        return 1;
      case DabRegion.data:
        return 2;
      case DabRegion.tasks:
        return 3;
      case DabRegion.reports:
        return 4;
    }
  }

  String get defaultTitle {
    switch (this) {
      case DabRegion.metrics:
        return 'Metrics';
      case DabRegion.data:
        return 'Data';
      case DabRegion.tasks:
        return 'Tasks';
      case DabRegion.reports:
        return 'Reports';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case DabRegion.metrics:
        return shad.LucideIcons.activity;
      case DabRegion.data:
        return shad.LucideIcons.table;
      case DabRegion.tasks:
        return shad.LucideIcons.squareCheck;
      case DabRegion.reports:
        return shad.LucideIcons.fileSpreadsheet;
    }
  }
}

/// Standard single-select time horizon options for `Metrics` & Analytics DABs.
enum DabTimeHorizon {
  thisYear,
  thisMonth,
  thisWeek,
  today,
}

extension DabTimeHorizonMeta on DabTimeHorizon {
  String get label {
    switch (this) {
      case DabTimeHorizon.thisYear:
        return 'This Year';
      case DabTimeHorizon.thisMonth:
        return 'This Month';
      case DabTimeHorizon.thisWeek:
        return 'This Week';
      case DabTimeHorizon.today:
        return 'Today';
    }
  }
}

/// Leading region Expand / Collapse `shad.OutlineButton` at the start of Desktop DAB strips.
class DabRegionLeading extends StatelessWidget {
  final DabRegion region;
  final String? titleOverride;
  final int? regionNumberOverride;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const DabRegionLeading({
    super.key,
    required this.region,
    this.titleOverride,
    this.regionNumberOverride,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    if (onToggleExpand == null) {
      return const SizedBox.shrink();
    }

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final iconMdSize = 20.0 * scaling;
    final iconSmSize = theme.iconTheme.small.size ?? 16.0;
    final regionNumber = regionNumberOverride ?? region.regionNumber;

    return shad.Tooltip(
      anchorAlignment: Alignment.bottomLeft,
      alignment: Alignment.topLeft,
      tooltip: (ctx) => shad.TooltipContainer(
        child: Text(isExpanded ? 'Collapse Region' : 'Expand Region'),
      ),
      child: SizedBox(
        width: 36 * scaling,
        height: 36 * scaling,
        child: shad.OutlineButton(
          density: shad.ButtonDensity.icon,
          alignment: Alignment.center,
          onPressed: onToggleExpand,
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            descendantsAreFocusable: false,
            child: SizedBox(
              width: iconMdSize,
              height: iconMdSize,
              child: ValueListenableBuilder<bool>(
                valueListenable:
                    ServiceKeyboardShortcuts.instance.isTabHeldNotifier,
                builder: (context, isShiftActive, _) {
                  final isTabActive = TickerMode.valuesOf(context).enabled;
                  final showKeyCap =
                      !_isAndroidPlatform && isTabActive && isShiftActive;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0)
                          .animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: showKeyCap
                        ? _DabRegionKeyCap(
                            key: ValueKey('dab_cap_$regionNumber'),
                            label: '$regionNumber',
                          )
                        : Center(
                            key: ValueKey('dab_expand_$isExpanded'),
                            child: Icon(
                              isExpanded
                                  ? shad.LucideIcons.minimize2
                                  : shad.LucideIcons.maximize2,
                              size: iconSmSize,
                              color: colors.mutedForeground,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact native `shad.ButtonGroup` single-select switcher matching `36px` DAB height.
class DabCompactTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const DabCompactTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final clampedIdx = selectedIndex.clamp(0, labels.length - 1);

    final segmentStyle = const shad.ButtonStyle.outline(
      size: shad.ButtonSize.normal,
      density: shad.ButtonDensity.normal,
    ).withPadding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scaling),
    );

    return SizedBox(
      height: 36 * scaling,
      child: shad.ButtonGroup(
        children: [
          for (int i = 0; i < labels.length; i++)
            shad.FocusToFront(
              child: shad.SelectedButton(
                value: i == clampedIdx,
                alignment: Alignment.center,
                style: segmentStyle,
                selectedStyle: segmentStyle,
                onChanged: onChanged != null ? (_) => onChanged!(i) : null,
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  descendantsAreFocusable: false,
                  child: Text(
                    labels[i],
                    style: theme.typography.textSmall.copyWith(
                      fontWeight:
                          i == clampedIdx ? FontWeight.w600 : FontWeight.w500,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single-select Time Horizon switcher (`This Year | This Month | This Week | Today`).
class DabTimeHorizonTabs extends StatelessWidget {
  final DabTimeHorizon selectedHorizon;
  final ValueChanged<DabTimeHorizon>? onHorizonChanged;

  const DabTimeHorizonTabs({
    super.key,
    required this.selectedHorizon,
    this.onHorizonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DabCompactTabs(
      labels: [for (final h in DabTimeHorizon.values) h.label],
      selectedIndex: selectedHorizon.index,
      onChanged: (idx) {
        if (idx >= 0 && idx < DabTimeHorizon.values.length) {
          onHorizonChanged?.call(DabTimeHorizon.values[idx]);
        }
      },
    );
  }
}

/// Optional trailing overflow (`3-dots`) control on DABs.
class DabRegionTrailingActions extends StatelessWidget {
  final VoidCallback? onOverflowPressed;
  final bool showOverflowButton;
  final bool showExpandButton;
  final int regionNumber;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const DabRegionTrailingActions({
    super.key,
    this.onOverflowPressed,
    this.showOverflowButton = true,
    this.showExpandButton = false,
    this.regionNumber = 1,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    if (!showOverflowButton) {
      return const SizedBox.shrink();
    }

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final iconMdSize = 20.0 * scaling;
    final iconSmSize = theme.iconTheme.small.size ?? 16.0;

    return Builder(
      builder: (btnContext) => SizedBox(
        width: 36 * scaling,
        height: 36 * scaling,
        child: shad.OutlineButton(
          density: shad.ButtonDensity.icon,
          alignment: Alignment.center,
          onPressed: () {
            if (onOverflowPressed != null) {
              onOverflowPressed!();
            } else {
              shad.showDropdown<void>(
                context: btnContext,
                anchorAlignment: Alignment.bottomRight,
                alignment: Alignment.topRight,
                offset: Offset(0, 4 * scaling),
                builder: (_) => const DabOverflowPopover(),
              );
            }
          },
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            descendantsAreFocusable: false,
            child: SizedBox(
              width: iconMdSize,
              height: iconMdSize,
              child: Center(
                child: Icon(
                  shad.LucideIcons.ellipsisVertical,
                  size: iconSmSize,
                  color: colors.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DabRegionKeyCap extends StatelessWidget {
  final String label;

  const _DabRegionKeyCap({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final capExtent = theme.iconTheme.medium.size ?? 20.0;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: false,
      child: shad.OutlinedContainer(
        width: capExtent,
        height: capExtent,
        backgroundColor: colors.mutedForeground,
        borderColor: colors.mutedForeground,
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        padding: EdgeInsets.zero,
        child: Center(
          child: Text(
            label,
            style: theme.typography.xSmall.merge(theme.typography.mono).copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: colors.primaryForeground,
                ),
          ),
        ),
      ),
    );
  }
}
