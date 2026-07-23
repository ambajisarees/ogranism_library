import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';
import '../tissues.dart';
import 'workspace_controller.dart';

/// [NavRail] — The consolidated master control rail for the ERP.
/// 
/// Replaces both the horizontal Topbar and previous vertical NavRail.
/// Features a fixed "Control Layer" at the top and a scrollable "Modules Section" below.
class NavRail extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final KineticWorkspaceController controller;
  final bool forceCollapsed;

  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.controller,
    this.forceCollapsed = false,
  });

  @override
  State<NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<NavRail> {
  bool _isHovered = false;
  /// Internal state to override hover peek if the user manually collapses
  bool _isManualCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final bool isPersistentCollapsed =
        widget.forceCollapsed || widget.controller.isSidebarCollapsed;
    
    // Peeking is active only if hover is on AND we haven't manually collapsed since entering
    final bool isPeeking = isPersistentCollapsed && 
                          _isHovered && 
                          !widget.forceCollapsed && 
                          !_isManualCollapsed;

    final bool isVisualCollapsed = isPersistentCollapsed && !isPeeking;

    final double viewWidth = isVisualCollapsed
        ? OrganismTheme.sidebarWidthCollapsed
        : OrganismTheme.sidebarWidth;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: MouseRegion(
        onEnter: (_) {
          if (isPersistentCollapsed) {
            setState(() {
              _isHovered = true;
              _isManualCollapsed = false; // Reset override on re-entry
            });
          }
        },
        onExit: (_) {
          if (isPersistentCollapsed) {
            setState(() {
              _isHovered = false;
              _isManualCollapsed = false; // Reset override on exit
            });
          }
        },
        child: AnimatedContainer(
          duration: OrganismTheme.durationFast,
          curve: OrganismTheme.curveStandard,
          width: viewWidth,
          decoration: BoxDecoration(
            color: colors.background, // Match darker background as requested
            border: Border(right: BorderSide(color: colors.border)),
          ),
          child: Column(
            children: [
              // FIXED TOP CONTROL LAYER
              _ControlLayer(
                isCollapsed: isVisualCollapsed,
                controller: widget.controller,
                onTaskTap: () => widget.onItemSelected(8),
                onTogglePressed: () {
                  widget.controller.toggleSidebar();
                  // If we are currently peeking, force it to stay collapsed
                  if (_isHovered) {
                    setState(() => _isManualCollapsed = true);
                  }
                },
              ),

              // SCROLLABLE MODULES SECTION
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingMd),
                  child: Column(
                    children: [
                      _NavHeader(label: 'Masters', isCollapsed: isVisualCollapsed),
                      _buildNavItem(0, LucideIcons.layoutDashboard, 'Dashboard', isVisualCollapsed),
                      _buildNavItem(1, LucideIcons.users, 'Parties', isVisualCollapsed),
                      _buildNavItem(2, LucideIcons.package, 'Items', isVisualCollapsed),
                      _buildNavItem(3, LucideIcons.palette, 'Designs', isVisualCollapsed),
                      _buildNavItem(4, LucideIcons.truck, 'Transports', isVisualCollapsed),
                      
                      _NavHeader(label: 'Production', isCollapsed: isVisualCollapsed),
                      _buildNavItem(5, LucideIcons.factory, 'Pipeline', isVisualCollapsed),
                      _buildNavItem(6, LucideIcons.scissors, 'Cutting', isVisualCollapsed),
                      _buildNavItem(7, LucideIcons.settings, 'Job Work', isVisualCollapsed),
                      
                      _NavHeader(label: 'Analysis', isCollapsed: isVisualCollapsed),
                      _buildNavItem(8, LucideIcons.fileText, 'Reports', isVisualCollapsed),
                      _buildNavItem(9, LucideIcons.book, 'Library', isVisualCollapsed),
                      _buildNavItem(10, LucideIcons.image, 'Media', isVisualCollapsed),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isCollapsed) {
    return CellNavItem(
      icon: icon,
      label: label,
      isSelected: widget.selectedIndex == index,
      isCollapsed: isCollapsed,
      onTap: () => widget.onItemSelected(index),
    );
  }
}

/// [_ControlLayer] — The fixed top section containing branding and global actions.
class _ControlLayer extends StatelessWidget {
  final bool isCollapsed;
  final KineticWorkspaceController controller;
  final VoidCallback onTaskTap;
  final VoidCallback onTogglePressed;

  const _ControlLayer({
    required this.isCollapsed,
    required this.controller,
    required this.onTaskTap,
    required this.onTogglePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingMd),
      child: Column(
        children: [
          // 1. HEADER (Toggle + Logo)
          _NavHeaderBlock(
            isCollapsed: isCollapsed,
            onPressed: onTogglePressed,
          ),
          const SizedBox(height: OrganismTheme.spacingMd),

          // 2. SEARCH
          _SearchBlock(
            isCollapsed: isCollapsed,
            controller: controller,
          ),

          // 3. TASKS
          _TasksBlock(
            isCollapsed: isCollapsed, 
            onTap: onTaskTap,
          ),

          // 4. PROFILE
          _ProfileBlock(isCollapsed: isCollapsed),
        ],
      ),
    );
  }
}

/// Combined Toggle and Logo block
class _NavHeaderBlock extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onPressed;

  const _NavHeaderBlock({required this.isCollapsed, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          // FIXED SLOT: The Toggle Icon
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: OrganismTheme.sidebarWidthCollapsed - 12.0,
            child: Center(
              child: CellButton(
                text: '',
                // Collapsed: Show Expand (ChevronsRight), Expanded: Show Collapse (ChevronsLeft)
                icon: isCollapsed ? LucideIcons.chevronsRight : LucideIcons.chevronsLeft,
                variant: CellButtonVariant.ghost,
                isCompact: true,
                onPressed: onPressed,
              ),
            ),
          ),

          // EXTENSION: The Logo
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
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: OrganismTheme.spacingSm),
                      child: AmbajiSareeLogo(isCollapsed: false, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBlock extends StatelessWidget {
  final bool isCollapsed;
  final KineticWorkspaceController controller;

  const _SearchBlock({required this.isCollapsed, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CellNavItem(
      icon: LucideIcons.search,
      label: 'Search',
      isCollapsed: isCollapsed,
      variant: CellNavItemVariant.action,
      trailing: const CellKbd(keyString: 'Ctrl+K'),
      onTap: () {
        TissueCommandPalette.show(
          context,
          actions: [
            CommandPaletteAction(
              id: 'nav_parties',
              label: 'Parties',
              subtitle: 'Registry',
              icon: LucideIcons.users,
              onSelect: () => controller.setModuleIndex(1),
            ),
            CommandPaletteAction(
              id: 'nav_items',
              label: 'Items',
              subtitle: 'Inventory',
              icon: LucideIcons.package,
              onSelect: () => controller.setModuleIndex(2),
            ),
          ],
        );
      },
    );
  }
}

class _TasksBlock extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onTap;
  const _TasksBlock({required this.isCollapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Custom leading with notification dot for collapsed state
    final Widget leading = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          LucideIcons.checkSquare,
          size: OrganismTheme.iconSizeMd,
          color: colors.textSecondary,
        ),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.error,
              shape: BoxShape.circle,
              border: Border.all(color: colors.background, width: 2),
            ),
          ),
        ),
      ],
    );

    return CellNavItem(
      leading: leading,
      label: 'Tasks',
      subtitle: const Text('26 Pending Tasks'),
      isCollapsed: isCollapsed,
      variant: CellNavItemVariant.action,
      onTap: onTap,
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  final bool isCollapsed;
  const _ProfileBlock({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return CellNavItem(
      leading: const CellAvatar(name: 'Smit', size: 28),
      label: 'Smit',
      subtitle: const Text('Admin'),
      isCollapsed: isCollapsed,
      variant: CellNavItemVariant.action,
      trailing: const Icon(LucideIcons.settings, size: 16),
      onTap: () {},
    );
  }
}

class _NavHeader extends StatelessWidget {
  final String label;
  final bool isCollapsed;
  const _NavHeader({required this.label, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          // FIXED SLOT: Divider Line (Left Aligned within the track)
          Positioned(
            left: 12,
            top: 15,
            width: 24,
            height: 1,
            child: Container(
              color: colors.border,
            ),
          ),

          // EXTENSION: Label
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
                      padding: const EdgeInsets.only(left: OrganismTheme.spacingMd),
                      child: Text(
                        label.toUpperCase(),
                        style: OrganismTheme.labelSmall(context).copyWith(
                          color: colors.textMuted,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
