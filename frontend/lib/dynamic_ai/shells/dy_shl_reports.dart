/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC REPORTS SHELL (dy_shl_reports.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Analytical reports & summary table page shell layout.
   - Provides reporting filters, summary metric counters, and export buttons.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Displays summary totals bar (Total Meters, Fresh Pcs, Fent Wt, Shortage %).
   - Displays printable report data table surface.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../specs/dy_color_system.dart';

/// [DyShlReports] — Page Shell Layout for Module Reports & Summaries.
class DyShlReports extends StatelessWidget {
  final String title;

  const DyShlReports({
    super.key,
    this.title = 'Module Reports',
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    final surfaceBg = DyColorSystem.resolveSurfaceCanvas(isDark);

    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      backgroundColor: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. REPORT TOOLBAR & SUMMARY HEADER
          Container(
            padding: EdgeInsets.all(14 * theme.scaling),
            color: surfaceBg,
            child: Row(
              children: [
                Icon(shad.LucideIcons.fileSpreadsheet, size: 18 * theme.scaling, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Audit & Pendency Summary Report',
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shad.LucideIcons.download, size: 14 * theme.scaling),
                      const SizedBox(width: 6),
                      const Text('Export CSV'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                shad.PrimaryButton(
                  size: shad.ButtonSize.small,
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shad.LucideIcons.printer, size: 14 * theme.scaling),
                      const SizedBox(width: 6),
                      const Text('Print Report'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const shad.Divider(),

          // 2. REPORT CONTENT TABLE SURFACE
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * theme.scaling),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildReportRow(theme, colors, 'Ambaji Silks & Textiles', '10481', '4,850 Mts', '₹8,73,000', '98.5%'),
                  const shad.Divider(),
                  _buildReportRow(theme, colors, 'Vardhman Synthetics Surat', '10482', '3,200 Mts', '₹5,76,000', '96.2%'),
                  const shad.Divider(),
                  _buildReportRow(theme, colors, 'Kothari Weavers', '10483', '6,100 Mts', '₹10,98,000', '99.1%'),
                  const shad.Divider(),
                  _buildReportRow(theme, colors, 'Laxmi Digital Prints', '10484', '2,950 Mts', '₹5,31,000', '94.8%'),
                  const shad.Divider(),
                  _buildReportRow(theme, colors, 'Shree Ram Rayon Mills', '10485', '5,400 Mts', '₹9,72,000', '97.6%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String weaver,
    String vno,
    String qty,
    String amt,
    String recovery,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * theme.scaling),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              weaver,
              style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Lot #$vno',
              style: theme.typography.mono.copyWith(fontSize: 12 * theme.scaling),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              qty,
              style: theme.typography.mono.copyWith(fontSize: 12.5 * theme.scaling, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amt,
              style: theme.typography.mono.copyWith(fontSize: 12.5 * theme.scaling, fontWeight: FontWeight.bold, color: colors.primary),
            ),
          ),
          Expanded(
            flex: 1,
            child: shad.SecondaryBadge(
              child: Text(
                recovery,
                style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
