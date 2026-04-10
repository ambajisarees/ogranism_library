import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../index.dart';
import '../widgets/library_header.dart';

class PlasmaView extends StatelessWidget {
  const PlasmaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryHeader(
          title: 'Level 1: Plasma (Foundations)',
          description: 'The fundamental colors, typography, and layout physics governing the ERP.',
        ),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildColorSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildTypographySection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildGeometrySection(),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary & Semantics', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingMd),
        Wrap(
          spacing: OrganismTheme.spacingMd,
          runSpacing: OrganismTheme.spacingMd,
          children: [
            _colorSwatch('Primary', OrganismTheme.primary),
            _colorSwatch('Primary Dark', OrganismTheme.primaryDark),
            _colorSwatch('Primary Light', OrganismTheme.primaryLight),
            _colorSwatch('Primary Subtle', OrganismTheme.primarySubtle, border: true),
            _colorSwatch('Success', OrganismTheme.success),
            _colorSwatch('Warning', OrganismTheme.warning),
            _colorSwatch('Error', OrganismTheme.error),
          ],
        ),
        const SizedBox(height: OrganismTheme.spacingLg),
        Text('Stones & Architectural Surfaces', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingMd),
        Wrap(
          spacing: OrganismTheme.spacingSm,
          runSpacing: OrganismTheme.spacingSm,
          children: [
            _colorSwatch('50 (Bg)', OrganismTheme.stone50, border: true),
            _colorSwatch('100 (Hover)', OrganismTheme.stone100, border: true),
            _colorSwatch('200 (Border)', OrganismTheme.stone200, border: true),
            _colorSwatch('300 (Active)', OrganismTheme.stone300, border: true),
            _colorSwatch('400 (Muted)', OrganismTheme.stone400),
            _colorSwatch('600 (Sec. Txt)', OrganismTheme.stone600),
            _colorSwatch('900 (Prim. Txt)', OrganismTheme.stone900),
          ],
        )
      ],
    );
  }

  Widget _colorSwatch(String label, Color color, {bool border = false}) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: color,
            borderRadius: OrganismTheme.borderMd,
            border: border ? Border.all(color: OrganismTheme.border) : null,
            boxShadow: OrganismTheme.shadowSm,
          ),
        ),
        const SizedBox(height: OrganismTheme.spacingSm),
        SizedBox(
          width: 90,
          child: Text(label, style: OrganismTheme.labelLarge, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _typeRow('Display Large', OrganismTheme.displayLarge),
        _typeRow('Title Large', OrganismTheme.titleLarge),
        _typeRow('Title Medium', OrganismTheme.titleMedium),
        _typeRow('Body Large', OrganismTheme.bodyLarge),
        _typeRow('Body Medium', OrganismTheme.bodyMedium),
        _typeRow('Body Small', OrganismTheme.bodySmall),
        _typeRow('Label Large', OrganismTheme.labelLarge),
        _typeRow('Numeric / Code', OrganismTheme.code, sample: 'O27-FX-992.34 MTS'),
      ],
    );
  }

  Widget _typeRow(String name, TextStyle style, {String sample = 'Ambaji Textiles ERP System'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OrganismTheme.spacingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 160,
            child: Text(name, style: OrganismTheme.labelLarge.copyWith(color: OrganismTheme.primaryLight)),
          ),
          Expanded(
            child: Text(sample, style: style),
          ),
        ],
      ),
    );
  }

  Widget _buildGeometrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Z-Index Shadows & Radius Mappings', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingXl),
        Wrap(
          spacing: OrganismTheme.spacingLg,
          runSpacing: OrganismTheme.spacingLg,
          children: [
            _shadowBox('Small Drop\nRadius Md', OrganismTheme.shadowSm, OrganismTheme.borderMd),
            _shadowBox('Medium Float\nRadius Lg', OrganismTheme.shadowMd, OrganismTheme.borderLg),
            _shadowBox('Deep Modal\nRadius Xl', OrganismTheme.shadowLg, BorderRadius.circular(OrganismTheme.radiusXl)),
            _shadowBox('Subtle Glow\nRadius Pill', OrganismTheme.shadowGlow, OrganismTheme.borderPill, isGlow: true),
          ],
        )
      ]
    );
  }

  Widget _shadowBox(String label, List<BoxShadow> shadow, BorderRadius radius, {bool isGlow = false}) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        borderRadius: radius,
        boxShadow: shadow,
        border: Border.all(color: isGlow ? OrganismTheme.primary.withOpacity(0.2) : OrganismTheme.borderSubtle),
      ),
      alignment: Alignment.center,
      child: Text(label, textAlign: TextAlign.center, style: OrganismTheme.bodyMedium),
    );
  }
}
