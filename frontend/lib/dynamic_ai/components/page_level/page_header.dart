import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro_level/micro_button.dart';

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

  late FocusNode _moduleTriggerFocusNode;
  late List<FocusNode> _moduleStripFocusNodes;

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

    _moduleTriggerFocusNode = FocusNode();
    _moduleStripFocusNodes = List.generate(
      widget.modules?.length ?? 0,
      (_) => FocusNode(),
    );
    // Initial load focus policy: NONE (Tab for the first time moves focus to header)
  }

  @override
  void dispose() {
    _animController.dispose();
    _moduleTriggerFocusNode.dispose();
    for (final fn in _moduleStripFocusNodes) {
      fn.dispose();
    }
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        debugPrint('[PageHeader] Module strip expanded -> Shifting focus to 1st module button');
        _animController.forward();
        // Shift focus directly to 1st module button in slide-down strip
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _moduleStripFocusNodes.isNotEmpty) {
            _moduleStripFocusNodes.first.requestFocus();
          }
        });
      } else {
        _animController.reverse();
      }
    });
  }

  void _selectModule(T moduleId) {
    debugPrint('[PageHeader] Module selected: $moduleId -> Unfocusing primary focus');
    if (widget.onModuleSelected != null) {
      widget.onModuleSelected!(moduleId);
    }
    // Smooth reverse slide-up animation on module selection & unfocus
    setState(() {
      _isExpanded = false;
      _animController.reverse();
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    // Find currently selected module item if any
    final selectedModule = widget.modules?.where((m) => m.id == widget.selectedModuleId).firstOrNull ??
        widget.modules?.firstOrNull;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // ==========================================
        // 1. TOP HEADER ROW (Crisp Vertical Alignment)
        // ==========================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Mandatory Title
            Text(
              widget.title,
              style: theme.typography.h2.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),

            // 2. Optional Module Switcher Trigger Button (MicroButton with FocusNode)
            if (widget.modules != null && widget.modules!.isNotEmpty && selectedModule != null) ...[
              const shad.DensityGap(shad.gapMd),
              MicroButton(
                focusNode: _moduleTriggerFocusNode,
                leadingIcon: selectedModule.icon,
                label: selectedModule.label,
                badgeCount: selectedModule.count,
                trailingIcon: _isExpanded ? shad.LucideIcons.chevronUp : shad.LucideIcons.chevronDown,
                isSelected: true,
                onPressed: _toggleExpand,
              ),
            ],

            // 3. Optional Tabs Slot
            if (widget.tabs != null) ...[
              const shad.DensityGap(shad.gapLg),
              widget.tabs!,
            ],

            // 4. Spacer (Pushes actions to far right)
            const Spacer(),

            // 5. Trailing Actions Row (max 1 primary, 2 secondary)
            if (widget.actions.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
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
        // 2. SMOOTH EXPANDABLE INLINE MODULE STRIP (Borderless, No Title, Left-Aligned)
        // ==========================================
        if (widget.modules != null && widget.modules!.isNotEmpty)
          SizeTransition(
            sizeFactor: _expandAnimation,
            alignment: Alignment.topLeft,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Padding(
                padding: EdgeInsets.only(top: 10 * theme.scaling),
                child: Wrap(
                  spacing: 8 * theme.scaling,
                  runSpacing: 8 * theme.scaling,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: widget.modules!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mod = entry.value;
                    final isSelected = mod.id == widget.selectedModuleId;
                    final focusNode = index < _moduleStripFocusNodes.length ? _moduleStripFocusNodes[index] : null;

                    return MicroButton(
                      focusNode: focusNode,
                      leadingIcon: mod.icon,
                      label: mod.label,
                      badgeCount: mod.count,
                      isSelected: isSelected,
                      onPressed: () => _selectModule(mod.id),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
