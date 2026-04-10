import 'package:flutter/material.dart';
import '../theme.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OrganismTheme.spacingXl),
      decoration: BoxDecoration(
        color: OrganismTheme.stone50,
        border: Border(
          left: BorderSide(
            color: OrganismTheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: OrganismTheme.displayLarge.copyWith(fontSize: 28),
          ),
          const SizedBox(height: OrganismTheme.spacingSm),
          Text(
            description,
            style: OrganismTheme.bodyLarge.copyWith(
              height: 1.6,
              color: OrganismTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
