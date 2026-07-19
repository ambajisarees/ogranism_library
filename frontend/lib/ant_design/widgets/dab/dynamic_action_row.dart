import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicActionOption {
  final String label;
  final Widget? icon;
  final String value;

  const DynamicActionOption({
    required this.label,
    this.icon,
    required this.value,
  });
}

class DynamicActionRow extends StatefulWidget {
  final Widget titleIcon;
  final String defaultLabel;
  final Widget defaultIcon;
  
  final String dynamicDefaultLabel;
  final List<DynamicActionOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;
  final WidgetBuilder? popoverBuilder;

  const DynamicActionRow({
    super.key,
    required this.titleIcon,
    required this.defaultLabel,
    required this.defaultIcon,
    this.dynamicDefaultLabel = 'None',
    this.options = const [],
    required this.selectedValue,
    required this.onSelected,
    this.popoverBuilder,
  });

  @override
  State<DynamicActionRow> createState() => _DynamicActionRowState();
}

class _DynamicActionRowState extends State<DynamicActionRow> {
  void _showOptionsPopover(BuildContext context) {
    final theme = shad.Theme.of(context);
    shad.showOverlay(
      context,
      shad.PopoverConfiguration(
        alignment: Alignment.topRight,
        anchorAlignment: Alignment.bottomRight,
        allowInvertVertical: false,
        offset: Offset(0, theme.density.baseContainerPadding * shad.padX2s),
        builder: (context) {
          if (widget.popoverBuilder != null) {
            return widget.popoverBuilder!(context);
          }
          return shad.ModalContainer(
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.options.map<Widget>((opt) {
                  final isOptionSelected = widget.selectedValue == opt.value;
                  return shad.Button(
                    onPressed: () {
                      widget.onSelected(opt.value);
                      shad.closeOverlay(context);
                    },
                    style: const shad.ButtonStyle.ghost().copyWith(
                      padding: (context, states, value) => EdgeInsets.symmetric(
                        vertical: 8 * theme.scaling,
                        horizontal: 8 * theme.scaling,
                      ),
                      mouseCursor: (context, states, value) => SystemMouseCursors.click,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (opt.icon != null) ...[
                              opt.icon!,
                              const shad.DensityGap(shad.gapSm),
                            ],
                            Text(opt.label),
                          ],
                        ),
                        if (isOptionSelected)
                          const Icon(shad.LucideIcons.check),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // Parse Yearless Format for Dynamic Chips: YYYY-MM-DD:YYYY-MM-DD -> Month Day - Month Day
  String _getYearlessDateString(String range) {
    final parts = range.split(':');
    if (parts.length != 2) return range;
    final startDt = DateTime.tryParse(parts[0]);
    final endDt = DateTime.tryParse(parts[1]);
    if (startDt == null || endDt == null) return range;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final startStr = '${months[startDt.month - 1]} ${startDt.day}';
    final endStr = '${months[endDt.month - 1]} ${endDt.day}';
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final wrapSpacing = theme.density.baseGap * shad.gapSm;

    final isDefaultSelected = widget.selectedValue == null;
    final selectedOption = widget.options.firstWhere(
      (opt) => opt.value == widget.selectedValue,
      orElse: () => const DynamicActionOption(label: '', value: ''),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title Icon
        IconTheme(
          data: IconThemeData(color: theme.colorScheme.mutedForeground),
          child: widget.titleIcon,
        ),
        const shad.DensityGap(shad.gapSm),
        
        // 3-Chip layout
        Wrap(
          spacing: wrapSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Chip 1: Default Option
            shad.Chip(
              style: isDefaultSelected
                  ? const shad.ButtonStyle.primary()
                  : const shad.ButtonStyle.outline(),
              leading: widget.defaultIcon,
              onPressed: () => widget.onSelected(null),
              child: Text(
                widget.defaultLabel,
                style: theme.typography.textSmall.copyWith(
                  fontWeight: isDefaultSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            
            // Chip 2: Dynamic Option with Popover
            Builder(
              builder: (context) {
                var displayLabel = widget.dynamicDefaultLabel;
                if (!isDefaultSelected) {
                  if (selectedOption.label.isNotEmpty) {
                    displayLabel = selectedOption.label;
                  } else if (widget.selectedValue != null && widget.selectedValue!.contains(':')) {
                    // It is a custom yearless range string
                    displayLabel = _getYearlessDateString(widget.selectedValue!);
                  } else {
                    displayLabel = widget.selectedValue!;
                  }
                }
                
                final displayIcon = !isDefaultSelected ? selectedOption.icon : null;
                
                return shad.Chip(
                  style: !isDefaultSelected
                      ? const shad.ButtonStyle.primary()
                      : const shad.ButtonStyle.outline(),
                  leading: displayIcon,
                  trailing: const Icon(shad.LucideIcons.ellipsisVertical),
                  onPressed: () => _showOptionsPopover(context),
                  child: Text(
                    displayLabel,
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: !isDefaultSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }
            ),

            // Chip 3: Destructive/Clear Option
            if (!isDefaultSelected)
              shad.Chip(
                style: const shad.ButtonStyle.destructive(),
                onPressed: () => widget.onSelected(null),
                child: const Icon(shad.LucideIcons.x),
              ),
          ],
        ),
      ],
    );
  }
}
