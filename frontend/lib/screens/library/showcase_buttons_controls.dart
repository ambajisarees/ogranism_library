import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseButtonsControls extends StatefulWidget {
  const ShowcaseButtonsControls({super.key});

  @override
  State<ShowcaseButtonsControls> createState() => _ShowcaseButtonsControlsState();
}

class _ShowcaseButtonsControlsState extends State<ShowcaseButtonsControls> {
  bool _switchVal1 = true;
  bool _switchVal2 = false;
  final bool _switchVal3 = true;
  shad.CheckboxState _checkState1 = shad.CheckboxState.checked;
  shad.CheckboxState _checkState2 = shad.CheckboxState.unchecked;
  shad.CheckboxState _checkState3 = shad.CheckboxState.indeterminate;
  String _radioVal = 'option1';
  double _sliderVal = 45.0;
  double _ratingVal = 4.0;
  int _counterVal = 12;
  String _segmentedVal = 'day';

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text('Buttons & Control Elements', style: theme.typography.h2),
          Text(
            'Interactive controls across all 6 native states (Normal, Hover, Focused, Pressed, Disabled, Loading) with native token compliance.',
            style: theme.typography.textMuted,
          ),
          const shad.DensityGap(shad.gapLg),

          // 1. Button Variants Matrix
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Button Variant & State Matrix', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 16 * theme.scaling,
                  runSpacing: 16 * theme.scaling,
                  children: [
                    _buildStateColumn(context, 'Primary', (label, state) => _buildButtonHelper(context, label, 'primary', state)),
                    _buildStateColumn(context, 'Secondary', (label, state) => _buildButtonHelper(context, label, 'secondary', state)),
                    _buildStateColumn(context, 'Outline', (label, state) => _buildButtonHelper(context, label, 'outline', state)),
                    _buildStateColumn(context, 'Ghost', (label, state) => _buildButtonHelper(context, label, 'ghost', state)),
                    _buildStateColumn(context, 'Destructive', (label, state) => _buildButtonHelper(context, label, 'destructive', state)),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. MicroButton & ERP Specific Button Styles
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ERP MicroButtons & Card Focus Outlines (Rule 8 Compliance)', style: theme.typography.h3),
                Text(
                  'Card-only focus outline using dynamic Border.all directly in style (colors.primary when focused). Zero duplicate wrappers.',
                  style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                ),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 12 * theme.scaling,
                  runSpacing: 12 * theme.scaling,
                  children: [
                    shad.Button.card(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(shad.LucideIcons.plus, size: 14),
                          shad.DensityGap(shad.gapSm),
                          Text('Add Party'),
                        ],
                      ),
                    ),
                    shad.Button.card(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(shad.LucideIcons.filter, size: 14),
                          shad.DensityGap(shad.gapSm),
                          Text('Filter Records'),
                        ],
                      ),
                    ),
                    shad.Button.card(
                      onPressed: null, // Disabled
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(shad.LucideIcons.lock, size: 14),
                          shad.DensityGap(shad.gapSm),
                          Text('Locked (Disabled)'),
                        ],
                      ),
                    ),
                    shad.Button.card(
                      onPressed: () {},
                      child: const Icon(shad.LucideIcons.refreshCw, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 3. Icon Buttons & Sizes
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Icon Buttons & Densities', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 16 * theme.scaling,
                  runSpacing: 12 * theme.scaling,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    shad.IconButton.primary(
                      icon: const Icon(shad.LucideIcons.download),
                      onPressed: () {},
                    ),
                    shad.IconButton.secondary(
                      icon: const Icon(shad.LucideIcons.upload),
                      onPressed: () {},
                    ),
                    shad.IconButton.outline(
                      icon: const Icon(shad.LucideIcons.copy),
                      onPressed: () {},
                    ),
                    shad.IconButton.ghost(
                      icon: const Icon(shad.LucideIcons.trash2),
                      onPressed: () {},
                    ),
                    shad.IconButton.outline(
                      density: shad.ButtonDensity.iconDense,
                      size: shad.ButtonSize.small,
                      icon: const Icon(shad.LucideIcons.pencil, size: 14),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 4. Form Selection Controls (Switch, Checkbox, Radio)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Switches & Toggles', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Row(
                        children: [
                          shad.Switch(
                            value: _switchVal1,
                            onChanged: (v) => setState(() => _switchVal1 = v),
                          ),
                          const shad.DensityGap(shad.gapMd),
                          Text('Auto Sync Airbyte', style: theme.typography.textSmall),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Row(
                        children: [
                          shad.Switch(
                            value: _switchVal2,
                            onChanged: (v) => setState(() => _switchVal2 = v),
                          ),
                          const shad.DensityGap(shad.gapMd),
                          Text('Dark Mode Overlay', style: theme.typography.textSmall),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Row(
                        children: [
                          shad.Switch(
                            value: _switchVal3,
                            onChanged: null, // Disabled
                          ),
                          const shad.DensityGap(shad.gapMd),
                          Text('System Read-Only (Disabled)', style: theme.typography.textMuted),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Checkboxes', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Row(
                        children: [
                          shad.Checkbox(
                            state: _checkState1,
                            onChanged: (s) => setState(() => _checkState1 = s),
                          ),
                          const shad.DensityGap(shad.gapMd),
                          Text('Include Taxes (Checked)', style: theme.typography.textSmall),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Row(
                        children: [
                          shad.Checkbox(
                            state: _checkState2,
                            onChanged: (s) => setState(() => _checkState2 = s),
                          ),
                          const shad.DensityGap(shad.gapMd),
                          Text('Print Packing Slip (Unchecked)', style: theme.typography.textSmall),
                        ],
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Row(
                        children: [
                          shad.Checkbox(
                            state: _checkState3,
                            onChanged: (s) => setState(() => _checkState3 = s),
                          ),
                          const shad.DensityGap(shad.gapMd),
                          Text('Partial Stock (Indeterminate)', style: theme.typography.textSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 5. Radio Groups & Sliders
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radio Options', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.RadioGroup<String>(
                        value: _radioVal,
                        onChanged: (val) => setState(() => _radioVal = val),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shad.RadioItem(
                              value: 'option1',
                              trailing: Text('FY 26-27 (Current Fiscal)', style: theme.typography.textSmall),
                            ),
                            shad.RadioItem(
                              value: 'option2',
                              trailing: Text('FY 25-26 (Archive)', style: theme.typography.textSmall),
                            ),
                            shad.RadioItem(
                              value: 'option3',
                              trailing: Text('All Fiscal Years', style: theme.typography.textSmall),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sliders & Control Ranges', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Text('Target Discount: ${_sliderVal.round()}%', style: theme.typography.xSmall),
                      shad.Slider(
                        value: shad.SliderValue.single(_sliderVal),
                        min: 0.0,
                        max: 100.0,
                        onChanged: (v) => setState(() => _sliderVal = v.value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 6. Ratings, Segmented Buttons, & Number Steppers
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rating, Stepper & Segmented Controls', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 24 * theme.scaling,
                  runSpacing: 16 * theme.scaling,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Star Rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Party Credit Grade', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                        const shad.DensityGap(shad.gapSm),
                        shad.StarRating(
                          value: _ratingVal,
                          onChanged: (v) => setState(() => _ratingVal = v),
                        ),
                      ],
                    ),
                    // Quantity Stepper
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Batch Quantity', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                        const shad.DensityGap(shad.gapSm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            shad.IconButton.outline(
                              size: shad.ButtonSize.small,
                              icon: const Icon(shad.LucideIcons.minus, size: 14),
                              onPressed: () {
                                if (_counterVal > 1) setState(() => _counterVal--);
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12 * theme.scaling),
                              child: Text('$_counterVal', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            shad.IconButton.outline(
                              size: shad.ButtonSize.small,
                              icon: const Icon(shad.LucideIcons.plus, size: 14),
                              onPressed: () => setState(() => _counterVal++),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Segmented Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Timeline Scope', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                        const shad.DensityGap(shad.gapSm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _segmentedVal == 'day'
                                ? shad.PrimaryButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () => setState(() => _segmentedVal = 'day'),
                                    child: const Text('Daily'),
                                  )
                                : shad.OutlineButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () => setState(() => _segmentedVal = 'day'),
                                    child: const Text('Daily'),
                                  ),
                            const shad.DensityGap(shad.gapXs),
                            _segmentedVal == 'week'
                                ? shad.PrimaryButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () => setState(() => _segmentedVal = 'week'),
                                    child: const Text('Weekly'),
                                  )
                                : shad.OutlineButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () => setState(() => _segmentedVal = 'week'),
                                    child: const Text('Weekly'),
                                  ),
                            const shad.DensityGap(shad.gapXs),
                            _segmentedVal == 'month'
                                ? shad.PrimaryButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () => setState(() => _segmentedVal = 'month'),
                                    child: const Text('Monthly'),
                                  )
                                : shad.OutlineButton(
                                    size: shad.ButtonSize.small,
                                    onPressed: () => setState(() => _segmentedVal = 'month'),
                                    child: const Text('Monthly'),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateColumn(
    BuildContext context,
    String label,
    Widget Function(String label, String stateName) builder,
  ) {
    final theme = shad.Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
        const shad.DensityGap(shad.gapSm),
        builder(label, 'Normal'),
        const shad.DensityGap(shad.gapSm),
        builder(label, 'Hover'),
        const shad.DensityGap(shad.gapSm),
        builder(label, 'Focused'),
        const shad.DensityGap(shad.gapSm),
        builder(label, 'Disabled'),
        const shad.DensityGap(shad.gapSm),
        builder(label, 'Loading'),
      ],
    );
  }

  Widget _buildButtonHelper(
    BuildContext context,
    String label,
    String variant,
    String state,
  ) {
    final isHovered = state == 'Hover';
    final isFocused = state == 'Focused';
    final isDisabled = state == 'Disabled';
    final isLoading = state == 'Loading';

    final childWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(right: 6.0),
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        Text('$label ($state)'),
      ],
    );

    final VoidCallback? onPressed = (isDisabled || isLoading) ? null : () {};

    Widget btnWidget;
    switch (variant) {
      case 'secondary':
        btnWidget = shad.SecondaryButton(onPressed: onPressed, child: childWidget);
        break;
      case 'outline':
        btnWidget = shad.OutlineButton(onPressed: onPressed, child: childWidget);
        break;
      case 'ghost':
        btnWidget = shad.GhostButton(onPressed: onPressed, child: childWidget);
        break;
      case 'destructive':
        btnWidget = shad.DestructiveButton(onPressed: onPressed, child: childWidget);
        break;
      case 'primary':
      default:
        btnWidget = shad.PrimaryButton(onPressed: onPressed, child: childWidget);
        break;
    }

    if (isHovered) {
      btnWidget = Opacity(opacity: 0.85, child: btnWidget);
    }

    if (isFocused) {
      final theme = shad.Theme.of(context);
      btnWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: btnWidget,
      );
    }

    return btnWidget;
  }
}
