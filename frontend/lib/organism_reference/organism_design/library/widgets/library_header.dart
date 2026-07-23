import 'package:flutter/material.dart';
import '../../theme.dart';

class LibraryHeader extends StatelessWidget {
  final String title;
  final String description;

  const LibraryHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OrganismTheme.spacingXl),
      decoration: BoxDecoration(
        color: colors.stone50,
        border: Border(
          left: BorderSide(
            color: colors.primary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: OrganismTheme.displayLarge(context),
          ),
          const SizedBox(height: OrganismTheme.spacingSm),
          Text(
            description,
            style: OrganismTheme.bodyLarge(context).copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
