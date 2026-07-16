import 'package:flutter/material.dart';
import '../theme.dart';
import 'button.dart'; // Direct import for CellButton

/// [CellMultiButton] — Segmented button group atom.
///
/// Unifies multiple [CellButton] widgets into a single bordered capsule with 
/// internal vertical dividers. Perfect for view mode switchers or toggle sets.

/// A collaborative segmented button group.
/// Beautifully unified borders with internal dividers.
class CellMultiButton extends StatelessWidget {
  final List<Widget> children;
  final BorderRadius? borderRadius;

  const CellMultiButton({
    super.key,
    required this.children,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? OrganismTheme.borderMd,
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(children.length * 2 - 1, (index) {
            if (index.isOdd) {
              return VerticalDivider(
                width: 1,
                thickness: 1,
                color: colors.border,
              );
            }
            
            final buttonIndex = index ~/ 2;
            final originalWidget = children[buttonIndex];
            
            // Re-wrap with flattened styles
            return _MultiWidgetWrapper(child: originalWidget);
          }),
        ),
      ),
    );
  }
}

class _MultiWidgetWrapper extends StatelessWidget {
  final Widget child;
  const _MultiWidgetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return child; 
  }
}
