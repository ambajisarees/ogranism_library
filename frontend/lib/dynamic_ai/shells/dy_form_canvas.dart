/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC FORM CANVAS SHELL (dy_form_canvas.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Unified modular Base-12 form shell (`DyFormCanvas`), standardized labeled
     field wrapper (`DyFormLabeledField`), and split transactional entry shell
     (`DyShlAdd`, migrated cleanly from legacy `dy_shl_add.dart`).
   - Powers both Master Add/Edit flows (`9 : 3` multi-section canvas + right
     context/readiness inspector, e.g. `ScrPtyForm`) and split line-item creation
     workspaces (`ScrCcForm`, `JwAddChallanView`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Desktop (`>= 1024px`) splits `mainSections` and `sideSections` using
     gap-compensated `DyGridSystem.spanWidth` (`mainColumnSpan`, default `9` : `3`),
     matching the top KPI grid alignment pixel-for-pixel.
   - Tablet/Mobile (`< 1024px`) stacks `mainSections` cleanly above `sideSections`
     inside one vertical `SingleChildScrollView`.
   - Zero hardcoded Material chrome; strictly uses `shadcn_flutter` theme tokens,
     `theme.typography.*`, `theme.density.*`, and `shad.DensityGap`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - When `sideSections` is empty, `mainSections` expands across the full 12-column
     canvas width automatically.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future enhancement: unsaved-dirty-state guard callback integrated with
     `DyLandingCanvas.onExitAddFlow`.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../specs/dy_grid_system.dart';

/// Standardized labeled form control wrapper enforcing native `shadcn_flutter`
/// typography, density spacing, required marker, and helper text.
class DyFormLabeledField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final Widget? trailingLabel;
  final Widget child;

  const DyFormLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.helperText,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: ' *',
                        style: theme.typography.xSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.destructive,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingLabel != null) ...[
              const shad.DensityGap(shad.gapXs),
              trailingLabel!,
            ],
          ],
        ),
        const shad.DensityGap(shad.gapXs),
        child,
        if (helperText != null && helperText!.isNotEmpty) ...[
          const shad.DensityGap(shad.gapXs),
          Text(
            helperText!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}

/// Base-12 Bento Form Canvas (`DyFormCanvas`) supporting a primary multi-section
/// column (`mainSections`), an optional right context/checklist column
/// (`sideSections`), and an optional footer bar (`bottomSummaryBar`).
class DyFormCanvas extends StatelessWidget {
  final List<Widget> mainSections;
  final List<Widget> sideSections;
  final int mainColumnSpan;
  final Widget? bottomSummaryBar;
  final double summaryHeight;
  final double verticalPadding;

  const DyFormCanvas({
    super.key,
    required this.mainSections,
    this.sideSections = const [],
    this.mainColumnSpan = DyGridSystem.flexCardsGrid,
    this.bottomSummaryBar,
    this.summaryHeight = 88.0,
    this.verticalPadding = 16.0,
  }) : assert(
          mainColumnSpan >= 1 && mainColumnSpan <= DyGridSystem.flexBase,
          'mainColumnSpan must be between 1 and 12.',
        );

  Widget _buildStackedList(List<Widget> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          if (i > 0) const shad.DensityGap(shad.gapMd),
          sections[i],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final gapMdPx = theme.density.baseGap * theme.scaling * shad.gapMd;
    final hasSide =
        sideSections.isNotEmpty && mainColumnSpan < DyGridSystem.flexBase;

    final formBody = LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < DyGridSystem.breakpointTablet;

        if (!hasSide || isCompact) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: verticalPadding * theme.scaling),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStackedList(mainSections),
                if (hasSide) ...[
                  const shad.DensityGap(shad.gapMd),
                  _buildStackedList(sideSections),
                ],
              ],
            ),
          );
        }

        final sideSpan = DyGridSystem.flexBase - mainColumnSpan;
        final sideWidth = DyGridSystem.spanWidth(
          totalWidth: constraints.maxWidth,
          span: sideSpan,
          gap: gapMdPx,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(bottom: verticalPadding * theme.scaling),
                child: _buildStackedList(mainSections),
              ),
            ),
            const shad.DensityGap(shad.gapMd),
            SizedBox(
              width: sideWidth,
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(bottom: verticalPadding * theme.scaling),
                child: _buildStackedList(sideSections),
              ),
            ),
          ],
        );
      },
    );

    if (bottomSummaryBar == null) return formBody;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: formBody),
        const shad.DensityGap(shad.gapMd),
        SizedBox(
          height: summaryHeight * theme.scaling,
          child: bottomSummaryBar!,
        ),
      ],
    );
  }
}

/// Split transactional line-item + header-form workspace layout (`DyShlAdd`)
/// used by multi-line entry workspaces (`ScrCcForm`, `JwAddChallanView`).
class DyShlAdd extends StatelessWidget {
  final Widget? actionBar;
  final Widget tableWorkspace;
  final Widget formWorkspace;
  final Widget? summaryBar;
  final int leftFlex;
  final int rightFlex;
  final double summaryHeight;

  const DyShlAdd({
    super.key,
    this.actionBar,
    this.tableWorkspace = const SizedBox.shrink(),
    this.formWorkspace = const SizedBox.shrink(),
    this.summaryBar,
    this.leftFlex = DyGridSystem.flexCardsGrid,
    this.rightFlex = DyGridSystem.flexCardsInspector,
    this.summaryHeight = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final gapMdPx = theme.density.baseGap * theme.scaling * shad.gapMd;

    final leftCol = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actionBar != null) ...[
          actionBar!,
          const shad.DensityGap(shad.gapMd),
        ],
        Expanded(child: tableWorkspace),
      ],
    );

    final rightCol = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actionBar != null) ...[
          SizedBox(height: 36.0 * theme.scaling),
          const shad.DensityGap(shad.gapMd),
        ],
        Expanded(
          child: SingleChildScrollView(
            child: formWorkspace,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useExactGrid =
                  (leftFlex + rightFlex == DyGridSystem.flexBase) &&
                      rightFlex >= 1 &&
                      rightFlex < DyGridSystem.flexBase &&
                      constraints.maxWidth >= DyGridSystem.breakpointTablet;

              if (useExactGrid) {
                final rightWidth = DyGridSystem.spanWidth(
                  totalWidth: constraints.maxWidth,
                  span: rightFlex,
                  gap: gapMdPx,
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: leftCol),
                    const shad.DensityGap(shad.gapMd),
                    SizedBox(width: rightWidth, child: rightCol),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: leftFlex, child: leftCol),
                  const shad.DensityGap(shad.gapMd),
                  Expanded(flex: rightFlex, child: rightCol),
                ],
              );
            },
          ),
        ),
        if (summaryBar != null) ...[
          const shad.DensityGap(shad.gapMd),
          SizedBox(
            height: summaryHeight * theme.scaling,
            child: summaryBar!,
          ),
        ],
      ],
    );
  }
}
