import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseProductDetail extends StatefulWidget {
  const PageShowcaseProductDetail({super.key});

  @override
  State<PageShowcaseProductDetail> createState() => _PageShowcaseProductDetailState();
}

class _PageShowcaseProductDetailState extends State<PageShowcaseProductDetail> {
  double _dyeRatio = 65.0;
  double _binderRatio = 20.0;
  double _softenerRatio = 15.0;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              shad.OutlineButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.arrowLeft, size: 16),
                    SizedBox(width: 6),
                    Text('Back to Catalog'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Royal Zari Silk Saree Specification (Design #D-4089)', style: theme.typography.h2),
                  Text('Master recipe formula, chemical ratios, color shade swatches, and rev history.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.OutlineButton(
                onPressed: () {
                  shad.showOverlay(
                    context,
                    shad.PopoverConfiguration(
                      alignment: Alignment.topRight,
                      builder: (context) => shad.ModalContainer(
                        child: Container(
                          width: 280,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Revision History Log', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('• Rev 3.2 (Jul 19): Dye ratio adjusted +5%'),
                              Text('• Rev 3.1 (Jun 12): Binder percentage updated'),
                              Text('• Rev 3.0 (May 04): Initial formula creation'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.history, size: 16),
                    SizedBox(width: 8),
                    Text('Revision Log (Rev 3.2)'),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapSm),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Text('Save Formula Changes'),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Main Detail Split (60% Ratios / 40% Swatches & Specs)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Chemical Formula Sliders
              Expanded(
                flex: 3,
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chemical Recipe Ratios', style: theme.typography.h3),
                      Text('Adjust component percentages per 100 Kg dyeing vessel batch.', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      const shad.DensityGap(shad.gapLg),

                      // Dye Percentage
                      Text('1. Active Dye Pigment: ${_dyeRatio.round()}%', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                      shad.Slider(
                        value: shad.SliderValue.single(_dyeRatio),
                        min: 0.0,
                        max: 100.0,
                        onChanged: (v) => setState(() => _dyeRatio = v.value),
                      ),
                      const shad.DensityGap(shad.gapMd),

                      // Binder Percentage
                      Text('2. Acrylic Binder Compound: ${_binderRatio.round()}%', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                      shad.Slider(
                        value: shad.SliderValue.single(_binderRatio),
                        min: 0.0,
                        max: 100.0,
                        onChanged: (v) => setState(() => _binderRatio = v.value),
                      ),
                      const shad.DensityGap(shad.gapMd),

                      // Softener Percentage
                      Text('3. Silicone Softener Emulsion: ${_softenerRatio.round()}%', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                      shad.Slider(
                        value: shad.SliderValue.single(_softenerRatio),
                        min: 0.0,
                        max: 100.0,
                        onChanged: (v) => setState(() => _softenerRatio = v.value),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // Right: Shade Swatches & Fabric Metadata
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    shad.Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Approved Color Shade Swatches', style: theme.typography.h3),
                          const shad.DensityGap(shad.gapMd),
                          Row(
                            children: [
                              _buildShadeSwatch(context, title: 'Crimson Red', hex: '#E11D48', color: const Color(0xFFE11D48)),
                              const SizedBox(width: 12),
                              _buildShadeSwatch(context, title: 'Royal Blue', hex: '#2563EB', color: const Color(0xFF2563EB)),
                              const SizedBox(width: 12),
                              _buildShadeSwatch(context, title: 'Emerald Green', hex: '#059669', color: const Color(0xFF059669)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const shad.DensityGap(shad.gapLg),
                    shad.Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fabric Physical Parameters', style: theme.typography.h3),
                          const shad.DensityGap(shad.gapMd),
                          _buildParamRow(context, label: 'Warp Yarn Type', val: 'Mulberry Silk 60/2'),
                          _buildParamRow(context, label: 'Weft Yarn Type', val: 'Pure Metallic Zari'),
                          _buildParamRow(context, label: 'Standard Width', val: '44 Inches (Saree Format)'),
                          _buildParamRow(context, label: 'GSM Weight', val: '84 GSM (+/- 2%)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShadeSwatch(BuildContext context, {required String title, required String hex, required Color color}) {
    final theme = shad.Theme.of(context);
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(color: theme.colorScheme.border),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
        Text(hex, style: theme.typography.mono.copyWith(fontSize: 10, color: theme.colorScheme.mutedForeground)),
      ],
    );
  }

  Widget _buildParamRow(BuildContext context, {required String label, required String val}) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
          const Spacer(),
          Text(val, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
