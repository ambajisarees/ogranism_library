/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Root application left `NavigationRail` (`DynamicSidebarNav`) implementing a
     native-token collapsed icon rail with animated Icon <-> KeyCap swapping on `Alt`
     press/latch, keyboard-navigable submodule flyout popovers, and a 224px expanded
     accordion tree.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Collapsed State (native token width = `iconBtnExtent + railPad * 2` = 52px
     at 1.0x scaling, 8px uniform outer padding via `gapSm`):
     * Selected state uses neutral `DyColorSystem.resolveSelectItem(isDark, colors)`
       card background fill only; icons, labels, and chevrons stay `colors.foreground`.
     * All KeyCaps uniformly use `colors.mutedForeground` fill with
       `colors.primaryForeground` text (inverted on `Quick Add [Q]` to
       `colors.primaryForeground` fill with `colors.primary` text).
     * `Quick Add [Q]` uses filled primary styling (`colors.primary` fill) with
       `colors.primaryForeground` icon, label, and keycap badge.
     * Solo holding `Alt` >= 400ms is handled globally by `KeyboardManagerWidget` to
       expand/collapse `DynamicSidebarNav` cleanly in-place (no floating preview overlay).
   - Expanded State (`expandedWidth: 224.0`):
     * Consistent `gapSm` (`8px`) outer padding and `iconTheme.medium` (`20px`)
       row icon size across Collapsed, Expanded, Flyout, and Mobile Drawer states.
     * Exclusive single-accordion (`_expandedFolderId`) with Option 2 trickle-down
       KeyCaps (`_armedFolderId`): shows top-level KeyCaps (`H/Q/M/P/S/F/W`) by default;
       pressing `Alt + M/P/S/F/W` arms that folder exclusively, hides top-level KeyCaps,
       and reveals only that folder's submodule KeyCaps. Selecting a child or `Esc` /
       `Backspace` / tab switch disarms back to top-level KeyCaps while keeping the active
       section open.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Obeys Rule 2 (`GEMINI.md`): keeps pure `Text(item.label)` on `shad.NavigationItem`,
     never nests `Expanded` inside `NavigationLabeled`.
   - Syncs `ServiceKeyboardShortcuts.instance.syncFlyoutState` so the workspace canvas
     applies a subtle tint whenever a collapsed folder flyout is open.
   - `resetSidebarKeyboardState()` closes open flyouts and disarms folders when switching tabs.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Configurable hold-to-expand delay (`400ms`) lives in `KeyboardManagerWidget`.
================================================================================
*/

library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart' hide Card, Tab, Badge, Divider;
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../services/service_keyboard_shortcuts.dart';
import '../specs/dy_color_system.dart';

bool get _isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

double _iconSm(shad.ThemeData theme) => theme.iconTheme.small.size ?? 16.0;

double _iconMd(shad.ThemeData theme) => theme.iconTheme.medium.size ?? 20.0;

shad.AbstractButtonStyle _railItemStyle({
  required shad.AbstractButtonStyle baseStyle,
  required Color hoverColor,
  Color? fixedBgColor,
  EdgeInsetsGeometry? padding,
}) {
  return baseStyle.copyWith(
    padding: padding != null ? (ctx, state, pad) => padding : null,
    decoration: (ctx, state, decoration) {
      final base = decoration as BoxDecoration? ?? const BoxDecoration();
      if (fixedBgColor != null) return base.copyWith(color: fixedBgColor);
      return state.hovered ? base.copyWith(color: hoverColor) : base;
    },
  );
}

/// Model representing a navigation node or collapsible folder in [DynamicSidebarNav].
class DynamicSidebarNavItem {
  final String? id;
  final IconData? icon;
  final String label;
  final String? shortcutKey;
  final VoidCallback? onTap;
  final ValueChanged<BuildContext>? onContextTap;
  final bool isSelected;
  final bool isHeader;
  final bool isPrimaryAction;
  final bool hasTrailingDivider;
  final List<DynamicSidebarNavItem> children;

  const DynamicSidebarNavItem({
    this.id,
    this.icon,
    required this.label,
    this.shortcutKey,
    this.onTap,
    this.onContextTap,
    this.isSelected = false,
    this.isHeader = false,
    this.isPrimaryAction = false,
    this.hasTrailingDivider = false,
    this.children = const [],
  });

  bool get isFolder => children.isNotEmpty;
  bool get hasSelectedChild =>
      children.any((c) => c.isSelected || c.hasSelectedChild);
}

/// Pure native [shad.NavigationRail] shell with density-token collapsed icon rail,
/// animated Icon <-> KeyCap switcher on `Alt`, hold-to-peek tooltips,
/// flyout submodule menus, and an expanded tree with trailing keycaps.
class DynamicSidebarNav extends StatefulWidget {
  final List<DynamicSidebarNavItem> items;
  final List<Widget> footerItems;
  final Widget? header;
  final Widget? floatingExpandedHeader;
  final double? collapsedWidth;
  final double expandedWidth;
  final bool expanded;

  const DynamicSidebarNav({
    super.key,
    required this.items,
    this.footerItems = const [],
    this.header,
    this.floatingExpandedHeader,
    this.collapsedWidth,
    this.expandedWidth = 224.0,
    this.expanded = true,
  });

  @override
  State<DynamicSidebarNav> createState() => DynamicSidebarNavState();
}

class DynamicSidebarNavState extends State<DynamicSidebarNav> {
  final Map<String, GlobalKey> _folderAnchorKeys = {};

  shad.OverlayCompleter<dynamic>? _activeFlyout;
  String? _activeFlyoutFolderId;
  String? _expandedFolderId;
  String? _armedFolderId;

  @override
  void initState() {
    super.initState();
    _syncSelectedFolderExpansion(forceToSelected: true);
  }

  @override
  void didUpdateWidget(covariant DynamicSidebarNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedChanged =
        _selectedItemKey(widget.items) != _selectedItemKey(oldWidget.items);
    if (selectedChanged) {
      _armedFolderId = null;
      _syncSelectedFolderExpansion(forceToSelected: true);
    } else {
      _syncSelectedFolderExpansion();
    }
    if (widget.expanded && !oldWidget.expanded) {
      _closeActiveFlyout();
    } else if (!widget.expanded && oldWidget.expanded) {
      _armedFolderId = null;
    }
  }

  @override
  void dispose() {
    _closeActiveFlyout();
    ServiceKeyboardShortcuts.instance.syncFlyoutState(false);
    super.dispose();
  }

  /// Clears open sidebar flyouts and armed folder highlights on workspace tab switch.
  void resetSidebarKeyboardState() {
    _closeActiveFlyout();
    cancelArmedFolder();
  }

  String? _selectedItemKey(List<DynamicSidebarNavItem> items) {
    for (final item in items) {
      if (item.isSelected) return item.id ?? item.label;
      final childKey = _selectedItemKey(item.children);
      if (childKey != null) return childKey;
    }
    return null;
  }

  void _syncSelectedFolderExpansion({bool forceToSelected = false}) {
    if (!forceToSelected && _armedFolderId != null) return;
    for (final item in widget.items) {
      if (item.isFolder && item.hasSelectedChild) {
        _expandedFolderId = item.id ?? item.label;
        return;
      }
    }
    if (widget.items.any((i) => !i.isFolder && i.isSelected)) {
      _expandedFolderId = null;
    }
  }

  GlobalKey _anchorKeyFor(DynamicSidebarNavItem item) =>
      _folderAnchorKeys.putIfAbsent(item.id ?? item.label, () => GlobalKey());

  void _closeActiveFlyout() {
    final hadFlyout = _activeFlyout != null || _activeFlyoutFolderId != null;
    _activeFlyout?.close();
    _activeFlyout = null;
    _activeFlyoutFolderId = null;
    ServiceKeyboardShortcuts.instance.syncFlyoutState(false);
    if (hadFlyout && mounted) setState(() {});
  }

  void _toggleExpandedFolder(DynamicSidebarNavItem folder) {
    final folderId = folder.id ?? folder.label;
    _closeActiveFlyout();
    if (_isAndroidPlatform) {
      setState(() {
        _expandedFolderId = _expandedFolderId == folderId ? null : folderId;
        _armedFolderId = null;
      });
      return;
    }
    final isAlreadyArmedAndOpen =
        _expandedFolderId == folderId && _armedFolderId == folderId;
    setState(() {
      if (isAlreadyArmedAndOpen) {
        _expandedFolderId = null;
        _armedFolderId = null;
      } else {
        _expandedFolderId = folderId;
        _armedFolderId = folderId;
      }
    });
  }

  /// Disarms the currently focused trickle-down folder on `Esc`, restoring top-level KeyCaps.
  void cancelArmedFolder() {
    if (_armedFolderId == null) return;
    setState(() {
      _armedFolderId = null;
      _syncSelectedFolderExpansion(forceToSelected: true);
    });
  }

  void _activateItem(DynamicSidebarNavItem item) {
    _closeActiveFlyout();
    if (widget.expanded) {
      setState(() {
        if (!item.isPrimaryAction) _expandedFolderId = null;
        _armedFolderId = null;
      });
    }
    if (item.onContextTap != null) {
      final anchorCtx = _anchorKeyFor(item).currentContext ?? context;
      item.onContextTap!(anchorCtx);
    } else {
      item.onTap?.call();
    }
  }

  /// Dispatches global `Alt + Letter` triggers from [KeyboardManagerWidget].
  void handleShortcutKey(String keyChar) {
    final normalized = keyChar.trim().toUpperCase();
    for (final item in widget.items) {
      if ((item.shortcutKey ?? '').toUpperCase() != normalized) continue;
      if (item.isFolder) {
        if (widget.expanded) {
          _toggleExpandedFolder(item);
        } else {
          openFolderFlyout(item);
        }
      } else {
        _activateItem(item);
      }
      return;
    }
  }

  /// Routes a single-letter keypress in expanded mode to the armed folder's child.
  bool handleExpandedSubmoduleKey(String keyChar) {
    if (!widget.expanded || _activeFlyout != null || _armedFolderId == null) {
      return false;
    }
    final normalized = keyChar.trim().toUpperCase();
    if (normalized.isEmpty) return false;

    for (final folder in widget.items) {
      if (!folder.isFolder) continue;
      final folderId = folder.id ?? folder.label;
      if (folderId != _armedFolderId) continue;

      for (final child in folder.children) {
        if ((child.shortcutKey ?? '').toUpperCase() == normalized) {
          if (mounted) {
            setState(() {
              _expandedFolderId = folderId;
              _armedFolderId = null;
            });
          }
          child.onTap?.call();
          return true;
        }
      }
    }
    return false;
  }

  /// Opens a keyboard-navigable flyout menu anchored beside a folder row.
  void openFolderFlyout(DynamicSidebarNavItem folder) {
    if (!folder.isFolder) return;
    final folderId = folder.id ?? folder.label;

    if (_activeFlyoutFolderId == folderId && _activeFlyout != null) {
      _closeActiveFlyout();
      return;
    }

    _activeFlyout?.close();
    _activeFlyout = null;

    final anchorContext = _folderAnchorKeys[folderId]?.currentContext ?? context;
    final theme = shad.Theme.of(context);
    final gapUnit = theme.density.baseGap * theme.scaling;

    setState(() {
      _activeFlyoutFolderId = folderId;
      if (widget.expanded) _expandedFolderId = folderId;
    });
    ServiceKeyboardShortcuts.instance.syncFlyoutState(true);

    final completer = shad.showOverlay<void>(
      anchorContext,
      shad.PopoverConfiguration(
        alignment: AlignmentDirectional.topStart,
        anchorAlignment: AlignmentDirectional.topEnd,
        offset: Offset(gapUnit * shad.gapSm, 0),
        dismissBackdropFocus: true,
        allowInvertVertical: true,
        allowInvertHorizontal: true,
      ),
      builder: (overlayContext) {
        return _SidebarFolderFlyout(
          folder: folder,
          onSelectChild: (child) {
            shad.closeOverlay(overlayContext);
            child.onTap?.call();
          },
          onDismiss: () => shad.closeOverlay(overlayContext),
        );
      },
    );
    _activeFlyout = completer;
    completer.future.whenComplete(() {
      if (_activeFlyout == completer) {
        _activeFlyout = null;
        _activeFlyoutFolderId = null;
        ServiceKeyboardShortcuts.instance.syncFlyoutState(false);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ServiceKeyboardShortcuts.instance.isAltPressedNotifier,
      builder: (context, isAltPressed, _) {
        return _buildRailWidget(
          context,
          isExpandedView: widget.expanded,
          isAltPressed: isAltPressed,
          includeAnchorKeys: true,
        );
      },
    );
  }

  Widget _buildRailWidget(
    BuildContext context, {
    required bool isExpandedView,
    required bool isAltPressed,
    required bool includeAnchorKeys,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = colors.brightness == Brightness.dark;
    final gapUnit = theme.density.baseGap * scaling;

    final railPad = gapUnit * shad.gapSm;
    final iconBtnExtent = _iconMd(theme) + (gapUnit * shad.gapSm * 2);
    final resolvedCollapsedSize = widget.collapsedWidth != null
        ? widget.collapsedWidth! * scaling
        : iconBtnExtent + (railPad * 2);

    final level0Background = DyColorSystem.resolveRootBackground(isDark);
    final hoverColor = colors.accent;
    final selectedBgColor = DyColorSystem.resolveSelectItem(isDark, colors);

    final collapsedGhostStyle = _railItemStyle(
      baseStyle: const shad.ButtonStyle.ghost(density: shad.ButtonDensity.icon),
      hoverColor: hoverColor,
    );
    final collapsedSelectedStyle = _railItemStyle(
      baseStyle:
          const shad.ButtonStyle.secondary(density: shad.ButtonDensity.icon),
      hoverColor: hoverColor,
      fixedBgColor: selectedBgColor,
    );
    final expandedRowPadding = EdgeInsets.symmetric(
      horizontal: gapUnit * shad.gapSm,
      vertical: gapUnit * shad.gapSm,
    );
    final expandedGhostStyle = _railItemStyle(
      baseStyle: const shad.ButtonStyle.ghost(),
      hoverColor: hoverColor,
      padding: expandedRowPadding,
    );
    final expandedSelectedStyle = _railItemStyle(
      baseStyle: const shad.ButtonStyle.secondary(),
      hoverColor: hoverColor,
      fixedBgColor: selectedBgColor,
      padding: expandedRowPadding,
    );

    final collapsedPrimaryStyle = _railItemStyle(
      baseStyle:
          const shad.ButtonStyle.primary(density: shad.ButtonDensity.icon),
      hoverColor: colors.primary.withAlpha(220),
      fixedBgColor: colors.primary,
    );
    final expandedPrimaryStyle = _railItemStyle(
      baseStyle: const shad.ButtonStyle.primary(),
      hoverColor: colors.primary.withAlpha(220),
      fixedBgColor: colors.primary,
      padding: expandedRowPadding,
    );

    final List<Widget> railChildren = [];
    final hasActiveFlyout = _activeFlyoutFolderId != null;
    final allowKeyCaps = !_isAndroidPlatform;
    final showTopKeyCaps =
        allowKeyCaps && (!includeAnchorKeys || _armedFolderId == null);

    for (final item in widget.items) {
      if (item.isHeader && !item.isFolder) continue;

      if (item.isFolder) {
        final folderId = item.id ?? item.label;
        final isFlyoutOwner = _activeFlyoutFolderId == folderId;
        final isCollapsedSelected =
            hasActiveFlyout ? isFlyoutOwner : item.hasSelectedChild;

        if (!isExpandedView) {
          railChildren.add(
            _buildCollapsedNavItem(
              context,
              anchorKey: includeAnchorKeys ? _anchorKeyFor(item) : null,
              item: item,
              isSelected: isCollapsedSelected,
              showKeyCap: allowKeyCaps && isAltPressed,
              ghostStyle: collapsedGhostStyle,
              selectedStyle: collapsedSelectedStyle,
              onActivate: () => openFolderFlyout(item),
            ),
          );
        } else {
          final isFolderExpanded =
              includeAnchorKeys && _expandedFolderId == folderId;
          final isArmedFolder =
              allowKeyCaps && includeAnchorKeys && _armedFolderId == folderId;
          final isRowSelected = !includeAnchorKeys
              ? isCollapsedSelected
              : (isFlyoutOwner || isArmedFolder);

          railChildren.add(
            _ExpandedRailFolder(
              anchorKey: includeAnchorKeys ? _anchorKeyFor(item) : null,
              folder: item,
              isExpanded: isFolderExpanded,
              isFlyoutSelected: isRowSelected,
              showTopKeyCap: showTopKeyCaps,
              showChildKeyCaps: allowKeyCaps && isFolderExpanded && isArmedFolder,
              ghostStyle: expandedGhostStyle,
              selectedStyle: expandedSelectedStyle,
              onToggleExpanded: !includeAnchorKeys
                  ? () => openFolderFlyout(item)
                  : () => _toggleExpandedFolder(item),
              onChildTap: (child) {
                _closeActiveFlyout();
                setState(() {
                  _expandedFolderId = folderId;
                  _armedFolderId = null;
                });
                child.onTap?.call();
              },
            ),
          );
        }
      } else {
        final isDirectSelected = hasActiveFlyout || item.isPrimaryAction
            ? false
            : item.isSelected;

        if (!isExpandedView) {
          railChildren.add(
            _buildCollapsedNavItem(
              context,
              anchorKey: includeAnchorKeys ? _anchorKeyFor(item) : null,
              item: item,
              isSelected: isDirectSelected,
              showKeyCap: allowKeyCaps && isAltPressed,
              ghostStyle: item.isPrimaryAction
                  ? collapsedPrimaryStyle
                  : collapsedGhostStyle,
              selectedStyle: item.isPrimaryAction
                  ? collapsedPrimaryStyle
                  : collapsedSelectedStyle,
              onActivate: () => _activateItem(item),
            ),
          );
        } else {
          railChildren.add(
            shad.SelectedButton(
              key: includeAnchorKeys ? _anchorKeyFor(item) : null,
              value: isDirectSelected,
              style: item.isPrimaryAction
                  ? expandedPrimaryStyle
                  : expandedGhostStyle,
              selectedStyle: item.isPrimaryAction
                  ? expandedPrimaryStyle
                  : expandedSelectedStyle,
              onChanged: (_) => _activateItem(item),
              child: _buildExpandedRowContent(
                context,
                icon: item.icon,
                label: item.label,
                keyChar: showTopKeyCaps ? item.shortcutKey : null,
                isSelected: isDirectSelected,
                isPrimaryAction: item.isPrimaryAction,
              ),
            ),
          );
        }
      }

      if (item.hasTrailingDivider) {
        railChildren.add(const shad.NavigationDivider());
      }
    }

    final headerWidget = !includeAnchorKeys
        ? (widget.floatingExpandedHeader ?? widget.header)
        : widget.header;

    return shad.NavigationRail(
      backgroundColor: level0Background,
      alignment: shad.NavigationRailAlignment.start,
      direction: Axis.vertical,
      expanded: isExpandedView,
      collapsedSize: resolvedCollapsedSize,
      expandedSize: widget.expandedWidth * scaling,
      spacing: gapUnit * shad.gapXs,
      padding: EdgeInsets.all(railPad),
      labelType: shad.NavigationLabelType.none,
      labelPosition: shad.NavigationLabelPosition.end,
      labelSize: shad.NavigationLabelSize.large,
      header: headerWidget != null ? [headerWidget] : null,
      footer: widget.footerItems.isNotEmpty ? widget.footerItems : null,
      children: railChildren,
    );
  }

  shad.NavigationItem _buildCollapsedNavItem(
    BuildContext context, {
    Key? anchorKey,
    required DynamicSidebarNavItem item,
    required bool isSelected,
    required bool showKeyCap,
    required shad.AbstractButtonStyle ghostStyle,
    required shad.AbstractButtonStyle selectedStyle,
    required VoidCallback onActivate,
  }) {
    return shad.NavigationItem(
      key: anchorKey,
      selected: isSelected,
      style: ghostStyle,
      selectedStyle: selectedStyle,
      alignment: Alignment.center,
      onChanged: (_) => onActivate(),
      label: Text(item.label),
      child: _buildCollapsedIconOrKeyCap(
        context,
        icon: item.icon,
        keyChar: item.shortcutKey,
        showKeyCap: showKeyCap,
        isPrimaryAction: item.isPrimaryAction,
      ),
    );
  }

  Widget _buildCollapsedIconOrKeyCap(
    BuildContext context, {
    IconData? icon,
    String? keyChar,
    required bool showKeyCap,
    bool isPrimaryAction = false,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final iconMdSize = _iconMd(theme);
    final hasKey = keyChar != null && keyChar.isNotEmpty;
    final iconColor =
        isPrimaryAction ? colors.primaryForeground : colors.foreground;

    return SizedBox(
      width: iconMdSize,
      height: iconMdSize,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 120),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: showKeyCap && hasKey
            ? _RailKeyCap(
                key: ValueKey('cap_${keyChar.toUpperCase()}'),
                label: keyChar.toUpperCase(),
                isPrimaryAction: isPrimaryAction,
              )
            : Center(
                key: const ValueKey('icon'),
                child: icon != null
                    ? Icon(icon, size: iconMdSize, color: iconColor)
                    : SizedBox(width: iconMdSize, height: iconMdSize),
              ),
      ),
    );
  }
}

Widget _buildExpandedRowContent(
  BuildContext context, {
  required IconData? icon,
  required String label,
  String? keyChar,
  required bool isSelected,
  bool isPrimaryAction = false,
  Widget? trailing,
}) {
  final theme = shad.Theme.of(context);
  final colors = theme.colorScheme;
  final contentColor =
      isPrimaryAction ? colors.primaryForeground : colors.foreground;

  return Row(
    children: [
      if (icon != null)
        Icon(icon, size: _iconMd(theme), color: contentColor),
      const shad.DensityGap(shad.gapSm),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.small.copyWith(
            fontWeight:
                (isSelected || isPrimaryAction) ? FontWeight.w600 : FontWeight.w500,
            color: contentColor,
          ),
        ),
      ),
      if (!_isAndroidPlatform && keyChar != null && keyChar.isNotEmpty) ...[
        const shad.DensityGap(shad.gapXs),
        _RailKeyCap(
          label: keyChar.toUpperCase(),
          isPrimaryAction: isPrimaryAction,
        ),
      ],
      if (trailing != null) ...[
        const shad.DensityGap(shad.gapXs),
        trailing,
      ],
    ],
  );
}

class _ExpandedRailFolder extends StatelessWidget {
  final GlobalKey? anchorKey;
  final DynamicSidebarNavItem folder;
  final bool isExpanded;
  final bool isFlyoutSelected;
  final bool showTopKeyCap;
  final bool showChildKeyCaps;
  final shad.AbstractButtonStyle ghostStyle;
  final shad.AbstractButtonStyle selectedStyle;
  final VoidCallback onToggleExpanded;
  final ValueChanged<DynamicSidebarNavItem> onChildTap;

  const _ExpandedRailFolder({
    required this.anchorKey,
    required this.folder,
    required this.isExpanded,
    required this.isFlyoutSelected,
    required this.showTopKeyCap,
    required this.showChildKeyCaps,
    required this.ghostStyle,
    required this.selectedStyle,
    required this.onToggleExpanded,
    required this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final gapUnit = theme.density.baseGap * scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        shad.SelectedButton(
          key: anchorKey,
          value: isFlyoutSelected,
          style: ghostStyle,
          selectedStyle: selectedStyle,
          onChanged: (_) => onToggleExpanded(),
          child: _buildExpandedRowContent(
            context,
            icon: folder.icon,
            label: folder.label,
            keyChar: showTopKeyCap ? folder.shortcutKey : null,
            isSelected: isFlyoutSelected,
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.25 : 0.0,
              duration: shad.kDefaultDuration,
              child: Icon(
                shad.LucideIcons.chevronRight,
                size: _iconSm(theme),
                color: colors.foreground,
              ),
            ),
          ),
        ),
        ClipRect(
          child: ExcludeFocus(
            excluding: !isExpanded,
            child: shad.AnimatedValueBuilder<double>(
              value: isExpanded ? 1.0 : 0.0,
              duration: shad.kDefaultDuration,
              curve: Curves.easeInOut,
              builder: (context, progress, child) {
                final clamped = progress.clamp(0.0, 1.0);
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: clamped,
                  child: Opacity(opacity: clamped, child: child),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: gapUnit * shad.gapXs),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: padUnit * shad.padSm,
                          end: gapUnit * shad.gapSm,
                        ),
                        child: SizedBox(
                          width: 1.0,
                          child: ColoredBox(color: colors.border),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: gapUnit * shad.gapXs,
                          children: folder.children.map((child) {
                            return shad.SelectedButton(
                              key: ValueKey(
                                'rail_child_${folder.id ?? folder.label}_${child.id ?? child.label}',
                              ),
                              value: child.isSelected,
                              style: ghostStyle,
                              selectedStyle: selectedStyle,
                              onChanged: (_) => onChildTap(child),
                              child: _buildExpandedRowContent(
                                context,
                                icon: child.icon,
                                label: child.label,
                                keyChar:
                                    showChildKeyCaps ? child.shortcutKey : null,
                                isSelected: child.isSelected,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RailKeyCap extends StatelessWidget {
  final String label;
  final bool isPrimaryAction;

  const _RailKeyCap({
    super.key,
    required this.label,
    this.isPrimaryAction = false,
  });

  @override
  Widget build(BuildContext context) {
    if (_isAndroidPlatform) return const SizedBox.shrink();

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final capExtent = _iconMd(theme);
    final bgColor =
        isPrimaryAction ? colors.primaryForeground : colors.mutedForeground;
    final textColor =
        isPrimaryAction ? colors.primary : colors.primaryForeground;

    return shad.OutlinedContainer(
      width: capExtent,
      height: capExtent,
      theme: shad.OutlinedContainerTheme(
        backgroundColor: bgColor,
        borderColor: bgColor,
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        padding: EdgeInsets.zero,
      ),
      child: Center(
        child: Text(
          label,
          style: theme.typography.xSmall.merge(theme.typography.mono).copyWith(
                fontWeight: FontWeight.w700,
                height: 1.0,
                color: textColor,
              ),
        ),
      ),
    );
  }
}

class _SidebarFolderFlyout extends StatefulWidget {
  final DynamicSidebarNavItem folder;
  final ValueChanged<DynamicSidebarNavItem> onSelectChild;
  final VoidCallback onDismiss;

  const _SidebarFolderFlyout({
    required this.folder,
    required this.onSelectChild,
    required this.onDismiss,
  });

  @override
  State<_SidebarFolderFlyout> createState() => _SidebarFolderFlyoutState();
}

class _SidebarFolderFlyoutState extends State<_SidebarFolderFlyout> {
  late int _highlightedIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final selectedIdx = widget.folder.children.indexWhere((c) => c.isSelected);
    _highlightedIndex = selectedIdx >= 0 ? selectedIdx : -1;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final hw = HardwareKeyboard.instance;
    if (hw.isAltPressed || hw.isControlPressed || hw.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final count = widget.folder.children.length;
    if (count == 0) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlightedIndex =
          _highlightedIndex < 0 ? 0 : (_highlightedIndex + 1) % count);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() => _highlightedIndex = _highlightedIndex < 0
          ? count - 1
          : (_highlightedIndex - 1 + count) % count);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      widget.onSelectChild(
          widget.folder.children[_highlightedIndex >= 0 ? _highlightedIndex : 0]);
      return KeyEventResult.handled;
    }
    final label = key.keyLabel.trim().toUpperCase();
    if (label.length == 1) {
      for (final child in widget.folder.children) {
        if ((child.shortcutKey ?? '').toUpperCase() == label) {
          widget.onSelectChild(child);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;
    final isDark = colors.brightness == Brightness.dark;
    final gapUnit = theme.density.baseGap * scaling;
    final padUnit = theme.density.baseContainerPadding * scaling;
    final selectedBgColor = DyColorSystem.resolveSelectItem(isDark, colors);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: padUnit * 13, maxWidth: padUnit * 16),
        child: shad.MenuPopup(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: gapUnit * shad.gapSm,
                vertical: gapUnit * shad.gapXs,
              ),
              child: Text(
                widget.folder.label,
                style: theme.typography.p.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
              ),
            ),
            const shad.Divider(),
            const shad.DensityGap(shad.gapXs),
            for (int i = 0; i < widget.folder.children.length; i++)
              _buildFlyoutRow(
                context,
                theme,
                colors,
                selectedBgColor,
                widget.folder.children[i],
                i,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlyoutRow(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    Color selectedBgColor,
    DynamicSidebarNavItem item,
    int index,
  ) {
    final gapUnit = theme.density.baseGap * theme.scaling;
    final isHighlighted = _highlightedIndex == index;
    final isSelected = item.isSelected;
    final rowRadius = BorderRadius.circular(theme.radiusMd);

    return MouseRegion(
      onEnter: (_) {
        if (_highlightedIndex != index) setState(() => _highlightedIndex = index);
      },
      child: shad.Button.ghost(
        alignment: AlignmentDirectional.centerStart,
        style: const shad.ButtonStyle.ghost().copyWith(
          padding: (ctx, state, pad) => EdgeInsets.all(gapUnit * shad.gapSm),
          decoration: (ctx, state, decoration) {
            final base = decoration as BoxDecoration? ?? const BoxDecoration();
            if (isSelected) {
              return base.copyWith(color: selectedBgColor, borderRadius: rowRadius);
            }
            if (isHighlighted || state.hovered) {
              return base.copyWith(color: colors.accent, borderRadius: rowRadius);
            }
            return base;
          },
        ),
        onPressed: () => widget.onSelectChild(item),
        child: _buildExpandedRowContent(
          context,
          icon: item.icon,
          label: item.label,
          keyChar: _isAndroidPlatform ? null : item.shortcutKey,
          isSelected: isSelected,
        ),
      ),
    );
  }
}
