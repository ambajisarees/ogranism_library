/// LLM NOTE: DynamicWorkspaceShell
/// - Level: Root App Workspace Shell Container
/// - Purpose: Top-level workspace scaffold framing the left navigation sidebar (Level 0 flush background) and main workspace view surface (Level 1 padded elevated card).
/// - Widget Composition: shad.Scaffold -> Row(sidebar + Expanded(Padding(8px) -> content)).

import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicWorkspaceShell extends StatelessWidget {
  final Widget sidebar;
  final Widget content;
  final Color? backgroundColor;

  const DynamicWorkspaceShell({
    super.key,
    required this.sidebar,
    required this.content,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isLight = theme.colorScheme.brightness == Brightness.light;
    final level0Background = isLight ? const Color(0xFFF8FAFC) : colors.muted;

    return shad.Scaffold(
      backgroundColor: level0Background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Navigation Sidebar (Flush on Level 0)
          sidebar,
          // Right Elevated Workspace Surface (Level 1)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0 * theme.scaling),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
