/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC CONTENT PANE (dynamic_content_pane.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Surface card container for master-detail split views and detail inspection canvases.
   - Encapsulates a sticky top header bar, flexible scrollable child body, and
     sticky summary footer bar matching DynamicDenseTable (DDT) header/footer specs 100%.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Sticky header (10 * theme.scaling vertical) & footer (15 * theme.scaling vertical) match DDT header/footer specs.
   - Title uses `h4` bold typography token.
   - Header actions support 1 mandatory `primaryAction` + up to 2 optional secondary actions (`secondaryAction1`, `secondaryAction2`).
   - Body renders inside a `SingleChildScrollView` surface card container.
   - Uses native `shadcn_flutter` color tokens (`colors.card`, `colors.border`, `theme.radiusMd`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [DynamicContentPane] — Page-level Content Surface Container with DDT-matched Header & Footer.
class DynamicContentPane extends StatelessWidget {
  final String title;
  final Widget primaryAction;
  final Widget? secondaryAction1;
  final Widget? secondaryAction2;
  final Widget? statusBadge;
  final Widget? headerLeading;
  final Color? headerBackgroundColor;

  // Body Prop
  final Widget child;

  // Footer Props
  final Widget? footerLeading;
  final Widget? footerAction;

  const DynamicContentPane({
    super.key,
    required this.title,
    required this.primaryAction,
    required this.child,
    this.secondaryAction1,
    this.secondaryAction2,
    this.statusBadge,
    this.headerLeading,
    this.headerBackgroundColor,
    this.footerLeading,
    this.footerAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = colors.brightness == Brightness.dark;
    final defaultHeaderFooterBg = isDark ? const Color(0xFF141210) : const Color(0xFFFCFDFE);
    final headerBg = headerBackgroundColor ?? defaultHeaderFooterBg;

    return Expanded(
      child: shad.OutlinedContainer(
        borderColor: colors.border,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        backgroundColor: colors.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. STICKY HEADER (Matches DynamicDenseTable Header: 16px horizontal / 10px vertical)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * theme.scaling,
                vertical: 10 * theme.scaling,
              ),
              color: headerBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (headerLeading != null) ...[
                    headerLeading!,
                    SizedBox(width: 8 * theme.scaling),
                  ],
                  Text(
                    title,
                    style: theme.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.foreground,
                    ),
                  ),
                  if (statusBadge != null) ...[
                    SizedBox(width: 8 * theme.scaling),
                    statusBadge!,
                  ],
                  const Spacer(),
                  if (secondaryAction1 != null) ...[
                    secondaryAction1!,
                    SizedBox(width: 8 * theme.scaling),
                  ],
                  if (secondaryAction2 != null) ...[
                    secondaryAction2!,
                    SizedBox(width: 8 * theme.scaling),
                  ],
                  primaryAction,
                ],
              ),
            ),

            shad.Divider(color: colors.border),

            // 2. SCROLLABLE CONTENT BODY (SingleChildScrollView surface card child)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
                child: child,
              ),
            ),

            shad.Divider(color: colors.border),

            // 3. STICKY FOOTER (Text-only child footer: 16px horizontal / 15px vertical, 50px total height matching DL 52px baseline)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * theme.scaling,
                vertical: 15 * theme.scaling,
              ),
              color: defaultHeaderFooterBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  footerLeading ??
                      Text(
                        '1 Selected • Total Investment: ₹0.00',
                        style: theme.typography.textSmall.copyWith(
                          color: colors.foreground,
                        ),
                      ),
                  const Spacer(),
                  if (footerAction != null) footerAction!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
