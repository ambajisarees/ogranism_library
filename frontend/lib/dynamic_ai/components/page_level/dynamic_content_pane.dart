/// LLM NOTE: DynamicContentPane
/// - Level: Page-Level Content Container
/// - Purpose: Surface card container with sticky header bar, flexible child body area, and optional sticky summary footer.
/// - Widget Composition: Expanded -> shad.OutlinedContainer -> Column(Sticky Header Container + Body Expanded(child) + Sticky Footer Container).
/// - Tokens: Uses colors.card background, colors.border, and radiusMd.

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicContentPane extends StatelessWidget {
  // Header Props (Mandatory: title + primaryAction)
  final String title;
  final Widget primaryAction;
  final Widget? statusBadge;
  final List<Widget>? toolbarActions;
  final Widget? headerLeading;

  // Body Prop (Generic Child)
  final Widget child;

  // Footer Props (Optional: summary leading + footer action)
  final Widget? footerLeading;
  final Widget? footerAction;

  // Loading state
  final bool isLoading;

  const DynamicContentPane({
    super.key,
    required this.title,
    required this.primaryAction,
    required this.child,
    this.statusBadge,
    this.toolbarActions,
    this.headerLeading,
    this.footerLeading,
    this.footerAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final headerFooterBg = isDark ? const Color(0xFF141210) : const Color(0xFFFCFDFE);

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
            // 1. Sticky Header (Dense Table Header Padding: horizontal 16, vertical 10)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: headerFooterBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (headerLeading != null) ...[
                    headerLeading!,
                    const SizedBox(width: 8),
                  ],
                  isLoading
                      ? const _SkeletonBox(width: 120, height: 18)
                      : Text(
                          title,
                          style: theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                  if (statusBadge != null && !isLoading) ...[
                    const SizedBox(width: 8),
                    statusBadge!,
                  ],
                  const Spacer(),
                  if (!isLoading && toolbarActions != null && toolbarActions!.isNotEmpty) ...[
                    ...toolbarActions!,
                    const SizedBox(width: 8),
                  ],
                  isLoading
                      ? const _SkeletonBox(width: 60, height: 24)
                      : primaryAction,
                ],
              ),
            ),

            const shad.Divider(),

            // 2. Middle Scrollable Content Area (Generic Page Child or Skeleton)
            Expanded(
              child: isLoading
                  ? SingleChildScrollView(
                      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _SkeletonBox(height: 50, borderRadius: BorderRadius.circular(theme.radiusMd))),
                              const SizedBox(width: 12),
                              Expanded(child: _SkeletonBox(height: 50, borderRadius: BorderRadius.circular(theme.radiusMd))),
                              const SizedBox(width: 12),
                              Expanded(child: _SkeletonBox(height: 50, borderRadius: BorderRadius.circular(theme.radiusMd))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SkeletonBox(height: 240, borderRadius: BorderRadius.circular(theme.radiusMd)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padMd),
                      child: child,
                    ),
            ),

            if (isLoading || footerLeading != null || footerAction != null) ...[
              const shad.Divider(),

              // 3. Sticky Footer (Dense Table Header Padding: horizontal 16, vertical 10)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: headerFooterBg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const _SkeletonBox(width: 160, height: 16)
                    else if (footerLeading != null)
                      footerLeading!,
                    const Spacer(),
                    if (isLoading)
                      const _SkeletonBox(width: 90, height: 24)
                    else if (footerAction != null)
                      footerAction!,
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const _SkeletonBox({
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = shad.Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.muted.withAlpha(120),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}
