/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC LANDING CANVAS SHELL (dy_landing_canvas.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Unified single-canvas Base-12 Bento landing architecture for Ambaji ERP modules.
   - Replaces fragmented 4-tab subpage strips with one scrollable linear snapshot combining
     Row KPI Metrics, Trend + Tasks, and Details + Quick Reports on a single canvas.
   - Manages instant `Shift + 1..4` Card Enlargement (Flex 12 zoom), interactive `PageHeader`
     breadcrumbs, `[N]` Add Flow transitions (`DyFormCanvas`), and `Backspace` structural step-back.
   - Desktop 4-Region Bento split: Data (`dataColumnSpan`, default `9`) and Tasks + Reports
     (`12 - dataColumnSpan`, default `3`), sized via `DyGridSystem.spanWidth` so every column
     boundary aligns flush with the top KPI row (`3-3-3-3`, `4-4-4` + `8-4`, `6-3-3`, etc.).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly enforces gap-compensated Base-12 grid geometry (`DyFlexRow` + `DyFlexCell`
     with `flex` `1..12` on desktop) with automatic responsive vertical stacking below
     `DyGridSystem.breakpointTablet` (1024px).
   - Binds to `ServiceKeyboardShortcuts.instance` via `ModuleShortcutBinding` + `TickerMode`
     visibility check so multiple open `IndexedStack` tabs never steal shortcuts from each other.
   - Hides all shortcut keycaps automatically on `TargetPlatform.android`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Desktop split rows holding scrollable grids (`DyTable`, `ListView`, `fl_chart`) use
     bounded `LayoutBuilder` constraints rather than `IntrinsicHeight`.
   - Pure native `shadcn_flutter` tokens only (`colors.*`, `theme.typography.*`, `DensityGap`).
   - Exposes `DyLinearLandingCanvas` / `DyLinearLandingCanvasState` typedefs for backwards
     compatibility across Maps & Contacts sub-widgets.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Unsaved-dirty-form guard hook (`canExitAddFlow`) can plug into `onBackspace` in future writes.
================================================================================
*/

library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' hide Card, Tab, Badge, Divider;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../services/service_keyboard_shortcuts.dart';
import '../../services/service_mobile_shell.dart';
import '../micro/dab/dab_region_header.dart';
import '../page/dy_page_header.dart';
import '../root/dy_module_tabs.dart';
import '../specs/dy_color_system.dart';
import '../specs/dy_grid_system.dart';

bool get _isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

/// Backwards-compatible aliases during module rollout.
typedef DyLinearLandingCanvas = DyLandingCanvas;
typedef DyLinearLandingCanvasState = DyLandingCanvasState;

/// Cell specification for a Base-12 [DyFlexRow].
class DyFlexCell {
  final int flex;
  final Widget child;
  final double? compactHeight;

  const DyFlexCell({
    required this.flex,
    required this.child,
    this.compactHeight,
  }) : assert(
          flex >= 1 && flex <= DyGridSystem.flexBase,
          'DyFlexCell flex must be between 1 and 12.',
        );
}

/// Base-12 responsive Bento row that renders side-by-side gap-compensated columns
/// on wide screens (>= 1024px) and wraps/stacks cleanly on tablets and mobile viewports.
class DyFlexRow extends StatelessWidget {
  final List<DyFlexCell> cells;
  final bool isKpiRow;
  final double? desktopRowHeight;

  const DyFlexRow({
    super.key,
    required this.cells,
    this.isKpiRow = false,
    this.desktopRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();

    final theme = shad.Theme.of(context);
    final gapUnit = theme.density.baseGap * theme.scaling;
    final rowGap = gapUnit * shad.gapMd;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletOrMobile =
            constraints.maxWidth < DyGridSystem.breakpointTablet;

        if (isTabletOrMobile) {
          if (isKpiRow && constraints.maxWidth >= 560 * theme.scaling) {
            final itemWidth = (constraints.maxWidth - rowGap) / 2;
            return Wrap(
              spacing: rowGap,
              runSpacing: rowGap,
              children: cells
                  .map(
                    (c) => SizedBox(
                      width: itemWidth,
                      child: c.child,
                    ),
                  )
                  .toList(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < cells.length; i++) ...[
                if (i > 0) const shad.DensityGap(shad.gapMd),
                if (cells[i].compactHeight != null)
                  SizedBox(
                    height: cells[i].compactHeight! * theme.scaling,
                    child: cells[i].child,
                  )
                else
                  cells[i].child,
              ],
            ],
          );
        }

        final totalFlex = cells.fold<int>(0, (sum, c) => sum + c.flex);
        final useExactGrid =
            totalFlex == DyGridSystem.flexBase && cells.length > 1;

        final row = Row(
          crossAxisAlignment: desktopRowHeight != null
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              if (i > 0) const shad.DensityGap(shad.gapMd),
              if (useExactGrid && i < cells.length - 1)
                SizedBox(
                  width: DyGridSystem.spanWidth(
                    totalWidth: constraints.maxWidth,
                    span: cells[i].flex,
                    gap: rowGap,
                  ),
                  child: cells[i].child,
                )
              else
                Expanded(
                  flex: useExactGrid ? 1 : cells[i].flex,
                  child: cells[i].child,
                ),
            ],
          ],
        );

        if (desktopRowHeight != null) {
          return SizedBox(
            height: desktopRowHeight! * theme.scaling,
            child: row,
          );
        }
        return row;
      },
    );
  }
}

/// Standardized native `shadcn_flutter` Bento card container with optional header,
/// live `[1..5]` Shift-Hold region KeyCap badge (desktop/web only), and enlarge button.
class DyBentoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final int? regionNumber;
  final bool isZoomed;
  final VoidCallback? onToggleZoom;
  final Widget? headerTrailing;
  final Widget child;
  final EdgeInsetsGeometry? bodyPadding;
  final bool expandBody;

  const DyBentoCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.regionNumber,
    this.isZoomed = false,
    this.onToggleZoom,
    this.headerTrailing,
    this.bodyPadding,
    this.expandBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = colors.brightness == Brightness.dark;
    final padUnit = theme.density.baseContainerPadding * scaling;
    final gapUnit = theme.density.baseGap * scaling;
    final surfaceBg = DyColorSystem.resolveSurfaceCanvas(isDark);

    final effectiveZoomCallback = onToggleZoom ??
        (regionNumber != null
            ? () =>
                DyLandingCanvas.maybeOf(context)?.toggleRegion(regionNumber!)
            : null);

    final bodyContent = bodyPadding != null
        ? Padding(padding: bodyPadding!, child: child)
        : child;

    return ValueListenableBuilder<bool>(
      valueListenable: ServiceKeyboardShortcuts.instance.isTabHeldNotifier,
      builder: (context, isTabHeld, _) {
        final isTabActive = TickerMode.valuesOf(context).enabled;
        final showRegionBadge =
            !_isAndroidPlatform && isTabActive && isTabHeld && regionNumber != null;

        return shad.OutlinedContainer(
          borderColor: showRegionBadge ? colors.primary : colors.border,
          borderWidth: showRegionBadge ? 1.5 : 1.0,
          backgroundColor: colors.card,
          borderRadius: theme.borderRadiusLg,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaceBg,
                  border: Border(
                    bottom: BorderSide(color: colors.border, width: 1.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padUnit * shad.padSm,
                    vertical: gapUnit * shad.gapSm,
                  ),
                  child: Row(
                    children: [
                      if (showRegionBadge) ...[
                        DyRegionBadge(number: regionNumber!),
                        const shad.DensityGap(shad.gapSm),
                      ] else if (icon != null) ...[
                        Icon(
                          icon,
                          size: (theme.iconTheme.small.size ?? 16) * scaling,
                          color: colors.foreground,
                        ),
                        const shad.DensityGap(shad.gapSm),
                      ],
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.typography.small.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.foreground,
                                ),
                              ),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              const shad.DensityGap(shad.gapSm),
                              Flexible(
                                child: Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.xSmall.copyWith(
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (headerTrailing != null) ...[
                        const shad.DensityGap(shad.gapSm),
                        headerTrailing!,
                      ],
                      if (effectiveZoomCallback != null) ...[
                        const shad.DensityGap(shad.gapXs),
                        shad.IconButton.ghost(
                          focusNode: FocusNode(skipTraversal: true),
                          size: shad.ButtonSize.small,
                          density: shad.ButtonDensity.iconDense,
                          icon: Icon(
                            isZoomed
                                ? shad.LucideIcons.minimize2
                                : shad.LucideIcons.maximize2,
                            size: (theme.iconTheme.small.size ?? 16) * scaling,
                            color: colors.mutedForeground,
                          ),
                          onPressed: effectiveZoomCallback,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (expandBody) Expanded(child: bodyContent) else bodyContent,
            ],
          ),
        );
      },
    );
  }
}

/// Native numeric KeyCap badge shown on Bento card regions (`[1]..[5]`).
class DyRegionBadge extends StatelessWidget {
  final int number;

  const DyRegionBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final extent =
        (theme.iconTheme.medium.size ?? theme.density.baseContainerPadding) *
            theme.scaling;

    return shad.OutlinedContainer(
      width: extent,
      height: extent,
      theme: shad.OutlinedContainerTheme(
        backgroundColor: colors.primary,
        borderColor: colors.primary,
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        padding: EdgeInsets.zero,
      ),
      child: Center(
        child: Text(
          '$number',
          style: theme.typography.xSmall.merge(theme.typography.mono).copyWith(
                fontWeight: FontWeight.w700,
                height: 1.0,
                color: colors.primaryForeground,
              ),
        ),
      ),
    );
  }
}

/// Target descriptor for an enlargeable card region (`Shift 1..5`).
class DyLinearZoomTarget {
  final int regionNumber;
  final String label;
  final WidgetBuilder builder;

  const DyLinearZoomTarget({
    required this.regionNumber,
    required this.label,
    required this.builder,
  });
}

/// Single-canvas Base-12 Bento landing shell with 4 desktop regions, interactive
/// `>` region zoom (`Shift 1..4`), `[N]` Add Flow routing, and native mobile TopBar tabs.
class DyLandingCanvas extends StatefulWidget {
  final String title;
  final String? moduleName;
  final List<Widget> actions;
  final List<Widget> snapshotRows;
  final List<DyLinearZoomTarget> zoomTargets;
  final Widget Function(VoidCallback onBackToSnapshot)? addFlowBuilder;
  final List<Widget>? addActions;
  final VoidCallback? onSaveDraftAdd;
  final VoidCallback? onConfirmAdd;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;
  final VoidCallback? onAdd;
  final bool showDefaultHeaderActions;
  final bool Function(String keyChar)? onPageActionKey;
  final bool isSavingAdd;
  final bool isLoading;

  // Structured 4-Region Bento Slots
  final Widget? metricsActionBar;
  final Widget? metricsChild;
  final Widget? metricsExpandedChild;
  final Widget? dataActionBar;
  final Widget? dataChild;
  final Widget? dataExpandedChild;
  final Widget? tasksActionBar;
  final Widget? tasksChild;
  final Widget? tasksExpandedChild;
  final Widget? reportsActionBar;
  final Widget? reportsChild;
  final Widget? reportsExpandedChild;
  final int? controlledZoomedRegion;
  final ValueChanged<int?>? onZoomedRegionChanged;
  final String? mobileSubviewTitle;
  final VoidCallback? onExitMobileSubview;
  final Widget? mobileSubviewChild;
  final int dataColumnSpan;

  const DyLandingCanvas({
    super.key,
    required this.title,
    this.moduleName,
    this.actions = const [],
    this.snapshotRows = const [],
    this.zoomTargets = const [],
    this.addFlowBuilder,
    this.addActions,
    this.onSaveDraftAdd,
    this.onConfirmAdd,
    this.onPrint,
    this.onExport,
    this.onAdd,
    this.showDefaultHeaderActions = false,
    this.onPageActionKey,
    this.isSavingAdd = false,
    this.isLoading = false,
    this.metricsActionBar,
    this.metricsChild,
    this.metricsExpandedChild,
    this.dataActionBar,
    this.dataChild,
    this.dataExpandedChild,
    this.tasksActionBar,
    this.tasksChild,
    this.tasksExpandedChild,
    this.reportsActionBar,
    this.reportsChild,
    this.reportsExpandedChild,
    this.controlledZoomedRegion,
    this.onZoomedRegionChanged,
    this.mobileSubviewTitle,
    this.onExitMobileSubview,
    this.mobileSubviewChild,
    this.dataColumnSpan = DyGridSystem.flexCardsGrid,
  }) : assert(
          dataColumnSpan >= 1 && dataColumnSpan < DyGridSystem.flexBase,
          'dataColumnSpan must be between 1 and 11.',
        );

  bool get _isFourRegionMode =>
      metricsChild != null &&
      dataChild != null &&
      tasksChild != null &&
      reportsChild != null;

  static DyLandingCanvasState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<DyLandingCanvasState>();
  }

  @override
  State<DyLandingCanvas> createState() => DyLandingCanvasState();
}

class DyLandingCanvasState extends State<DyLandingCanvas> {
  int? _zoomedRegion;
  bool _isAdding = false;
  int _mobileTabIndex = 0;
  late final ModuleShortcutBinding _shortcutBinding;

  int? get _effectiveZoomedRegion =>
      widget.controlledZoomedRegion ?? _zoomedRegion;

  @override
  void initState() {
    super.initState();
    _shortcutBinding = ModuleShortcutBinding(
      isActive: () => mounted && TickerMode.valuesOf(context).enabled,
      onRegionTeleport: toggleRegion,
      onPageActionKey: _handlePageActionKey,
      onNewEntry: _handleNewEntryShortcut,
      onBackspace: _handleBackspaceShortcut,
    );
    ServiceKeyboardShortcuts.instance.registerModuleBinding(_shortcutBinding);
  }

  @override
  void dispose() {
    ServiceKeyboardShortcuts.instance.unregisterModuleBinding(_shortcutBinding);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ServiceMobileShell.instance.clear();
    });
    super.dispose();
  }

  void _syncMobileTopBar() {
    if (!widget._isFourRegionMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !TickerMode.valuesOf(context).enabled) return;
      final isPhoneWidth =
          MediaQuery.sizeOf(context).width < DyGridSystem.breakpointMobile;
      if (!isPhoneWidth) {
        ServiceMobileShell.instance.clear();
        return;
      }
      final addCallback =
          widget.onAdd ?? (widget.addFlowBuilder != null ? openAddFlow : null);
      ServiceMobileShell.instance.update(
        MobileTopBarConfig(
          tabLabels: [for (final r in DabRegion.values) r.defaultTitle],
          selectedTabIndex: _mobileTabIndex,
          onTabChanged: (idx) {
            setState(() => _mobileTabIndex = idx);
            _syncMobileTopBar();
          },
          subviewTitle: _isAdding
              ? 'Add ${widget.moduleName ?? widget.title}'
              : widget.mobileSubviewTitle,
          onBackFromSubview:
              _isAdding ? exitToSnapshot : widget.onExitMobileSubview,
          onAddPressed: addCallback,
        ),
      );
    });
  }

  bool _handlePageActionKey(String keyChar) {
    return widget.onPageActionKey?.call(keyChar) ?? false;
  }

  void _handleNewEntryShortcut() {
    if (widget.onAdd != null && !_isAdding) {
      widget.onAdd!();
      return;
    }
    if (widget.addFlowBuilder != null && !_isAdding) {
      openAddFlow();
    }
  }

  bool _handleBackspaceShortcut() {
    if (_isAdding || _effectiveZoomedRegion != null) {
      exitToSnapshot();
      return true;
    }
    return false;
  }

  void _pulseTopProgress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PageLoadingNotification(true).dispatch(context);
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted) {
          PageLoadingNotification(false).dispatch(context);
        }
      });
    });
  }

  /// Toggles enlargement for Bento region [regionNumber] (`1..5`).
  void toggleRegion(int regionNumber) {
    final targetExists = widget.zoomTargets
            .any((t) => t.regionNumber == regionNumber) ||
        (widget._isFourRegionMode && regionNumber >= 1 && regionNumber <= 4);
    if (!targetExists) return;

    final next = _effectiveZoomedRegion == regionNumber ? null : regionNumber;
    _pulseTopProgress();
    setState(() {
      _isAdding = false;
      _zoomedRegion = next;
      if (next != null && next >= 1 && next <= 4) {
        _mobileTabIndex = next - 1;
      }
    });
    widget.onZoomedRegionChanged?.call(next);
  }

  /// Enters `[N]` Add Flow mode if `addFlowBuilder` is provided.
  void openAddFlow() {
    if (widget.addFlowBuilder == null) return;
    _pulseTopProgress();
    setState(() {
      _isAdding = true;
      _zoomedRegion = null;
    });
    widget.onZoomedRegionChanged?.call(null);
  }

  /// Returns to the Landing Bento Snapshot from zoomed or Add mode.
  void exitToSnapshot() {
    if (!_isAdding && _effectiveZoomedRegion == null) return;
    _pulseTopProgress();
    setState(() {
      _isAdding = false;
      _zoomedRegion = null;
    });
    widget.onZoomedRegionChanged?.call(null);
  }

  String? _resolveActiveZoomLabel(int? regionNum) {
    if (regionNum == null) return null;
    for (final t in widget.zoomTargets) {
      if (t.regionNumber == regionNum) return t.label;
    }
    if (widget._isFourRegionMode &&
        regionNum >= 1 &&
        regionNum <= DabRegion.values.length) {
      return DabRegion.values[regionNum - 1].defaultTitle;
    }
    return null;
  }

  Widget? _resolveActiveZoomBody(BuildContext context, int? regionNum) {
    if (regionNum == null) return null;
    for (final t in widget.zoomTargets) {
      if (t.regionNumber == regionNum) {
        return KeyedSubtree(
          key: ValueKey('linear_zoom_${t.regionNumber}'),
          child: t.builder(context),
        );
      }
    }
    if (!widget._isFourRegionMode) return null;

    Widget? bar;
    Widget content;
    switch (regionNum) {
      case 1:
        bar = widget.metricsActionBar;
        content = widget.metricsExpandedChild ??
            SingleChildScrollView(child: widget.metricsChild!);
      case 2:
        bar = widget.dataActionBar;
        content = widget.dataExpandedChild ?? widget.dataChild!;
      case 3:
        bar = widget.tasksActionBar;
        content = widget.tasksExpandedChild ?? widget.tasksChild!;
      case 4:
        bar = widget.reportsActionBar;
        content = widget.reportsExpandedChild ?? widget.reportsChild!;
      default:
        return null;
    }

    return KeyedSubtree(
      key: ValueKey('linear_zoom_4reg_$regionNum'),
      child: _buildRegionPane(
        actionBar: bar,
        child: content,
        barGap: shad.gapMd,
      ),
    );
  }

  Widget _buildRegionPane({
    Widget? actionBar,
    required Widget child,
    double barGap = shad.gapMd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actionBar != null) ...[
          actionBar,
          shad.DensityGap(barGap),
        ],
        Expanded(child: child),
      ],
    );
  }

  Widget _buildDesktopFourRegionLanding(BoxConstraints constraints) {
    final theme = shad.Theme.of(context);
    final rowGap = theme.density.baseGap * theme.scaling * shad.gapMd;
    final tasksReportsSpan = DyGridSystem.flexBase - widget.dataColumnSpan;
    final rightColWidth = DyGridSystem.spanWidth(
      totalWidth: constraints.maxWidth,
      span: tasksReportsSpan,
      gap: rowGap,
    );

    final row3 = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildRegionPane(
            actionBar: widget.dataActionBar,
            child: widget.dataChild!,
          ),
        ),
        const shad.DensityGap(shad.gapMd),
        SizedBox(
          width: rightColWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: _buildRegionPane(
                  actionBar: widget.tasksActionBar,
                  child: widget.tasksChild!,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              Expanded(
                flex: 1,
                child: _buildRegionPane(
                  actionBar: widget.reportsActionBar,
                  child: widget.reportsChild!,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (constraints.maxHeight < 440) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.metricsActionBar != null) ...[
              widget.metricsActionBar!,
              const shad.DensityGap(shad.gapMd),
            ],
            widget.metricsChild!,
            const shad.DensityGap(shad.gapMd),
            SizedBox(height: 480, child: row3),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.metricsActionBar != null) ...[
          widget.metricsActionBar!,
          const shad.DensityGap(shad.gapMd),
        ],
        widget.metricsChild!,
        const shad.DensityGap(shad.gapMd),
        Expanded(child: row3),
      ],
    );
  }

  Widget _buildMobileFourRegionScaffold(BuildContext context) {
    final activeIdx = _mobileTabIndex.clamp(0, DabRegion.values.length - 1);
    final activeRegion = DabRegion.values[activeIdx];

    if (_isAdding && widget.addFlowBuilder != null) {
      return widget.addFlowBuilder!(exitToSnapshot);
    }

    if (widget.mobileSubviewChild != null) {
      return widget.mobileSubviewChild!;
    }

    final Widget activeBar;
    final Widget activeContent;
    switch (activeRegion) {
      case DabRegion.metrics:
        activeBar = widget.metricsActionBar ?? const SizedBox.shrink();
        activeContent = widget.metricsExpandedChild ??
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: widget.metricsChild!,
            );
      case DabRegion.data:
        activeBar = widget.dataActionBar ?? const SizedBox.shrink();
        activeContent = widget.dataChild!;
      case DabRegion.tasks:
        activeBar = widget.tasksActionBar ?? const SizedBox.shrink();
        activeContent = widget.tasksExpandedChild ?? widget.tasksChild!;
      case DabRegion.reports:
        activeBar = widget.reportsActionBar ?? const SizedBox.shrink();
        activeContent = widget.reportsExpandedChild ?? widget.reportsChild!;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: KeyedSubtree(
        key: ValueKey('mobile_tab_${activeRegion.name}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activeBar is! SizedBox) ...[
              activeBar,
              const shad.DensityGap(shad.gapMd),
            ],
            Expanded(child: activeContent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final activeZoomNum = _effectiveZoomedRegion;
    final activeZoomLabel = _resolveActiveZoomLabel(activeZoomNum);
    final isZoomed = activeZoomLabel != null;

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final isMobile =
            outerConstraints.maxWidth < DyGridSystem.breakpointMobile;

        _syncMobileTopBar();

        if (isMobile && widget._isFourRegionMode) {
          return _buildMobileFourRegionScaffold(context);
        }

        final Widget header = _isAdding
            ? PageHeader(
                title: widget.title,
                moduleName: widget.moduleName,
                mode: PageHeaderMode.adding,
                onBack: exitToSnapshot,
                onDiscard: exitToSnapshot,
                onSaveDraft: widget.onSaveDraftAdd,
                onConfirm: widget.onConfirmAdd,
                isSaving: widget.isSavingAdd,
                actions: widget.addActions ?? const [],
              )
            : PageHeader(
                title: widget.title,
                mode: PageHeaderMode.standard,
                breadcrumbSubtitle: activeZoomLabel,
                onBreadcrumbRootTap: isZoomed ? exitToSnapshot : null,
                onBack: isZoomed ? exitToSnapshot : null,
                onPrint: widget.onPrint,
                onExport: widget.onExport,
                onAdd: widget.onAdd ??
                    (widget.addFlowBuilder != null ? openAddFlow : null),
                showDefaultStandardActions: widget.showDefaultHeaderActions,
                actions: widget.actions,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const shad.DensityGap(shad.gapLg),
            Expanded(
              child: LayoutBuilder(
                builder: (context, bodyConstraints) {
                  final Widget body;
                  if (_isAdding && widget.addFlowBuilder != null) {
                    body = KeyedSubtree(
                      key: const ValueKey('linear_add_flow'),
                      child: widget.addFlowBuilder!(exitToSnapshot),
                    );
                  } else if (isZoomed) {
                    body = _resolveActiveZoomBody(context, activeZoomNum) ??
                        const SizedBox.shrink();
                  } else if (widget._isFourRegionMode) {
                    body = KeyedSubtree(
                      key: const ValueKey('linear_4region_snapshot'),
                      child: _buildDesktopFourRegionLanding(bodyConstraints),
                    );
                  } else {
                    body = KeyedSubtree(
                      key: const ValueKey('linear_bento_snapshot'),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: theme.density.baseContainerPadding *
                              theme.scaling *
                              shad.padMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < widget.snapshotRows.length; i++) ...[
                              if (i > 0) const shad.DensityGap(shad.gapMd),
                              widget.snapshotRows[i],
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: body,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
