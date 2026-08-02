/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC ADD FORM SHELL (dy_shl_add.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dedicated Add/Edit creation workflow page shell layout framing PageFormCanvas.
   - Handles top PageHeader in adding mode alongside 2-pane form surface canvas.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Wraps PageFormCanvas (1400px centered max-width, 340px side pane).
   - Manages back button navigation and confirm/discard form actions.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'page_form_canvas.dart';
import '../page/dy_page_header.dart';

/// [DyShlAdd] — Dedicated Page Shell Layout framing PageFormCanvas for Add/Edit flows.
class DyShlAdd extends StatelessWidget {
  final String title;
  final String moduleName;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final Widget mainPane;
  final Widget sidePane;
  final double maxWidth;
  final double sidePaneWidth;

  const DyShlAdd({
    super.key,
    required this.title,
    required this.moduleName,
    required this.onBack,
    required this.onConfirm,
    required this.mainPane,
    required this.sidePane,
    this.maxWidth = 1400.0,
    this.sidePaneWidth = 340.0,
  });

  @override
  Widget build(BuildContext context) {
    return PageFormCanvas(
      maxWidth: maxWidth,
      sidePaneWidth: sidePaneWidth,
      header: PageHeader(
        title: title,
        moduleName: moduleName,
        mode: PageHeaderMode.adding,
        onBack: onBack,
        onDiscard: onBack,
        onConfirm: onConfirm,
      ),
      mainPane: mainPane,
      sidePane: sidePane,
    );
  }
}
