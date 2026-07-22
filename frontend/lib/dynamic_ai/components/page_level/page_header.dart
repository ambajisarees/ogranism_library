import 'package:flutter/material.dart' hide Colors, Border;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onExport;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onExport,
  }) : assert(actions.length <= 5, 'PageHeader can take at most 5 actions');

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final effectiveActions = [
      ...actions,
      if (onExport != null)
        shad.OutlineButton(
          onPressed: onExport,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(shad.LucideIcons.download),
              shad.DensityGap(shad.gapSm),
              Text('Export'),
            ],
          ),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.typography.h2.copyWith(color: theme.colorScheme.foreground),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const shad.DensityGap(shad.gapXs),
                Text(subtitle!).small().muted(),
              ],
            ],
          ),
        ),
        if (effectiveActions.isNotEmpty) ...[
          const shad.DensityGap(shad.gapMd),
          shad.DensityRow(
            spacing: shad.gapMd,
            mainAxisSize: MainAxisSize.min,
            children: effectiveActions,
          ),
        ],
      ],
    );
  }
}
