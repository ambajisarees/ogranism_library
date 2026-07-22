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

    return shad.Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Navigation Sidebar
          sidebar,
          // Right Edge-to-Edge Workspace
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }
}
