import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class FormDataItem {
  final String label;
  final String value;
  final Widget? valueWidget; // Optional widget override for badge display or similar

  const FormDataItem({
    required this.label,
    required this.value,
    this.valueWidget,
  });
}

class FormDataList extends StatelessWidget {
  final String title;
  final List<FormDataItem> fields;

  const FormDataList({
    super.key,
    required this.title,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            title,
            style: theme.typography.textLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const shad.DensityGap(shad.gapSm),
          const shad.Divider(),
          const shad.DensityGap(shad.gapSm),
          // Fields display
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: fields.map((field) => _buildFieldRow(theme, colors, field)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(shad.ThemeData theme, shad.ColorScheme colors, FormDataItem field) {
    return Padding(
      padding: EdgeInsets.only(bottom: theme.density.baseGap * shad.gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: theme.typography.textMuted.copyWith(fontSize: 11),
          ),
          const shad.DensityGap(shad.gapXs),
          if (field.valueWidget != null) ...[
            field.valueWidget!,
          ] else ...[
            Text(
              field.value,
              style: theme.typography.textSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
