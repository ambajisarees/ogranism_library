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
                  Text(
                    title,
                    style: theme.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.foreground,
                    ),
                  ),
                  if (statusBadge != null) ...[
                    const SizedBox(width: 8),
                    statusBadge!,
                  ],
                  const Spacer(),
                  if (toolbarActions != null && toolbarActions!.isNotEmpty) ...[
                    ...toolbarActions!,
                    const SizedBox(width: 8),
                  ],
                  primaryAction,
                ],
              ),
            ),

            const shad.Divider(),

            // 2. Middle Scrollable Content Area (Generic Page Child)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padMd),
                child: child,
              ),
            ),

            if (footerLeading != null || footerAction != null) ...[
              const shad.Divider(),

              // 3. Sticky Footer (Dense Table Header Padding: horizontal 16, vertical 10)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: headerFooterBg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (footerLeading != null) footerLeading!,
                    const Spacer(),
                    if (footerAction != null) footerAction!,
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
