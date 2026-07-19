import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicContentArea extends StatelessWidget {
  final List<Widget> children;

  const DynamicContentArea({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return Expanded(
      child: shad.Card(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padLg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
