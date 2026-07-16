import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../tissues.dart';

/// [SystemAppMasterLayout] — The Level 5 structural blueprint for ERP registries.
/// 
/// Composes the workstation into a high-density, split-pane workstation.
/// - Left Pane: Registry Hub (Identity Header + Navigation List).
/// - Right Pane: Content Canvas (Unified Sticky Header + Scrollable Form Cards).
class SystemAppMasterLayout extends StatelessWidget {
  // Master Pane (Left) Props
  final Widget paneHeader;
  final Widget paneList;
  
  // Optional Top Navigation (e.g. TissueTabChrome)
  final Widget? tabs;
  
  // Detail Pane (Right) Unified Organ
  final Widget? sectionCanvas;

  // State indicators
  final bool isDetailVisible;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;

  const SystemAppMasterLayout({
    super.key,
    required this.paneHeader,
    required this.paneList,
    this.sectionCanvas,
    this.isDetailVisible = false,
    this.emptyTitle = 'No selection',
    this.emptyMessage = 'Select an item from the list to view and manage its details.',
    this.emptyIcon = LucideIcons.mousePointer2,
    this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final paneWidth = constraints.maxWidth < OrganismTheme.breakpointMd
            ? OrganismTheme.masterPaneWidthCompact
            : OrganismTheme.masterPaneWidth;

        return Column(
          children: [
            if (tabs != null) tabs!,
            Expanded(
              child: Row(
                children: [
                  // ── MASTER PANE ──────────────────────────────────────────
                  Container(
                    width: paneWidth,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: colors.border)),
                    ),
                    child: Column(
                      children: [
                        paneHeader,
                        Expanded(child: paneList),
                      ],
                    ),
                  ),

                  // ── DETAIL PANE (CANVAS) ─────────────────────────────────
                  Expanded(
                    child: isDetailVisible && sectionCanvas != null
                        ? sectionCanvas!
                        : Container(
                            color: colors.surfaceSubtle,
                            padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(OrganismTheme.radiusLg),
                                border: Border.all(color: colors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: TissueEmptyState(
                                  title: emptyTitle,
                                  message: emptyMessage,
                                  icon: emptyIcon,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
