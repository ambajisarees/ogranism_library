import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells.dart';

/// [OrganSectionCanvas] — The unified detail view experience for the ERP.
///
/// Presents the entire detail view as a SINGLE, full-height card floating
/// on the canvas with 24px outer padding. Pins the header (with optional sub-headers
/// and badges) at the top, followed by a divider, and an expanded scrollable body.
class OrganSectionCanvas extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget? headerBadge;
  final Widget? subHeader;
  final Widget? tabs;
  final Widget? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const OrganSectionCanvas({
    super.key,
    required this.title,
    this.actions = const [],
    this.headerBadge,
    this.subHeader,
    this.tabs,
    this.footer,
    required this.children,
    this.padding = const EdgeInsets.all(OrganismTheme.spacingLg),
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      color: colors.surfaceSubtle,
      padding: const EdgeInsets.all(OrganismTheme.spacingLg), // High-density desktop outer margins
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(OrganismTheme.radiusMd), // Sharp, clean MD borders
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.04), // Clean low-opacity shadow
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. PINNED HEADER (Architecture from Cutting Cards) ──────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                OrganismTheme.spacingLg,
                OrganismTheme.spacingLg,
                OrganismTheme.spacingLg,
                OrganismTheme.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: OrganismTheme.titleLarge(context).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (headerBadge != null) ...[
                              const SizedBox(width: 12),
                              headerBadge!,
                            ],
                          ],
                        ),
                      ),
                      if (actions.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions
                              .map((a) => Padding(
                                    padding: const EdgeInsets.only(left: OrganismTheme.spacingSm),
                                    child: a,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                  if (subHeader != null) ...[
                    const SizedBox(height: OrganismTheme.spacingMd),
                    subHeader!,
                  ],
                  if (tabs != null) ...[
                    const SizedBox(height: OrganismTheme.spacingSm),
                    SizedBox(
                      height: 40.0,
                      child: tabs!,
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: colors.border, height: 1, thickness: 1),

            // ── 2. SCROLLABLE BODY ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < children.length; i++) ...[
                      children[i],
                      if (i < children.length - 1) ...[
                        const SizedBox(height: OrganismTheme.spacingLg),
                        const CellDivider(),
                        const SizedBox(height: OrganismTheme.spacingLg),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // ── 3. PINNED FOOTER (Architecture from Cutting Cards) ──────────
            if (footer != null) ...[
              Divider(color: colors.border, height: 1, thickness: 1),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OrganismTheme.spacingLg,
                  vertical: OrganismTheme.spacingMd,
                ),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
