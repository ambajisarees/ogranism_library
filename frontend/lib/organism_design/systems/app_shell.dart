import 'package:flutter/material.dart';
import '../theme.dart';
import '../organs/workspace_controller.dart';

/// [OrganAppShell] — The standard Level 5 assembly shell for the ERP.
///
/// Composes a [Topbar], [NavBoat] (Sidebar), Main Content Area, 
/// and an optional Right auxiliary panel into a cohesive layout.
class OrganAppShell extends StatelessWidget {
  /// The main functional pane (e.g., Dashboard, Data Grid).
  final Widget content;

  /// The horizontal header bar.
  final Widget? topbar;

  /// The vertical navigation sidebar.
  final Widget? sidebar;

  /// Optional persistent right-side panel (e.g., Filtering, Properties).
  final Widget? rightPanel;

  /// Background color for the entire shell.
  final Color? backgroundColor;

  /// Global controller managing workspace state (used for layout conditions if needed).
  final KineticWorkspaceController? controller;

  const OrganAppShell({
    super.key,
    required this.content,
    this.topbar,
    this.sidebar,
    this.rightPanel,
    this.backgroundColor,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final overlayVisible = controller?.isOverlayVisible ?? false;
    final overlayContent = controller?.overlayContent;
    final onOverlayCloseRequest = controller?.onOverlayCloseRequest;

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      body: Stack(
        children: [
          // ── MAIN APPLICATION LAYER ─────────────────────────────────
          Column(
            children: [
              // 1. Top Section (Global Actions / Search)
              if (topbar != null) topbar!,
    
              // 2. Main Section (Navigation + Content)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Navigation Sidebar
                    if (sidebar != null) sidebar!,
    
                    // Main Content Area
                    Expanded(
                      child: controller != null 
                        ? KineticWorkspaceProvider(
                            controller: controller!,
                            child: content,
                          )
                        : content,
                    ),
    
                    // Right Panel (if any)
                    if (rightPanel != null) rightPanel!,
                  ],
                ),
              ),
            ],
          ),

          // ── SYSTEM OVERLAY LAYER (SCRIM) ───────────────────────────
          if (overlayVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: onOverlayCloseRequest,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: OrganismTheme.durationStandard,
                  color: colors.overlay, // Official Theme Scrim
                ),
              ),
            ),

          // ── CREATION CANVAS LAYER (FULL-SCREEN BELOW TOPBAR) ────────
          if (overlayContent != null)
            Builder(
              builder: (context) {
                final screenHeight = MediaQuery.sizeOf(context).height;
                final topOffset = OrganismTheme.topbarHeight;

                return AnimatedPositioned(
                  duration: OrganismTheme.durationStandard,
                  curve: OrganismTheme.curveStandard,
                  left: 0,
                  right: 0,
                  top: overlayVisible ? topOffset : screenHeight,
                  bottom: 0,
                  child: overlayContent,
                );
              },
            ),
        ],
      ),
    );
  }
}
