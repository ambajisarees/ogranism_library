/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES WORKSTATION LANDING SCREEN (scr_sales_landing.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Primary landing workstation container for Sales module (`sales` / `so`).
   - Conforms 100% to DyPageCanvas 4-Shell Architecture (`Dash`, `Details`, `Reports`, `Tasks`).
   - Defaults immediately to subpage index 2 (`Reports`) to spotlight the Master Customer
     invoice grouping and haste analysis focus report.
   - Details shell (index 1) is left cleanly blank for future phase per user request.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Target Schemas/Tables: `IMMBE2627.sq_BILLS` (Series S1) and `IMMBE2627.sq_BILLDET`.
   - 4-Shell Integration:
     * Dash: `DyShlDash(title: 'Sales')`
     * Details: Placeholder state (per specification)
     * Reports: `ScrSalesReportPane` (9-column master customer grouped report)
     * Tasks: `DyShlTasks()`

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - No forced `< 100000` filter to encompass the full ~11k+ historical/active S1 dataset.
   - Strict adherence to native `shadcn_flutter` component tokens and layout rules.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../dynamic_ai/page/dy_page_header.dart';
import '../../dynamic_ai/shells/dy_shl_dash.dart';
import '../../dynamic_ai/shells/dy_shl_tasks.dart';
import '../../dynamic_ai/shells/dy_page_canvas.dart';
import 'scr_sales_report_pane.dart';

/// [ScrSalesLanding] — Main Landing Container Screen for the Sales module.
class ScrSalesLanding extends StatefulWidget {
  const ScrSalesLanding({super.key});

  @override
  State<ScrSalesLanding> createState() => _ScrSalesLandingState();
}

class _ScrSalesLandingState extends State<ScrSalesLanding> {
  // Navigation & Subpage State (Default to Reports = index 2 per user focus)
  int _contextTabIndex = 2;

  @override
  Widget build(BuildContext context) {
    return DyPageCanvas(
      header: PageHeader(
        title: 'Sales & Invoices',
        actions: [
          shad.OutlineButton(
            onPressed: () {
              shad.showToast(
                context: context,
                builder: (context, show) => const shad.Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Printing / Exporting sales report...'),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.printer, size: 14),
                shad.DensityGap(shad.gapSm),
                Text('Print / Export'),
              ],
            ),
          ),
        ],
        subpages: PageSubpages(
          selectedIndex: _contextTabIndex,
          labels: const ['Dash', 'Details', 'Reports', 'Tasks'],
          onSubpageChanged: (idx) {
            setState(() {
              _contextTabIndex = idx;
            });
          },
        ),
      ),
      subpageIndex: _contextTabIndex,
      subpageContents: [
        const DyShlDash(title: 'Sales'),
        _buildBlankDetailsPlaceholder(),
        const ScrSalesReportPane(),
        const DyShlTasks(),
      ],
    );
  }

  /// Blank placeholder for Details subpage as explicitly requested.
  Widget _buildBlankDetailsPlaceholder() {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: shad.Card(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: EdgeInsets.all(32 * theme.scaling),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shad.LucideIcons.fileSpreadsheet,
                size: 48 * theme.scaling,
                color: colors.primary,
              ),
              const shad.DensityGap(shad.gapMd),
              Text(
                'Sales Details Canvas',
                style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              const shad.DensityGap(shad.gapSm),
              Text(
                'The transactional line-item details canvas is currently blank for this phase. Please switch to the "Reports" subpage above to view the Master Customer sales breakdown.',
                textAlign: TextAlign.center,
                style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
              ),
              const shad.DensityGap(shad.gapLg),
              shad.PrimaryButton(
                onPressed: () {
                  setState(() {
                    _contextTabIndex = 2; // Jump to Reports
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(shad.LucideIcons.chartColumn, size: 16),
                    shad.DensityGap(shad.gapSm),
                    Text('Go to Reports Page'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
