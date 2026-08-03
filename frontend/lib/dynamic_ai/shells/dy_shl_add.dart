/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC ADD FORM SHELL (dy_shl_add.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Dedicated Add/Edit creation body shell layout sitting directly below PageHeader in DyPageCanvas.
   - Standardized container canvas framing the form body content (e.g. 2-pane form: Main Form + Sidebar).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Does NOT wrap PageHeader internally (PageHeader is owned 100% by DyPageCanvas).
   - Serves as the form workspace canvas sitting below PageHeader in adding/editing mode.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;

/// [DyShlAdd] — Body Shell Layout sitting below PageHeader in DyPageCanvas for Add/Edit flows.
class DyShlAdd extends StatelessWidget {
  final Widget child;

  const DyShlAdd({
    super.key,
    this.child = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
