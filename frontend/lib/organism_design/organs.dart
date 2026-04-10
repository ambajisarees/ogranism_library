// organs.dart
// Collections of tissues (cards, complex entity layouts, app shells)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'cells.dart';

/// The primary navigation shell for the ERP. 
/// Supports two states: Rail (Collapsed) and Sidebar (Expanded).
class NavBoat extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NavBoat({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<NavBoat> createState() => _NavBoatState();
}

class _NavBoatState extends State<NavBoat> {
  bool _isCollapsed = false;

  void _toggle() => setState(() => _isCollapsed = !_isCollapsed);

  @override
  Widget build(BuildContext context) {
    final double width = _isCollapsed 
        ? OrganismTheme.sidebarWidthCollapsed 
        : OrganismTheme.sidebarWidth;

    return AnimatedContainer(
      duration: OrganismTheme.durationStandard,
      curve: OrganismTheme.curveStandard,
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        border: Border(right: BorderSide(color: OrganismTheme.border)),
      ),
      child: Column(
        children: [
          // 1. Top Control Bar (Toggle button only, moved to top right)
          Padding(
            padding: const EdgeInsets.only(
              top: OrganismTheme.spacingSm, 
              right: OrganismTheme.spacingSm,
              left: OrganismTheme.spacingSm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: _isCollapsed ? Alignment.center : Alignment.centerRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: OrganismTheme.stone100,
                        borderRadius: OrganismTheme.borderSm,
                        border: Border.all(color: OrganismTheme.border),
                      ),
                      child: Icon(
                        _isCollapsed ? LucideIcons.chevronRight : LucideIcons.chevronLeft,
                        size: OrganismTheme.iconSizeSm,
                        color: OrganismTheme.iconSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Branding Area (Below toggle)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: OrganismTheme.spacingMd,
              horizontal: _isCollapsed ? 0 : OrganismTheme.spacingMd,
            ),
            child: AmbajiSareeLogo(
              isCollapsed: _isCollapsed,
              size: _isCollapsed ? 32 : 36,
            ),
          ),

          const SizedBox(height: OrganismTheme.spacingMd),

          // 3. Navigation List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingSm),
              child: Column(
                children: [
                   _NavBoatItem(
                    index: 0,
                    icon: LucideIcons.layoutDashboard,
                    label: 'Dashboard',
                    isSelected: widget.selectedIndex == 0,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(0),
                  ),
                  
                  _NavBoatHeader(label: 'Masters', isCollapsed: _isCollapsed),
                  
                  _NavBoatItem(
                    index: 1,
                    icon: LucideIcons.users,
                    label: 'Parties',
                    isSelected: widget.selectedIndex == 1,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(1),
                  ),
                  _NavBoatItem(
                    index: 2,
                    icon: LucideIcons.package,
                    label: 'Items',
                    isSelected: widget.selectedIndex == 2,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(2),
                  ),
                  _NavBoatItem(
                    index: 3,
                    icon: LucideIcons.palette,
                    label: 'Designs',
                    isSelected: widget.selectedIndex == 3,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(3),
                  ),
                  _NavBoatItem(
                    index: 4,
                    icon: LucideIcons.truck,
                    label: 'Transports',
                    isSelected: widget.selectedIndex == 4,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(4),
                  ),

                  _NavBoatHeader(label: 'Production', isCollapsed: _isCollapsed),

                  _NavBoatItem(
                    index: 5,
                    icon: LucideIcons.factory,
                    label: 'Pipeline',
                    isSelected: widget.selectedIndex == 5,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(5),
                  ),
                  _NavBoatItem(
                    index: 6,
                    icon: LucideIcons.scissors,
                    label: 'Cutting',
                    isSelected: widget.selectedIndex == 6,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(6),
                  ),
                  _NavBoatItem(
                    index: 7,
                    icon: LucideIcons.settings,
                    label: 'Job Work',
                    isSelected: widget.selectedIndex == 7,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(7),
                  ),
                  _NavBoatItem(
                    index: 8,
                    icon: LucideIcons.fileText,
                    label: 'Reports',
                    isSelected: widget.selectedIndex == 8,
                    isCollapsed: _isCollapsed,
                    onTap: () => widget.onItemSelected(8),
                  ),
                ],
              ),
            ),
          ),

          // Footer info (Session info)
          if (!_isCollapsed)
            Container(
              padding: const EdgeInsets.all(OrganismTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: OrganismTheme.border)),
              ),
              child: Row(
                children: [
                  const CellAvatar(name: 'Smit', size: 32),
                  const SizedBox(width: OrganismTheme.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Smit', style: OrganismTheme.labelLarge),
                        Text('Admin', style: OrganismTheme.bodySmall.copyWith(color: OrganismTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
             Padding(
              padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingMd),
              child: const CellAvatar(name: 'Smit', size: 28),
            ),
        ],
      ),
    );
  }
}

class _NavBoatItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavBoatItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool showLabelInRail = isCollapsed && isSelected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: OrganismTheme.borderMd,
        child: AnimatedContainer(
          duration: OrganismTheme.durationFast,
          curve: OrganismTheme.curveStandard,
          height: showLabelInRail ? 56 : 40,
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? OrganismTheme.spacingXs : OrganismTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isSelected ? OrganismTheme.primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: OrganismTheme.borderMd,
            border: isSelected && isCollapsed ? Border.all(color: OrganismTheme.primary.withOpacity(0.2)) : null,
          ),
          child: AnimatedSwitcher(
            duration: OrganismTheme.durationFast,
            child: isCollapsed
                ? Column(
                    key: ValueKey('collapsed_${isSelected}_$index'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        Text(
                          label,
                          style: OrganismTheme.labelMedium.copyWith(
                            fontSize: 9,
                            color: OrganismTheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Icon(
                        icon,
                        size: OrganismTheme.iconSizeMd,
                        color: isSelected ? OrganismTheme.primary : OrganismTheme.iconSecondary,
                      ),
                    ],
                  )
                : Row(
                    key: ValueKey('expanded_$index'),
                    children: [
                      Icon(
                        icon,
                        size: OrganismTheme.iconSizeMd,
                        color: isSelected ? OrganismTheme.primary : OrganismTheme.iconSecondary,
                      ),
                      const SizedBox(width: OrganismTheme.spacingMd),
                      Expanded(
                        child: Text(
                          label,
                          style: OrganismTheme.titleMedium.copyWith(
                            color: isSelected ? OrganismTheme.primary : OrganismTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14, // Slightly tighter titleMedium for Nav
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
          ),
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
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingLg),
        child: Container(
          height: 1,
          width: 24,
          color: OrganismTheme.border,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: OrganismTheme.spacingMd,
        top: OrganismTheme.spacingLg,
        bottom: OrganismTheme.spacingSm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: OrganismTheme.labelLarge.copyWith(
            color: OrganismTheme.textMuted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
