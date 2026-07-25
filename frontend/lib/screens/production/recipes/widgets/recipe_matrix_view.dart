import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Optional Matrix Grid Pivot View for rapidly entering an entire mill rate sheet across fabrics.
class MillRecipeMatrixView extends StatefulWidget {
  final String millName;
  final List<String> fabrics;
  final List<String> printTypes;
  final Map<String, double> initialMatrix; // Key: 'fabricCode_printType' -> rate
  final ValueChanged<Map<String, double>> onSaveMatrix;

  const MillRecipeMatrixView({
    super.key,
    required this.millName,
    required this.fabrics,
    required this.printTypes,
    required this.initialMatrix,
    required this.onSaveMatrix,
  });

  @override
  State<MillRecipeMatrixView> createState() => _MillRecipeMatrixViewState();
}

class _MillRecipeMatrixViewState extends State<MillRecipeMatrixView> {
  late Map<String, double> _matrixValues;

  @override
  void initState() {
    super.initState();
    _matrixValues = Map.from(widget.initialMatrix);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.Card(
      child: Padding(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulk Matrix View - ${widget.millName}',
                      style: theme.typography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pivot grid for multi-fabric rate sheet entry',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
                shad.PrimaryButton(
                  onPressed: () => widget.onSaveMatrix(_matrixValues),
                  child: const Row(
                    children: [
                      Icon(shad.LucideIcons.save, size: 14),
                      SizedBox(width: 4),
                      Text('Save Matrix Rates'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const shad.Divider(),
            const SizedBox(height: 12),

            // Pivot Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultColumnWidth: const FixedColumnWidth(120),
                    border: TableBorder.all(
                      color: colors.border,
                      width: 1.0,
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                    ),
                    children: [
                      // Header Row (Print Types)
                      TableRow(
                        decoration: BoxDecoration(color: colors.muted.withAlpha(80)),
                        children: [
                          _buildHeaderCell(context, 'Fabric / Print'),
                          for (var pType in widget.printTypes)
                            _buildHeaderCell(context, pType),
                        ],
                      ),

                      // Data Rows (Fabrics)
                      for (var fabric in widget.fabrics)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                fabric,
                                style: theme.typography.xSmall
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            for (var pType in widget.printTypes)
                              _buildMatrixInputCell(context, fabric, pType),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.foreground,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMatrixInputCell(
      BuildContext context, String fabric, String printType) {
    final key = '${fabric}_$printType';
    final initialRate = _matrixValues[key] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: shad.TextField(
        initialValue: initialRate > 0 ? initialRate.toString() : '',
        placeholder: const Text('₹0.0'),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          final rate = double.tryParse(val) ?? 0.0;
          _matrixValues[key] = rate;
        },
      ),
    );
  }
}
