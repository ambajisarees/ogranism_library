import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';
import '../plasma.dart';
import 'workspace_controller.dart';

/// [OrganPaneHeader] — The primary entry point for ERP registry panes.
/// 
/// Revamped Dual-Track Layout:
/// ROW 1: Identity & Primary Action
/// ROW 2: Search & Global Utility
class OrganPaneHeader extends StatefulWidget {
  final String? title;

  // Customization
  final VoidCallback? onAddPressed;
  final String addLabel;
  final IconData addIcon;

  // Search Configuration
  final String? searchPlaceholder;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;

  // Collection Controls
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSortPressed;

  // Popover content support
  final Widget? filterContent;
  final Widget? sortContent;
  final double? filterWidth;
  final double? sortWidth;

  /// Optional primary action to display next to the title.
  final Widget? primaryAction;

  const OrganPaneHeader({
    super.key,
    this.title,
    this.onAddPressed,
    this.addLabel = 'Add',
    this.addIcon = LucideIcons.plus,
    this.searchPlaceholder = 'Search...',
    this.onSearchChanged,
    this.searchController,
    this.onFilterPressed,
    this.onSortPressed,
    this.filterContent,
    this.sortContent,
    this.filterWidth,
    this.sortWidth,
    this.primaryAction,
  });

  @override
  State<OrganPaneHeader> createState() => _OrganPaneHeaderState();
}

class _OrganPaneHeaderState extends State<OrganPaneHeader> {
  final GlobalKey<PlasmaPopoverState> _filterPopoverKey = GlobalKey<PlasmaPopoverState>();
  final GlobalKey<PlasmaPopoverState> _sortPopoverKey = GlobalKey<PlasmaPopoverState>();

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // TRACK 1: Identity & Action
          Padding(
            padding: const EdgeInsets.all(OrganismTheme.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title ?? KineticWorkspaceProvider.maybeOf(context)?.activeModuleName ?? 'Registry',
                    style: OrganismTheme.titleLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widget.primaryAction != null) ...[
                  widget.primaryAction!,
                  const SizedBox(width: OrganismTheme.spacingSm),
                ],
                if (widget.onAddPressed != null)
                  CellButton(
                    text: widget.addLabel,
                    icon: widget.addIcon,
                    variant: CellButtonVariant.primary,
                    isCompact: true,
                    onPressed: widget.onAddPressed,
                  ),
              ],
            ),
          ),

          // TRACK 2: Search & Utility
          Padding(
            padding: const EdgeInsets.only(
              left: OrganismTheme.spacingMd,
              right: OrganismTheme.spacingMd,
              bottom: OrganismTheme.spacingMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CellInput(
                    placeholder: widget.searchPlaceholder!,
                    prefixIcon: LucideIcons.search,
                    isCompact: false,
                    controller: widget.searchController,
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                const SizedBox(width: OrganismTheme.spacingSm),
                if (widget.filterContent != null)
                  PlasmaPopover(
                    key: _filterPopoverKey,
                    explicitWidth: widget.filterWidth ?? 260,
                    targetAnchor: Alignment.bottomRight,
                    followerAnchor: Alignment.topRight,
                    trigger: CellButton(
                      icon: LucideIcons.filter,
                      variant: CellButtonVariant.input,
                      isCompact: false,
                      onPressed: () {
                        _filterPopoverKey.currentState?.toggle();
                      },
                    ),
                    content: widget.filterContent!,
                  )
                else
                  CellButton(
                    icon: LucideIcons.filter,
                    variant: CellButtonVariant.input,
                    isCompact: false,
                    onPressed: widget.onFilterPressed ?? () {},
                  ),
                const SizedBox(width: OrganismTheme.spacingXs),
                if (widget.sortContent != null)
                  PlasmaPopover(
                    key: _sortPopoverKey,
                    explicitWidth: widget.sortWidth ?? 220,
                    targetAnchor: Alignment.bottomRight,
                    followerAnchor: Alignment.topRight,
                    trigger: CellButton(
                      icon: LucideIcons.arrowUpDown,
                      variant: CellButtonVariant.input,
                      isCompact: false,
                      onPressed: () {
                        _sortPopoverKey.currentState?.toggle();
                      },
                    ),
                    content: widget.sortContent!,
                  )
                else
                  CellButton(
                    icon: LucideIcons.arrowUpDown,
                    variant: CellButtonVariant.input,
                    isCompact: false,
                    onPressed: widget.onSortPressed ?? () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
