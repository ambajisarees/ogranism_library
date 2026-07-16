import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/tab_item.dart';

/// [TissueTabChrome] — The structural tray for page-level navigation.
///
/// Provides a consistent 56px height bar for horizontal [CellTabItem] lists.
/// Designed for a high-density, professional "Control Center" experience.
class TissueTabChrome extends StatelessWidget {
  final List<CellTabItem> items;
  final Widget? trailing;

  const TissueTabChrome({
    super.key,
    required this.items,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) => items[index],
            ),
          ),
          if (trailing != null) ...[
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
              constraints: const BoxConstraints(minWidth: 120),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}
