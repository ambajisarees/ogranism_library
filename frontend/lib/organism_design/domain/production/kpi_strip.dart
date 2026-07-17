import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';
import 'kpi_tile.dart';

class OrganKpiStrip extends StatelessWidget {
  final List<DomainKpiTile> items;
  final bool isLoading;

  const OrganKpiStrip({
    super.key,
    required this.items,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeletonRow();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: OrganismTheme.spacingLg),
            child: SizedBox(
              width: 200, // Normalized width for grid-like feel in strip
              child: item,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(4, (index) => const Padding(
          padding: EdgeInsets.only(right: OrganismTheme.spacingLg),
          child: CellSkeleton(
            width: 200,
            height: 100,
          ),
        )),
      ),
    );
  }
}
