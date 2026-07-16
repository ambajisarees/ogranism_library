import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../widgets/library_section.dart';

class ThemeView extends StatelessWidget {
  const ThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorsSection(context, colors),
        _buildTypographySection(context, colors),
        _buildMetricsSection(context, colors),
      ],
    );
  }

  Widget _buildColorsSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Color Palette',
      subtitle: 'Dynamic tokens matching the Kinetic Fuchsia theme.',
      child: Wrap(
        spacing: OrganismTheme.spacingMd,
        runSpacing: OrganismTheme.spacingMd,
        children: [
          _colorChip(context, colors, 'Primary', colors.primary),
          _colorChip(context, colors, 'Stone Base', colors.stone200),
          _colorChip(context, colors, 'Surface', colors.surface),
          _colorChip(context, colors, 'Background', colors.background),
          _colorChip(context, colors, 'Border', colors.border),
          _colorChip(context, colors, 'Error (Destructive)', colors.error),
          _colorChip(context, colors, 'Success', colors.success),
          _colorChip(context, colors, 'Warning', colors.warning),
        ],
      ),
    );
  }

  Widget _colorChip(BuildContext context, OrganismColors colors, String label, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      decoration: BoxDecoration(
        color: color,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Text(
        label,
        style: OrganismTheme.bodySmall(context).copyWith(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _buildTypographySection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Typography System',
      subtitle: 'Semantically bound text primitives.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display Large', style: OrganismTheme.displayLarge(context)),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text('Title Large', style: OrganismTheme.titleLarge(context)),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text('Body Large', style: OrganismTheme.bodyLarge(context)),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text('Label Large', style: OrganismTheme.labelLarge(context)),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text('Numeric Medium - 1,234,567', style: OrganismTheme.numericMedium(context)),
          const SizedBox(height: OrganismTheme.spacingMd),
          Text('Code Tabular - A1B2C3D4', style: OrganismTheme.codeTabular(context)),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Metrics & Spacing',
      subtitle: 'Standardized layout gaps and boundaries.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          _metricBox(context, colors, 'xs (4)', OrganismTheme.spacingXs),
          _metricBox(context, colors, 'sm (8)', OrganismTheme.spacingSm),
          _metricBox(context, colors, 'md (16)', OrganismTheme.spacingMd),
          _metricBox(context, colors, 'lg (24)', OrganismTheme.spacingLg),
          _metricBox(context, colors, 'xl (32)', OrganismTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _metricBox(BuildContext context, OrganismColors colors, String label, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          color: colors.primary.withValues(alpha: 0.2),
        ),
        const SizedBox(width: OrganismTheme.spacingSm),
        Flexible(child: Text(label, style: OrganismTheme.codeTabular(context))),
      ],
    );
  }
}
