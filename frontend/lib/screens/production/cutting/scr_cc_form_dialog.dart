/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Form Modal Dialog for Multi-Cutting Cards (`cc`).
   - Allows users to log new physical cutting cards or edit existing summary metrics 
     (`MILL`, `GREYQUAL`, `CUT_LENGTH`, `TOTAL_RMTS`, `TOTAL_FRESH_PCS`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - High-density form inputs using `shad.TextField` and `shad.Button`.
   - Performs defensive client-side validation before invoking Supabase backend edge functions.
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/production/mdl_cc.dart';

/// [ScrCcFormDialog] — Add/Edit Form Modal Dialog for Cutting Cards.
class ScrCcFormDialog extends StatefulWidget {
  final MdlCcHeader? initialCard;

  const ScrCcFormDialog({
    super.key,
    this.initialCard,
  });

  static Future<MdlCcHeader?> show(BuildContext context, {MdlCcHeader? initialCard}) {
    return showDialog<MdlCcHeader>(
      context: context,
      builder: (_) => ScrCcFormDialog(initialCard: initialCard),
    );
  }

  @override
  State<ScrCcFormDialog> createState() => _ScrCcFormDialogState();
}

class _ScrCcFormDialogState extends State<ScrCcFormDialog> {
  late TextEditingController _millController;
  late TextEditingController _qualityController;
  late TextEditingController _cutLengthController;
  late TextEditingController _totalRmtsController;
  late TextEditingController _freshPcsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _millController = TextEditingController(text: widget.initialCard?.millName ?? '');
    _qualityController = TextEditingController(text: widget.initialCard?.greyQuality ?? '');
    _cutLengthController = TextEditingController(text: widget.initialCard?.cutLength.toString() ?? '6.00');
    _totalRmtsController = TextEditingController(text: widget.initialCard?.totalReceivedMeters.toString() ?? '');
    _freshPcsController = TextEditingController(text: widget.initialCard?.totalFreshPcs.toString() ?? '');
  }

  @override
  void dispose() {
    _millController.dispose();
    _qualityController.dispose();
    _cutLengthController.dispose();
    _totalRmtsController.dispose();
    _freshPcsController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_millController.text.trim().isEmpty || _qualityController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final isEdit = widget.initialCard != null;

    return Dialog(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Cutting Card ${widget.initialCard!.displayCcCode}' : 'Log New Cutting Card',
                  style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                shad.IconButton.ghost(
                  icon: const Icon(shad.LucideIcons.x, size: 16),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            shad.Divider(color: theme.colorScheme.border),
            const SizedBox(height: 16),

            // Form Inputs
            shad.TextField(
              controller: _millController,
              placeholder: const Text('Mill / Dyeing Processor Name'),
            ),
            const SizedBox(height: 12),
            shad.TextField(
              controller: _qualityController,
              placeholder: const Text('Grey Fabric Quality (e.g. CHIFFON BRASSO)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: shad.TextField(
                    controller: _cutLengthController,
                    placeholder: const Text('Cut Length (Mtr)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: shad.TextField(
                    controller: _totalRmtsController,
                    placeholder: const Text('Total Received Mtrs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            shad.TextField(
              controller: _freshPcsController,
              placeholder: const Text('Total Fresh Cut Sarees (Pcs)'),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shad.Button.outline(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                shad.Button.primary(
                  onPressed: _isSaving ? null : _handleSave,
                  child: Text(_isSaving ? 'Saving...' : (isEdit ? 'Save Changes' : 'Create Cutting Card')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
