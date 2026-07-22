import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicContentPane extends StatelessWidget {
  final Widget child;

  const DynamicContentPane({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return Expanded(
      child: shad.Card(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
        child: child,
      ),
    );
  }
}
