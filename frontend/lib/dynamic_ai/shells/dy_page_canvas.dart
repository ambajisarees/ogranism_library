/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC PAGE CANVAS (dy_page_canvas.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Synchronized page-level container framing PageHeader AND Page Content.
   - Guarantees Header and Content boundaries are 100% aligned in all layout modes:
     - landing: Flex 12 (100% full container width).
     - form: Flex 10 (Centered with 1 empty flex unit on each side).
     - focus: Flex 8 (Centered with 2 empty flex units on each side).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Encapsulates AnimatedSwitcher (150ms cross-fade transition) for zero-shift subpage transitions.
   - Supports passing either direct `content` OR a `subpageContents` list with `subpageIndex`.
   - Enforces strict native token rules (gapMd = 12px, gapLg = 16px, zero ad-hoc container wrappers).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Layout mode for [DyPageCanvas]
enum DyPageLayoutMode {
  landing, // Flex 12 (100% full width)
  form,    // Flex 10 (Centered with 1 flex margin on each side)
  focus,   // Flex 8 (Centered with 2 flex margins on each side)
}

/// [DyPageCanvas] — Synchronized Page Layout Coordinator.
/// Aligns PageHeader and Page Content to the exact same flex grid boundaries
/// and handles 150ms AnimatedSwitcher cross-fade subpage transitions natively.
class DyPageCanvas extends StatelessWidget {
  final Widget header;
  final Widget content;
  final List<Widget>? subpageContents;
  final int? subpageIndex;
  final DyPageLayoutMode layoutMode;

  const DyPageCanvas({
    super.key,
    required this.header,
    this.content = const SizedBox.shrink(),
    this.subpageContents,
    this.subpageIndex,
    this.layoutMode = DyPageLayoutMode.landing,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve active content: either subpageContents switcher or direct content
    Widget activeContent = content;
    if (subpageContents != null && subpageContents!.isNotEmpty) {
      final int activeIdx = (subpageIndex ?? 0).clamp(0, subpageContents!.length - 1);
      activeContent = AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(activeIdx),
          child: subpageContents![activeIdx],
        ),
      );
    }

    if (layoutMode == DyPageLayoutMode.landing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const shad.DensityGap(shad.gapLg),
          Expanded(child: activeContent),
        ],
      );
    }

    final int contentFlex = layoutMode == DyPageLayoutMode.form ? 10 : 8;
    final int marginFlex = (12 - contentFlex) ~/ 2;

    return Row(
      children: [
        if (marginFlex > 0) Expanded(flex: marginFlex, child: const SizedBox.shrink()),
        Expanded(
          flex: contentFlex,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const shad.DensityGap(shad.gapMd),
              Expanded(child: activeContent),
            ],
          ),
        ),
        if (marginFlex > 0) Expanded(flex: marginFlex, child: const SizedBox.shrink()),
      ],
    );
  }
}
