/*
================================================================================
LLM CONTEXT & QUERY SPACE — SCR_CC_FORM (scr_cc_form.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Cutting Cards Creation & Batch Specification Form Container Screen.
   - Target schema/table: IMMBE2627.sb_cutdet_summary & sb_cutdet.
   - Renders DyPageCanvas in adding mode with PageHeader at top and DyShlAdd body canvas below.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - PageHeader owned by DyPageCanvas at top in adding mode.
   - DyShlAdd sits below PageHeader as the form workspace surface.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_page_header.dart';
import '../../../dynamic_ai/shells/dy_page_canvas.dart';
import '../../../dynamic_ai/shells/dy_shl_add.dart';

/// [ScrCcForm] — Creation Form Screen for Cutting Cards.
class ScrCcForm extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;

  const ScrCcForm({
    super.key,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<ScrCcForm> createState() => _ScrCcFormState();
}

class _ScrCcFormState extends State<ScrCcForm> {
  bool _isSaving = false;

  Future<void> _handleConfirmSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSaving = false);
    shad.showToast(
      context: context,
      builder: (context, overlay) => const shad.SurfaceCard(
        child: Text('Cutting Card created successfully!'),
      ),
    );
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.form,
      header: PageHeader(
        title: 'Cutting Card',
        moduleName: 'Cutting Card',
        mode: PageHeaderMode.adding,
        onBack: widget.onBack,
        onDiscard: widget.onBack,
        onSaveDraft: () {
          shad.showToast(
            context: context,
            builder: (context, overlay) => const shad.SurfaceCard(
              child: Text('Draft saved successfully!'),
            ),
          );
        },
        onConfirm: _handleConfirmSave,
        isSaving: _isSaving,
      ),
      content: const DyShlAdd(),
    );
  }
}
