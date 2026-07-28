import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [PageFormCanvas] — Pure modular zero-overhead layout container.
/// Constrains header and form children to [maxWidth], centers them horizontally,
/// and applies zero internal padding so layout inherits parent TabPane surface padding.
class PageFormCanvas extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const PageFormCanvas({
    super.key,
    this.header,
    required this.child,
    this.maxWidth = 1200.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth * theme.scaling),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[
                header!,
                const shad.DensityGap(shad.gapMd),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
