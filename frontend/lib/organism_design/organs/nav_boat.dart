import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';
import 'workspace_controller.dart';

/// [NavBoat] — The primary vertical navigation shell.
/// 
/// Responds to the [KineticWorkspaceController] for collapse/expand states.
class NavBoat extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final KineticWorkspaceController controller;
  /// When true, the sidebar stays collapsed and hover-peek is disabled.
  final bool forceCollapsed;

  const NavBoat({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.controller,
    this.forceCollapsed = false,
  });

  @override
  State<NavBoat> createState() => _NavBoatState();
}

class _NavBoatState extends State<NavBoat> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final bool isPersistentCollapsed = widget.forceCollapsed || widget.controller.isSidebarCollapsed;
    final bool isPeeking = isPersistentCollapsed && _isHovered && !widget.forceCollapsed;

    // Visual width that includes the overlay peek
    final double viewWidth = (isPersistentCollapsed && !isPeeking) 
        ? OrganismTheme.sidebarWidthCollapsed 
        : OrganismTheme.sidebarWidth;

    return MouseRegion(
      onEnter: (_) {
        if (isPersistentCollapsed) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isPersistentCollapsed) setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: OrganismTheme.durationFast,
        curve: OrganismTheme.curveStandard,
        width: viewWidth,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(right: BorderSide(color: colors.border)),
        ),
        child: Column(
          children: [
            const SizedBox(height: OrganismTheme.spacingMd),

            // Navigation List
            Expanded(
              child: SingleChildScrollView(
                clipBehavior: Clip.none, 
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    CellNavItem(
                      icon: LucideIcons.layoutDashboard,
                      label: 'Dashboard',
                      isSelected: widget.selectedIndex == 0,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(0),
                    ),
                    
                    _NavBoatHeader(
                      label: 'Masters', 
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                    ),
                    
                    CellNavItem(
                      icon: LucideIcons.users,
                      label: 'Parties',
                      isSelected: widget.selectedIndex == 1,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(1),
                    ),
                    CellNavItem(
                      icon: LucideIcons.package,
                      label: 'Items',
                      isSelected: widget.selectedIndex == 2,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(2),
                    ),
                    CellNavItem(
                      icon: LucideIcons.palette,
                      label: 'Designs',
                      isSelected: widget.selectedIndex == 3,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(3),
                    ),
                    CellNavItem(
                      icon: LucideIcons.truck,
                      label: 'Transports',
                      isSelected: widget.selectedIndex == 4,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(4),
                    ),

                    _NavBoatHeader(
                      label: 'Production', 
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                    ),

                    CellNavItem(
                      icon: LucideIcons.factory,
                      label: 'Pipeline',
                      isSelected: widget.selectedIndex == 5,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(5),
                    ),
                    CellNavItem(
                      icon: LucideIcons.activity,
                      label: 'Admin & Sync',
                      isSelected: widget.selectedIndex == 8,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(8),
                    ),

                    _NavBoatHeader(
                      label: 'Design System', 
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                    ),

                    CellNavItem(
                      icon: LucideIcons.book,
                      label: 'Library',
                      isSelected: widget.selectedIndex == 9,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(9),
                    ),
                    CellNavItem(
                      icon: LucideIcons.image,
                      label: 'Media',
                      isSelected: widget.selectedIndex == 10,
                      isCollapsed: isPersistentCollapsed && !isPeeking,
                      onTap: () => widget.onItemSelected(10),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: OrganismTheme.spacingMd),
          ],
        ),
      ),
    );
  }
}

class _NavBoatHeader extends StatelessWidget {
  final String label;
  final bool isCollapsed;

  const _NavBoatHeader({required this.label, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            // 1. Fixed "Divider" Area for Rail
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: OrganismTheme.sidebarWidthCollapsed - 12.0, // Match CellNavItem
              child: Center(
                child: Container(
                  height: 1,
                  width: 20,
                  color: colors.border,
                ),
              ),
            ),

            // 2. Sliding Label Area
            Positioned(
              left: OrganismTheme.sidebarWidthCollapsed - 12.0,
              top: 0,
              bottom: 0,
              right: 0,
              child: ClipRect(
                child: AnimatedSlide(
                  duration: OrganismTheme.durationFast,
                  curve: OrganismTheme.curveStandard,
                  offset: isCollapsed ? const Offset(-1.0, 0) : Offset.zero,
                  child: AnimatedOpacity(
                    duration: OrganismTheme.durationFast,
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: OrganismTheme.spacingSm),
                        child: Text(
                          label.toUpperCase(),
                          style: OrganismTheme.labelMedium(context).copyWith(
                            color: colors.textMuted,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
