import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';

/// A single command context element.
class CommandPaletteAction {
  final String id;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onSelect;

  const CommandPaletteAction({
    required this.id,
    required this.label,
    required this.onSelect,
    this.subtitle,
    this.icon,
  });
}

/// [TissueCommandPalette] — Cmd+K / Omnibox Command Palette
/// Used via `TissueCommandPalette.show(...)`.
class TissueCommandPalette extends StatefulWidget {
  final List<CommandPaletteAction> actions;
  final String placeholder;

  const TissueCommandPalette({
    super.key,
    required this.actions,
    this.placeholder = 'Search commands...',
  });

  static Future<void> show(
    BuildContext context, {
    required List<CommandPaletteAction> actions,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Command Palette',
      transitionDuration: OrganismTheme.durationFast,
      pageBuilder: (context, anim, secondAnim) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: TissueCommandPalette(actions: actions),
          ),
        );
      },
    );
  }

  @override
  State<TissueCommandPalette> createState() => _TissueCommandPaletteState();
}

class _TissueCommandPaletteState extends State<TissueCommandPalette> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<CommandPaletteAction> _filteredActions = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredActions = widget.actions;
    _searchController.addListener(_filter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredActions = widget.actions.where((action) {
        return action.label.toLowerCase().contains(query) ||
               (action.subtitle != null && action.subtitle!.toLowerCase().contains(query));
      }).toList();
      _selectedIndex = 0;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _executeSelected() {
    if (_filteredActions.isNotEmpty && _selectedIndex < _filteredActions.length) {
      final action = _filteredActions[_selectedIndex];
      Navigator.of(context).pop();
      action.onSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Use RawKeyboardListener or standard Focus
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              _selectedIndex = (_selectedIndex + 1) % _filteredActions.length;
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              _selectedIndex = (_selectedIndex - 1 + _filteredActions.length) % _filteredActions.length;
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _executeSelected();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: OrganismTheme.borderLg,
          border: Border.all(color: colors.border),
          boxShadow: OrganismTheme.shadowLg,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(OrganismTheme.spacingMd),
              child: CellInput(
                controller: _searchController,
                focusNode: _focusNode,
                placeholder: widget.placeholder,
                prefixIcon: LucideIcons.search,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingSm),
                itemCount: _filteredActions.length,
                itemBuilder: (context, index) {
                  final action = _filteredActions[index];
                  final isSelected = index == _selectedIndex;

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      action.onSelect();
                    },
                    child: Container(
                      color: isSelected ? colors.primary.withOpacity(0.05) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OrganismTheme.spacingLg,
                        vertical: OrganismTheme.spacingMd,
                      ),
                      child: Row(
                        children: [
                          if (action.icon != null) ...[
                            Icon(action.icon, color: isSelected ? colors.primary : colors.textMuted, size: 20),
                            const SizedBox(width: OrganismTheme.spacingMd),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action.label,
                                  style: OrganismTheme.bodyLarge(context).copyWith(
                                    color: isSelected ? colors.primary : colors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                                if (action.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    action.subtitle!,
                                    style: OrganismTheme.bodySmall(context),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(LucideIcons.cornerDownLeft, size: 16, color: colors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [TissueCommandPaletteLauncher] — Standardized search bar for launching the palette.
///
/// A high-fidelity, compact search cluster designed for the Topbar or sidebar.
/// Standard height: 32px. Internally handles shortcut visualization (Ctrl+K).
class TissueCommandPaletteLauncher extends StatefulWidget {
  final VoidCallback onTap;
  final String placeholder;
  final double width;

  const TissueCommandPaletteLauncher({
    super.key,
    required this.onTap,
    this.placeholder = 'Search...',
    this.width = 240,
  });

  @override
  State<TissueCommandPaletteLauncher> createState() => _TissueCommandPaletteLauncherState();
}

class _TissueCommandPaletteLauncherState extends State<TissueCommandPaletteLauncher> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Semantics(
      label: 'Search commands and masters',
      hint: 'Type or press Ctrl+K to search anything',
      button: true,
      container: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: widget.width,
          child: OrganismFocus(
            onTap: widget.onTap,
            borderRadius: OrganismTheme.borderMd,
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: OrganismTheme.durationFast,
                curve: OrganismTheme.curveStandard,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _isHovered ? colors.surfaceSubtle : colors.surface,
                  border: Border.all(
                    color: _isHovered ? colors.primary.withValues(alpha: 0.5) : colors.border,
                  ),
                  borderRadius: OrganismTheme.borderMd,
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(LucideIcons.search, size: 14, color: colors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OrganismTheme.bodySmall(context).copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    const ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CellKbd(keyString: 'Ctrl'),
                          SizedBox(width: 4),
                          CellKbd(keyString: 'K'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
