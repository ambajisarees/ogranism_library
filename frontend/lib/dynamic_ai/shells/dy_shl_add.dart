/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC ADD FORM SHELL (dy_shl_add.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dedicated Add/Edit creation body shell layout sitting directly below PageHeader in DyPageCanvas.
   - Enforces 2-row workspace architecture:
     - Row 1 (Expanded Vertical Height):
       - Flex 7 Left Column: DAB (fixed height) + Table Workspace (Expanded, internal scroll).
       - Flex 3 Right Column: Single Form Workspace (Expanded, internal SingleChildScrollView).
     - Row 2 (Fixed 160px Height): Summary Bar (Full width).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - PageHeader is owned 100% by DyPageCanvas at top in form mode.
   - Table Workspace (Flex 7): Scrollable table engine for line items input.
   - Form Workspace (Flex 3): Scrollable form section pane (`DyFormSection` cards).
   - Bottom Summary Bar: Fixed 160px height summary component.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DyShlAdd] — Add/Edit Form Body Shell Layout sitting below PageHeader in DyPageCanvas.
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
    this.leftFlex = 7,
    this.rightFlex = 3,
    this.summaryHeight = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. ROW 1: SPLIT WORKSPACE (Expanded Vertical Height)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FLEX 7 COLUMN: DAB + TABLE WORKSPACE (Internal Scroll)
              Expanded(
                flex: leftFlex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (actionBar != null) ...[
                      actionBar!,
                      const shad.DensityGap(shad.gapMd),
                    ],
                    Expanded(child: tableWorkspace),
                  ],
                ),
              ),

              const shad.DensityGap(shad.gapLg),

              // FLEX 3 COLUMN: SINGLE UNIFIED FORM (Top Aligned with Table Header)
              Expanded(
                flex: rightFlex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (actionBar != null) ...[
                      SizedBox(height: 34.0 * theme.scaling),
                      const shad.DensityGap(shad.gapMd),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: formWorkspace,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. ROW 2: BOTTOM SUMMARY BAR (Fixed 160px Height, Full Width)
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
