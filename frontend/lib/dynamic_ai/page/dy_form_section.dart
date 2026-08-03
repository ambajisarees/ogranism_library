/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC FORM SECTION (dy_form_section.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Modular 12-column responsive form card container for Add/Edit workflows.
   - Pinned 36px sticky header matching DynamicContentPane & DyTableHeader specs.
   - Houses N number of form elements (TextField, AutoComplete, Checkbox, Select, etc.).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Sticky Header: 36px height, `DyColorSystem.resolveSurfaceCanvas(isDark)` background,
     1px `colors.border` bottom line, standard `h4` typography.
   - Grid Body: `padSm` container padding (16px scaled), `gapSm` row & column spacing (8px).
   - 12-Column Flex Grid: Each `DyFormField` specifies `colSpan` (1 to 12).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../specs/dy_color_system.dart';

/// Field specification for [DyFormSection] holding a widget child and 12-column grid span.
class DyFormField {
  final Widget child;
  final int colSpan; // 1 to 12 (default 6 for half-width, 12 for full-width)

  const DyFormField({
    required this.child,
    this.colSpan = 6,
  }) : assert(colSpan >= 1 && colSpan <= 12, 'colSpan must be between 1 and 12');
}

/// [DyFormSection] — 12-Column Responsive Form Card Component.
class DyFormSection extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final Widget? trailing;
  final List<DyFormField> fields;
  final EdgeInsetsGeometry? padding;

  const DyFormSection({
    super.key,
    required this.title,
    this.leadingIcon,
    this.trailing,
    required this.fields,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    // Header Background token compliant with DyColorSystem surface canvas
    final headerBg = DyColorSystem.resolveSurfaceCanvas(isDark);

    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      clipBehavior: Clip.antiAlias,
      backgroundColor: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. PINNED 36px STICKY HEADER
          Container(
            height: 36 * theme.scaling,
            padding: EdgeInsets.symmetric(horizontal: 16 * theme.scaling),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(
                bottom: BorderSide(color: colors.border, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    size: 16 * theme.scaling,
                    color: colors.primary,
                  ),
                  const shad.DensityGap(shad.gapSm),
                ],
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // 2. 12-COLUMN RESPONSIVE FORM GRID BODY (padSm padding, gapSm row/col gaps)
          Padding(
            padding: padding ?? EdgeInsets.all(16 * theme.scaling),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final double gap = 8 * theme.scaling; // gapSm baseline = 8px

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: fields.map((field) {
                    // Calculate exact item width based on 12-column span
                    final double itemWidth = field.colSpan == 12
                        ? availableWidth
                        : ((availableWidth - gap) * (field.colSpan / 12.0)).clamp(0.0, availableWidth);

                    return SizedBox(
                      width: itemWidth,
                      child: field.child,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
