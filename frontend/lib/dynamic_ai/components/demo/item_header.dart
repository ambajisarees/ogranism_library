import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ItemHeader extends StatelessWidget {
  final String title;
  final VoidCallback onEditPressed;

  const ItemHeader({
    super.key,
    required this.title,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return shad.Card(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
      child: SizedBox(
        height: 38.0 * theme.scaling, // Aligns precisely with the search textfield height of the DynamicList header
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.typography.h3.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.foreground),
            ),
            const Spacer(),
            shad.OutlineButton(
              onPressed: onEditPressed,
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
