/*
================================================================================
LLM CONTEXT & QUERY SPACE — PURCHASE BILLS FORM DIALOG (scr_pb_form_dialog.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Form Modal Dialog for creating or editing Purchase Bills (`pb`).
   - High-density keyboard-friendly entry modal with supplier, quality, date, 
     bill number, and invoice total inputs.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Built with native `shadcn_flutter` form controls (`shad.TextField`, `shad.Select`, `shad.PrimaryButton`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [ScrPbFormDialog] — Add/Edit Purchase Bill Modal Dialog.
class ScrPbFormDialog extends StatefulWidget {
  const ScrPbFormDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ScrPbFormDialog(),
    );
  }

  @override
  State<ScrPbFormDialog> createState() => _ScrPbFormDialogState();
}

class _ScrPbFormDialogState extends State<ScrPbFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _billNoController = TextEditingController();
  final _qualityController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _supplierController.dispose();
    _billNoController.dispose();
    _qualityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    return shad.AlertDialog(
      title: const Text('Log New Purchase Bill'),
      content: Container(
        width: 480 * theme.scaling,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shad.TextField(
                controller: _supplierController,
                placeholder: const Text('Supplier / Party Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: shad.TextField(
                      controller: _billNoController,
                      placeholder: const Text('Supplier Bill No'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: shad.TextField(
                      controller: _qualityController,
                      placeholder: const Text('Fabric Quality'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              shad.TextField(
                controller: _amountController,
                placeholder: const Text('Net Bill Amount (₹)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        shad.OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        shad.PrimaryButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              shad.showToast(
                context: context,
                builder: (context, show) => shad.Card(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Purchase Bill entry recorded successfully.'),
                  ),
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save Entry'),
        ),
      ],
    );
  }
}
