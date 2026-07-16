import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells.dart';

/// [OrganSectionCanvas] — The unified detail view experience for the ERP.
///
/// Presents the entire detail view as a SINGLE, full-height card floating 
/// on the canvas with 16px padding. 
///   • Header is sticky and pinned to the top of the card.
///   • Tabs are integrated directly below the title.
///   • Content sections are separated by dividers within the same card.
///   • CARD is slightly elevated using shadowMd.
class OrganSectionCanvas extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget? tabs;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const OrganSectionCanvas({
    super.key,
    required this.title,
    this.actions = const [],
    this.tabs,
    required this.children,
    this.padding = const EdgeInsets.all(OrganismTheme.spacingMd),
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      color: colors.surfaceSubtle, 
      padding: padding, 
      child: Container(
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
        child: CustomScrollView(
          slivers: [
            // ── STICKY HEADER ──────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _SectionCanvasHeaderDelegate(
                title: title,
                actions: actions,
                tabs: tabs,
                colors: colors,
              ),
            ),

            // ── SCROLLABLE SECTIONS ─────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final isLast = index == children.length - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      children[index],
                      if (!isLast) const CellDivider(),
                    ],
                  );
                },
                childCount: children.length,
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: OrganismTheme.spacingLg),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCanvasHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final List<Widget> actions;
  final Widget? tabs;
  final OrganismColors colors;

  _SectionCanvasHeaderDelegate({
    required this.title,
    required this.actions,
    this.tabs,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
           bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: OrganismTheme.titleLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
          if (tabs != null) ...[
            const SizedBox(height: OrganismTheme.spacingSm),
            SizedBox(
              height: 40.0,
              child: tabs!,
            ),
          ],
        ],
      ),
    );
  }

  @override
  double get maxExtent => tabs != null ? 128.0 : 88.0;

  @override
  double get minExtent => tabs != null ? 128.0 : 88.0;

  @override
  bool shouldRebuild(covariant _SectionCanvasHeaderDelegate oldDelegate) {
    return oldDelegate.title != title || 
           oldDelegate.actions != actions ||
           oldDelegate.tabs != tabs;
  }
}
