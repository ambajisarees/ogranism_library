import 'package:flutter/material.dart' hide Colors, Border;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageHeader extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const PageHeader({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actions = const [],
  }) : assert(actions.length <= 5, 'PageHeader can take at most 5 actions');

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final containerSize = theme.iconTheme.x3Large.size;
    final iconSize = theme.iconTheme.xLarge.size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          SizedBox(
            width: containerSize,
            height: containerSize,
            child: shad.Card(
              padding: EdgeInsets.zero,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: iconSize,
                  ),
                  child: icon!,
                ),
              ),
            ),
          ),
          const shad.DensityGap(shad.gapMd),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.typography.h3),
              if (subtitle != null) ...[
                const shad.DensityGap(shad.gapXs),
                Text(subtitle!).small().muted(),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const shad.DensityGap(shad.gapMd),
          shad.DensityRow(
            spacing: shad.gapMd,
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
        ],
      ],
    );
  }
}
