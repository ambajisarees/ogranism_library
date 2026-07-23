import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellKbd] — Keyboard key visualization atom.
///
/// Renders a key label (e.g. 'ESC', '⌘K') in a hard-edge mechanical style
/// to indicate keyboard shortcuts.

/// Keyboard key geometry rendering exact literal keystroke styling
class CellKbd extends StatelessWidget {
  final String keyString;

  const CellKbd({
    super.key,
    required this.keyString,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        border: Border.all(color: colors.border),
        borderRadius: OrganismTheme.borderSm,
        boxShadow: [
          BoxShadow(
            color: colors.border,
            offset: const Offset(0, 1), // Simulating 3D mechanical key depth slightly
          )
        ]
      ),
      child: Text(
        keyString,
        style: OrganismTheme.monoLabel(context).copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
