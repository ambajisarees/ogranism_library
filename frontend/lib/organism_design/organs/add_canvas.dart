import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';

/// [OrganAddCanvas] — The specialized "Creation" overlay for the ERP.
///
/// Version 2.0: High-Density Workstation Layout.
/// Featured in large creation sheets where rapid data entry is the priority.
/// Supports a secondary meta-header [subHeader] and primary [trailingAction].
class OrganAddCanvas extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final List<Widget> children;
  
  /// A secondary row of metadata directly below the title (e.g., VNO, Date).
  final Widget? subHeader;
  
  /// The primary action in the header (e.g., "Confirm" or "Save").
  final Widget? trailingAction;
  
  /// Optional sticky footer for primary bulk actions.
  final Widget? footer;
  
  /// Additional actions in the header row.
  final List<Widget> headerActions;
  
  const OrganAddCanvas({
    super.key,
    required this.title,
    required this.onClose,
    required this.children,
    this.subHeader,
    this.trailingAction,
    this.footer,
    this.headerActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(OrganismTheme.radiusLg),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        children: [
          // ── STICKY HEADER ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OrganismTheme.spacingMd,
              vertical: OrganismTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Destructive Discard Action (Red)
                    CellButton(
                      icon: LucideIcons.x,
                      variant: CellButtonVariant.destructive,
                      isCompact: true,
                      onPressed: onClose,
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: Text(
                        title,
                        style: OrganismTheme.titleLarge(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Header Actions
                    if (headerActions.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: headerActions
                            .map((a) => Padding(
                                  padding: const EdgeInsets.only(left: OrganismTheme.spacingSm),
                                  child: a,
                                ))
                            .toList(),
                      ),
                    // Primary Confirm Action
                    if (trailingAction != null) ...[
                       const SizedBox(width: OrganismTheme.spacingMd),
                       trailingAction!,
                    ],
                  ],
                ),
                
                // Secondary Sub-Header (Page Meta Fields)
                if (subHeader != null) ...[
                  const SizedBox(height: OrganismTheme.spacingMd),
                  const CellDivider(),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  subHeader!,
                ],
              ],
            ),
          ),

          // ── SCROLLABLE SECTIONS (FLAT LAYOUT) ───────────────────────
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: OrganismTheme.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return children[index];
                      },
                      childCount: children.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── STICKY FOOTER ──────────────────────────────────────────
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(OrganismTheme.spacingMd),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}
