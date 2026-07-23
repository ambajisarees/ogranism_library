import 'package:flutter/material.dart' hide Colors;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Model for an item inside the [PageHeader] Module Switcher
class ModuleItem<T> {
  final T id;
  final String label;
  final IconData icon;
  final int count;

  const ModuleItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.count,
  });
}

/// [PageHeader] - Modular, production-grade top page header with an optional
/// inline expandable Module Switcher, optional tabs slot, and action button slots.
class PageHeader<T> extends StatefulWidget {
  final String title;
  final String? subtitle;

  // Optional Module Switcher
  final T? selectedModuleId;
  final List<ModuleItem<T>>? modules;
  final ValueChanged<T>? onModuleSelected;

  // Optional Tabs Slot
  final Widget? tabs;

  // Optional Trailing Actions (max 1 primary, 2 secondary)
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.selectedModuleId,
    this.modules,
    this.onModuleSelected,
    this.tabs,
    this.actions = const [],
  }) : assert(actions.length <= 3, 'PageHeader can take at most 3 actions (1 primary, 2 secondary)');

  @override
  State<PageHeader<T>> createState() => _PageHeaderState<T>();
}

class _PageHeaderState<T> extends State<PageHeader<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _selectModule(T moduleId) {
    if (widget.onModuleSelected != null) {
      widget.onModuleSelected!(moduleId);
    }
    // Smooth reverse slide-up animation on module selection
    setState(() {
      _isExpanded = false;
      _animController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    // Find currently selected module item if any
    final selectedModule = widget.modules?.where((m) => m.id == widget.selectedModuleId).firstOrNull ??
        widget.modules?.firstOrNull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================
        // 1. TOP HEADER ROW
        // ==========================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Mandatory Title & Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: theme.typography.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const shad.DensityGap(shad.gapXs),
                  Text(
                    widget.subtitle!,
                    style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                  ),
                ],
              ],
            ),

            // 2. Optional Module Switcher Trigger Button
            if (widget.modules != null && widget.modules!.isNotEmpty && selectedModule != null) ...[
              const shad.DensityGap(shad.gapMd),
              shad.OutlineButton(
                onPressed: _toggleExpand,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selectedModule.icon, size: 16 * theme.scaling, color: colors.primary),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      selectedModule.label,
                      style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    shad.SecondaryBadge(
                      child: Text(
                        selectedModule.count.toString(),
                        style: theme.typography.xSmall.copyWith(
                          fontSize: 10 * theme.scaling,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const shad.DensityGap(shad.gapSm),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        shad.LucideIcons.chevronDown,
                        size: 14 * theme.scaling,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 3. Optional Tabs Slot
            if (widget.tabs != null) ...[
              const shad.DensityGap(shad.gapLg),
              widget.tabs!,
            ],

            // 4. Spacer
            const Spacer(),

            // 5. Trailing Actions Row (max 1 primary, 2 secondary)
            if (widget.actions.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions.map((act) {
                  return Padding(
                    padding: EdgeInsets.only(left: 8 * theme.scaling),
                    child: act,
                  );
                }).toList(),
              ),
            ],
          ],
        ),

        // ==========================================
        // 2. SMOOTH EXPANDABLE INLINE MODULE STRIP
        // ==========================================
        if (widget.modules != null && widget.modules!.isNotEmpty)
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Padding(
                padding: EdgeInsets.only(top: 12 * theme.scaling),
                child: Container(
                  padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * shad.padSm),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8 * theme.scaling),
                        child: Text(
                          'MODULE SELECTION',
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.mutedForeground,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8 * theme.scaling,
                        runSpacing: 8 * theme.scaling,
                        children: widget.modules!.map((mod) {
                          final isSelected = mod.id == widget.selectedModuleId;
                          return isSelected
                              ? shad.PrimaryButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => _selectModule(mod.id),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(mod.icon, size: 14 * theme.scaling),
                                      const shad.DensityGap(shad.gapSm),
                                      Text(mod.label),
                                      const shad.DensityGap(shad.gapSm),
                                      shad.SecondaryBadge(
                                        child: Text(
                                          mod.count.toString(),
                                          style: theme.typography.xSmall.copyWith(
                                            fontSize: 10 * theme.scaling,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : shad.OutlineButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => _selectModule(mod.id),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(mod.icon, size: 14 * theme.scaling, color: colors.mutedForeground),
                                      const shad.DensityGap(shad.gapSm),
                                      Text(mod.label),
                                      const shad.DensityGap(shad.gapSm),
                                      shad.OutlineBadge(
                                        child: Text(
                                          mod.count.toString(),
                                          style: theme.typography.xSmall.copyWith(
                                            fontSize: 10 * theme.scaling,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
