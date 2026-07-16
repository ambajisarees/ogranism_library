import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';
import '../cells/spatial.dart';

class TissueBarcodeScanner extends StatefulWidget {
  final ValueChanged<String> onScanned;
  final String label;

  const TissueBarcodeScanner({
    super.key,
    required this.onScanned,
    this.label = 'Scan Barcode',
  });

  @override
  State<TissueBarcodeScanner> createState() => _TissueBarcodeScannerState();
}

class _TissueBarcodeScannerState extends State<TissueBarcodeScanner> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.onScanned(value.trim());
      _controller.clear();
    }
    // Maintain focus for continuous scanning
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(OrganismTheme.spacingSm),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.scanLine, color: colors.primary),
          ),
          CellGap.standard,
          Expanded(
            child: CellInput(
              controller: _controller,
              focusNode: _focusNode,
              isNaked: true,
              textStyle: OrganismTheme.codeTabular(context).copyWith(
                fontSize: OrganismTheme.titleMedium(context).fontSize,
                letterSpacing: 2,
              ),
              placeholder: widget.label,
              textInputAction: TextInputAction.done,
              onSubmitted: _handleSubmitted,
            ),
          ),
          CellGap.standard,
          Tooltip(
            message: 'Waiting for scanner input (simulates camera / keyboard wedge)',
            child: Icon(LucideIcons.scanLine, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
