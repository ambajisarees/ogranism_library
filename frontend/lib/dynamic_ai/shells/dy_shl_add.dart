/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC ADD FORM SHELL (dy_shl_add.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dedicated Add/Edit creation workflow page shell layout framing DyPageCanvas.
   - Handles top PageHeader in adding/editing mode alongside custom form content.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Enforces DyPageCanvas(layoutMode: DyPageLayoutMode.form) for Flex 10 centered layout.
   - Manages back button navigation, title, moduleName, and confirm/discard form actions.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'dy_page_canvas.dart';
import '../page/dy_page_header.dart';

/// [DyShlAdd] — Dedicated Page Shell Layout framing DyPageCanvas for Add/Edit flows.
class DyShlAdd extends StatelessWidget {
  final String title;
  final String? moduleName;
  final PageHeaderMode mode;
  final VoidCallback onBack;
  final VoidCallback? onDiscard;
  final VoidCallback? onSaveDraft;
  final VoidCallback onConfirm;
  final Widget content;

  const DyShlAdd({
    super.key,
    required this.title,
    this.moduleName,
    this.mode = PageHeaderMode.adding,
    required this.onBack,
    this.onDiscard,
    this.onSaveDraft,
    required this.onConfirm,
    this.content = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return DyPageCanvas(
      layoutMode: DyPageLayoutMode.form,
      header: PageHeader(
        title: title,
        moduleName: moduleName,
        mode: mode,
        onBack: onBack,
        onDiscard: onDiscard ?? onBack,
        onSaveDraft: onSaveDraft,
        onConfirm: onConfirm,
      ),
      content: content,
    );
  }
}
