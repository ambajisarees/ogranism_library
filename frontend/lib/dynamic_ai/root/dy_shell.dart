/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Root workspace scaffold (`DynamicWorkspaceShell`) framing either the Desktop flush Level 0 navigation rail/sidebar alongside the elevated Level 1 workspace surface (8px top/right/bottom margin) or the Mobile viewport with an 8px all-sides Level 0 root boundary inside `SafeArea`.
   - Prevents redundant left-edge inset between the navigation rail and page card on Desktop so rail horizontal padding stays visually balanced.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses `shad.Scaffold` and native density multipliers (`theme.density.baseGap * theme.scaling * shad.gapSm`) for top/right/bottom workspace card breathing room with zero left padding against the rail.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Pure layout wrapper with no direct Supabase queries or mutable state.
   - Left padding MUST remain `0` because the adjacent sidebar/rail already owns its right horizontal edge padding.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None at this stage.
================================================================================
*/

/// LLM NOTE: DynamicWorkspaceShell
/// - Level: Root App Workspace Shell Container
/// - Purpose: Top-level workspace scaffold framing the left navigation sidebar (Level 0 flush background) and main workspace view surface (Level 1 padded elevated card).
/// - Widget Composition: shad.Scaffold -> Row(sidebar + Expanded(Padding(8px) -> content)).

library;

import 'package:flutter/material.dart' hide Card, Tab, Badge, Scaffold;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../specs/dy_color_system.dart';

class DynamicWorkspaceShell extends StatelessWidget {
  final Widget? sidebar;
  final Widget content;
  final Color? backgroundColor;
  final bool isMobile;

  const DynamicWorkspaceShell({
    super.key,
    this.sidebar,
    required this.content,
    this.backgroundColor,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = colors.brightness == Brightness.dark;
    final level0Background =
        backgroundColor ?? DyColorSystem.resolveRootBackground(isDark);
    final mobileSurfaceBackground =
        backgroundColor ?? DyColorSystem.resolveSurfaceCanvas(isDark);

    final shellPad = theme.density.baseGap * theme.scaling * shad.gapSm;
    if (isMobile || sidebar == null) {
      return shad.Scaffold(
        backgroundColor: mobileSurfaceBackground,
        child: SafeArea(
          child: content,
        ),
      );
    }

    return shad.Scaffold(
      backgroundColor: level0Background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Navigation Sidebar (Flush on Level 0)
          sidebar!,
          // Right Elevated Workspace Surface (Level 1)
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, shellPad, shellPad, shellPad),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
