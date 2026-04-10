import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'index.dart'; // Grants access to OrganismTheme and Cells

/// A composable layout boundary replacing hardcoded static cards.
/// Provides exact ERP physical mapping (1px solid border, surface fill).
class TissueCard extends StatelessWidget {
  final List<Widget> children;
  final bool hasShadow;
  final EdgeInsetsGeometry padding;

  const TissueCard({
    super.key,
    required this.children,
    this.hasShadow = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        borderRadius: OrganismTheme.borderLg,
        border: Border.all(color: OrganismTheme.border),
        boxShadow: hasShadow ? OrganismTheme.shadowSm : null,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

/// The top composition layer of a TissueCard ensuring exact padding matrices.
class TissueCardHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;

  const TissueCardHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OrganismTheme.titleMedium),
                if (description != null) ...[
                  const SizedBox(height: OrganismTheme.spacingXs),
                  Text(description!, style: OrganismTheme.bodyMedium),
                ]
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// The body composition layer of a TissueCard mapping exact internal padding.
class TissueCardContent extends StatelessWidget {
  final Widget child;

  const TissueCardContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: OrganismTheme.spacingLg,
        right: OrganismTheme.spacingLg,
        bottom: OrganismTheme.spacingLg,
      ),
      child: child,
    );
  }
}

/// The massive top-level block defining an active screen route in the ERP.
class TissuePageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const TissuePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OrganismTheme.displayLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: OrganismTheme.spacingSm),
                  Text(subtitle!, style: OrganismTheme.bodyLarge.copyWith(color: OrganismTheme.textSecondary)),
                ]
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Standardized Composition of Form Elements: Label + Input + Error
class TissueFormField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? errorText;
  final Widget inputCell; // Expects a CellInput, CellCheckbox, or TissueDropdown

  const TissueFormField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.errorText,
    required this.inputCell,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CellLabel(text: label, isRequired: isRequired),
        const SizedBox(height: OrganismTheme.spacingSm),
        inputCell,
        if (errorText != null) ...[
          const SizedBox(height: OrganismTheme.spacingXs),
          Text(errorText!, style: OrganismTheme.bodySmall.copyWith(color: OrganismTheme.error)),
        ]
      ],
    );
  }
}

/// Headless layout block for uneditable system values ensuring layout 
/// symmetry with editable forms.
class TissueReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;

  const TissueReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: OrganismTheme.labelLarge.copyWith(color: OrganismTheme.stone500)),
        const SizedBox(height: OrganismTheme.spacingXs),
        Text(
          value, 
          style: (isMono ? OrganismTheme.code : OrganismTheme.bodyLarge).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// A Composed Dropdown mapping the physical borders of CellInput 
/// to native Flutter picker engines.
class TissueDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final bool isDisabled;
  final bool hasError;

  const TissueDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.placeholder,
    this.isDisabled = false,
    this.hasError = false,
  });

  @override
  State<TissueDropdown<T>> createState() => _TissueDropdownState<T>();
}

class _TissueDropdownState<T> extends State<TissueDropdown<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = OrganismTheme.border;
    if (widget.hasError) {
      borderColor = OrganismTheme.error;
    } else if (_isHovered && !widget.isDisabled) {
      borderColor = OrganismTheme.stone400; // Hover border mapping
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: Container(
        height: OrganismTheme.buttonHeightStandard,
        padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
        decoration: BoxDecoration(
          color: widget.isDisabled ? OrganismTheme.stone100 : OrganismTheme.surface,
          borderRadius: OrganismTheme.borderSm,
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.centerLeft,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.isDisabled ? null : widget.onChanged,
            isDense: true,
            isExpanded: true,
            icon: const Icon(LucideIcons.chevronsUpDown, size: OrganismTheme.iconSizeSm, color: OrganismTheme.iconSecondary),
            style: OrganismTheme.bodyLarge,
            dropdownColor: OrganismTheme.surface,
            borderRadius: OrganismTheme.borderMd,
            hint: widget.placeholder != null ? Text(widget.placeholder!, style: OrganismTheme.bodyLarge.copyWith(color: OrganismTheme.textMuted)) : null,
          ),
        ),
      ),
    );
  }
}

/// Standardized Alert banners for system feedback.
class TissueAlert extends StatelessWidget {
  final String title;
  final String? message;
  final CellBadgeVariant variant; 
  final IconData icon;

  const TissueAlert({
    super.key,
    required this.title,
    this.message,
    this.variant = CellBadgeVariant.secondary,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = OrganismTheme.stone100;
    Color border = OrganismTheme.stone200;
    Color text = OrganismTheme.stone900;
    
    if (variant == CellBadgeVariant.error) {
      bg = const Color(0xFFFEF2F2); // Red 50 equivalent
      border = const Color(0xFFFECACA); 
      text = OrganismTheme.error;
    } else if (variant == CellBadgeVariant.warning) {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      text = OrganismTheme.warning;
    } else if (variant == CellBadgeVariant.success) {
      bg = const Color(0xFFF0FDF4);
      border = const Color(0xFFBBF7D0);
      text = OrganismTheme.success;
    } else if (variant == CellBadgeVariant.primary) {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      text = OrganismTheme.primary;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: OrganismTheme.iconSizeMd,
            color: text,
          ),
          const SizedBox(width: OrganismTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OrganismTheme.labelLarge.copyWith(color: text, fontWeight: FontWeight.w700)),
                if (message != null) ...[
                  const SizedBox(height: OrganismTheme.spacingXs),
                  Text(message!, style: OrganismTheme.bodyMedium.copyWith(color: text.withOpacity(0.9))),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Fallback state when SQL queries return no data.
class TissueEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const TissueEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OrganismTheme.spacing2Xl),
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        borderRadius: OrganismTheme.borderLg,
        border: Border.all(color: OrganismTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(OrganismTheme.spacingLg),
            decoration: const BoxDecoration(
              color: OrganismTheme.stone100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: OrganismTheme.iconSizeLg,
              color: OrganismTheme.iconSecondary,
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingLg),
          Text(title, style: OrganismTheme.titleMedium),
          const SizedBox(height: OrganismTheme.spacingSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: OrganismTheme.bodyMedium.copyWith(color: OrganismTheme.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: OrganismTheme.spacingLg),
            action!
          ]
        ],
      ),
    );
  }
}

/// Headless pagination component mapping to primary action buttons.
enum TissuePaginationVariant { standard, compact }

class TissuePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final TissuePaginationVariant variant;
  final ValueChanged<int> onPageChanged;

  const TissuePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.variant = TissuePaginationVariant.standard,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == TissuePaginationVariant.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CellButton(
            icon: LucideIcons.chevronLeft,
            variant: CellButtonVariant.outline,
            onPressed: currentPage <= 1 ? null : () => onPageChanged(currentPage - 1),
            text: '',
          ),
          const SizedBox(width: OrganismTheme.spacingSm),
          Text('Page $currentPage of $totalPages', style: OrganismTheme.bodySmall),
          const SizedBox(width: OrganismTheme.spacingSm),
          CellButton(
            icon: LucideIcons.chevronRight,
            variant: CellButtonVariant.outline,
            onPressed: currentPage >= totalPages ? null : () => onPageChanged(currentPage + 1),
            text: '',
          ),
        ],
      );
    }

    // Standard Variant
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CellButton(
          text: 'Previous',
          variant: CellButtonVariant.outline,
          onPressed: currentPage <= 1 ? null : () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: OrganismTheme.spacingMd),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(totalPages, (index) {
                final pageStr = (index + 1).toString();
                final isSelected = currentPage == (index + 1);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: CellButton(
                    text: pageStr,
                    variant: isSelected ? CellButtonVariant.outline : CellButtonVariant.ghost,
                    onPressed: () => onPageChanged(index + 1),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: OrganismTheme.spacingMd),
        CellButton(
          text: 'Next',
          variant: CellButtonVariant.outline,
          onPressed: currentPage >= totalPages ? null : () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }
}

/// Highly compressed navigation list grouping blocks of data dynamically.
enum TissueTabsVariant { pill, underline }

class TissueTabs extends StatefulWidget {
  final List<String> tabs;
  final int initialIndex;
  final TissueTabsVariant variant;
  final ValueChanged<int>? onChanged;

  const TissueTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.variant = TissueTabsVariant.pill,
    this.onChanged,
  });

  @override
  State<TissueTabs> createState() => _TissueTabsState();
}

class _TissueTabsState extends State<TissueTabs> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == TissueTabsVariant.underline) {
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: OrganismTheme.border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.tabs.asMap().entries.map((entry) {
            final isSelected = _currentIndex == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = entry.key);
                if (widget.onChanged != null) widget.onChanged!(entry.key);
              },
              child: AnimatedContainer(
                duration: OrganismTheme.durationFast,
                curve: OrganismTheme.curveStandard,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? OrganismTheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value,
                  style: OrganismTheme.labelLarge.copyWith(
                    color: isSelected ? OrganismTheme.textPrimary : OrganismTheme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Pill variant
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: OrganismTheme.stone100,
        borderRadius: OrganismTheme.borderMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.tabs.asMap().entries.map((entry) {
          final isSelected = _currentIndex == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() => _currentIndex = entry.key);
              if (widget.onChanged != null) widget.onChanged!(entry.key);
            },
            child: AnimatedContainer(
              duration: OrganismTheme.durationFast,
              curve: OrganismTheme.curveStandard,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? OrganismTheme.surface : Colors.transparent,
                borderRadius: OrganismTheme.borderSm,
                boxShadow: isSelected ? OrganismTheme.shadowSm : null,
              ),
              child: Text(
                entry.value,
                style: OrganismTheme.labelLarge.copyWith(
                  color: isSelected ? OrganismTheme.textPrimary : OrganismTheme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// The universal List rendering component mapping to the Slot Architecture.
/// Massively replaces list_card_1, list_card_2, list_card_3, and featureCard
/// by composing Cells dynamically.
class TissueListCard extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? footer;
  
  final bool isCompact;
  final bool isSelected;
  final VoidCallback? onTap;

  const TissueListCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.footer,
    this.isCompact = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<TissueListCard> createState() => _TissueListCardState();
}

class _TissueListCardState extends State<TissueListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double paddingValue = widget.isCompact ? OrganismTheme.spacingMd : OrganismTheme.spacingLg;
    
    Color borderColor = widget.isSelected ? OrganismTheme.primary : OrganismTheme.border;
    Color bgColor = widget.isSelected ? OrganismTheme.primaryLight : OrganismTheme.surface;
    
    if (_isHovered && widget.onTap != null && !widget.isSelected) {
      borderColor = OrganismTheme.stone400; // Hover tracing corresponding to Cell border states
      bgColor = OrganismTheme.stone100;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.all(paddingValue),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: OrganismTheme.borderMd,
            border: Border.all(color: borderColor, width: widget.isSelected ? 1.5 : 1.0),
            boxShadow: _isHovered && widget.onTap != null ? OrganismTheme.shadowSm : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: paddingValue),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null) widget.title!,
                        if (widget.title != null && widget.subtitle != null) ...[
                          const SizedBox(height: 2), // Tight mapping
                          widget.subtitle!,
                        ] else if (widget.subtitle != null) ...[
                          widget.subtitle!
                        ]
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    SizedBox(width: paddingValue),
                    widget.trailing!,
                  ]
                ],
              ),
              if (widget.footer != null) ...[
                SizedBox(height: paddingValue),
                widget.footer!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Exact +/- stepper control geometry
class TissueStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const TissueStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: OrganismTheme.border),
        borderRadius: OrganismTheme.borderSm,
        color: OrganismTheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CellButton(
            text: '', // icon only
            icon: LucideIcons.minus,
            variant: CellButtonVariant.ghost,
            onPressed: () => onChanged(value - 1),
          ),
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(value.toString(), style: OrganismTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          ),
          CellButton(
            text: '', // icon only
            icon: LucideIcons.plus,
            variant: CellButtonVariant.ghost,
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class PipelineStageData {
  final String label;
  final bool isCompleted;
  final bool isActive;

  const PipelineStageData({
    required this.label,
    this.isCompleted = false,
    this.isActive = false,
  });
}

/// A sequential tracking visualizer natively handling standard stages line traces.
class TissuePipeline extends StatelessWidget {
  final List<PipelineStageData> stages;

  const TissuePipeline({
    super.key,
    required this.stages,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Connector Line
              final int prevStageIndex = index ~/ 2;
              final bool isLineActive = stages[prevStageIndex].isCompleted;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isLineActive ? OrganismTheme.primary : OrganismTheme.stone200,
                ),
              );
            } else {
              // Node
              final stageIndex = index ~/ 2;
              final stage = stages[stageIndex];
              
              Color nodeBgColor = OrganismTheme.surface;
              Color nodeBorderColor = OrganismTheme.stone300;
              Color nodeTextColor = OrganismTheme.textSecondary;
              
              if (stage.isCompleted) {
                nodeBgColor = OrganismTheme.primary;
                nodeBorderColor = OrganismTheme.primary;
                nodeTextColor = Colors.white;
              } else if (stage.isActive) {
                nodeBgColor = OrganismTheme.primaryLight;
                nodeBorderColor = OrganismTheme.primary;
                nodeTextColor = OrganismTheme.primary;
              }
              
              return Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: nodeBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: nodeBorderColor, width: stage.isActive ? 2 : 1),
                    ),
                    child: stage.isCompleted 
                        ? const Icon(
                            LucideIcons.check,
                            size: OrganismTheme.iconSizeXs,
                            color: Colors.white,
                          )
                        : Text('${stageIndex + 1}', style: OrganismTheme.bodySmall.copyWith(color: nodeTextColor, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: OrganismTheme.spacingSm),
                  Text(stage.label, style: OrganismTheme.bodyMedium.copyWith(color: stage.isActive ? OrganismTheme.textPrimary : nodeTextColor, fontWeight: stage.isActive ? FontWeight.w600 : FontWeight.w400)),
                ],
              );
            }
          }),
        );
      }
    );
  }
}

/// A headless-style Select trigger that uses PlasmaPopover.
class TissueSelect<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String? placeholder;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T> onChanged;

  const TissueSelect({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CellLabel(text: label),
        const SizedBox(height: OrganismTheme.spacingSm),
        PlasmaPopover(
          trigger: Container(
            height: OrganismTheme.buttonHeightStandard,
            padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
            decoration: BoxDecoration(
              color: OrganismTheme.surface,
              borderRadius: OrganismTheme.borderSm,
              border: Border.all(color: OrganismTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? itemLabelBuilder(value!) : (placeholder ?? 'Select option'),
                  style: OrganismTheme.bodyLarge.copyWith(
                    color: value != null ? OrganismTheme.textPrimary : OrganismTheme.textMuted,
                  ),
                ),
                Icon(
                  LucideIcons.chevronsUpDown,
                  size: OrganismTheme.iconSizeSm,
                  color: OrganismTheme.iconSecondary,
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final isSelected = item == value;
              return TissueListCard(
                isCompact: true,
                isSelected: isSelected,
                onTap: () => onChanged(item),
                title: Text(itemLabelBuilder(item), style: OrganismTheme.labelLarge),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// A High-Density Shadcn-style DatePicker.
/// Uses PlasmaPopover to anchor a calendar grid.
class TissueDatePicker extends StatefulWidget {
  final DateTime? value;
  final String label;
  final ValueChanged<DateTime> onChanged;

  const TissueDatePicker({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<TissueDatePicker> createState() => _TissueDatePickerState();
}

class _TissueDatePickerState extends State<TissueDatePicker> {
  @override
  Widget build(BuildContext context) {
    final dateStr = widget.value != null 
        ? "${widget.value!.day.toString().padLeft(2, '0')}/${widget.value!.month.toString().padLeft(2, '0')}/${widget.value!.year}"
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CellLabel(text: widget.label),
        const SizedBox(height: OrganismTheme.spacingSm),
        PlasmaPopover(
          trigger: Container(
            height: OrganismTheme.buttonHeightStandard,
            padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingMd),
            decoration: BoxDecoration(
              color: OrganismTheme.surface,
              borderRadius: OrganismTheme.borderSm,
              border: Border.all(color: OrganismTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: OrganismTheme.bodyLarge.copyWith(
                    color: widget.value != null ? OrganismTheme.textPrimary : OrganismTheme.textMuted,
                  ),
                ),
                Icon(
                  LucideIcons.calendar,
                  size: OrganismTheme.iconSizeSm,
                  color: OrganismTheme.iconSecondary,
                ),
              ],
            ),
          ),
          content: _TissueCalendar(
            initialDate: widget.value ?? DateTime.now(),
            onDateSelected: (date) {
              widget.onChanged(date);
              // Note: Popover closing is handled by the PlasmaPopover's internal barrier logic usually,
              // but we might want an explicit close here. Adding a Navigator.pop check if needed.
            },
          ),
        ),
      ],
    );
  }
}

/// Private high-density calendar grid.
class _TissueCalendar extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const _TissueCalendar({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_TissueCalendar> createState() => _TissueCalendarState();
}

class _TissueCalendarState extends State<_TissueCalendar> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _prevMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));
  void _nextMonth() => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final firstDayOffset = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    
    final monthName = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_viewMonth.month - 1];

    return Container(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: OrganismTheme.iconSizeMd),
                onPressed: _prevMonth,
              ),
              Text('$monthName ${_viewMonth.year}', style: OrganismTheme.labelLarge),
              IconButton(
                icon: const Icon(LucideIcons.chevronRight, size: OrganismTheme.iconSizeMd),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: OrganismTheme.spacingMd),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Center(child: Text(d, style: OrganismTheme.bodySmall.copyWith(color: OrganismTheme.textMuted))))
                .toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox.shrink();
              final day = index - firstDayOffset + 1;
              final date = DateTime(_viewMonth.year, _viewMonth.month, day);
              final isSelected = DateUtils.isSameDay(date, widget.initialDate);
              
              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? OrganismTheme.primary : Colors.transparent,
                    borderRadius: OrganismTheme.borderSm,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: OrganismTheme.bodySmall.copyWith(
                        color: isSelected ? Colors.white : OrganismTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A clean, 1px bordered accordion matching Shadcn's standard Collapsible component. 
class TissueAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  const TissueAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<TissueAccordion> createState() => _TissueAccordionState();
}

class _TissueAccordionState extends State<TissueAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        border: Border(bottom: BorderSide(color: OrganismTheme.border)), // Shadcn standard accordion only borders bottom usually
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: OrganismTheme.titleMedium.copyWith(fontWeight: FontWeight.w500)),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: OrganismTheme.durationStandard,
                    curve: OrganismTheme.curveStandard,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: OrganismTheme.iconSizeSm,
                      color: OrganismTheme.iconSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: OrganismTheme.spacingLg),
              child: widget.content, // Renders the interior tissue children
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: OrganismTheme.durationStandard,
            sizeCurve: OrganismTheme.curveStandard,
          )
        ],
      ),
    );
  }
}

/// Models a single menu item for TissueMenu
class TissueMenuItemData {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const TissueMenuItemData({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
  });
}

/// Natively maps Shadcn's DropdownMenu onto a standard flutter PopupMenu with exact dimensional scaling.
class TissueMenu extends StatelessWidget {
  final Widget child; // Trigger
  final List<TissueMenuItemData> items;

  const TissueMenu({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: OrganismTheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: OrganismTheme.borderMd,
        side: BorderSide(color: OrganismTheme.border),
      ),
      tooltip: '', // Override native long-press tooltip
      child: child,
      itemBuilder: (context) {
        return items.asMap().entries.map((entry) {
          final item = entry.value;
          final color = item.isDestructive ? OrganismTheme.error : OrganismTheme.textPrimary;
          return PopupMenuItem<int>(
            value: entry.key,
            onTap: item.onTap,
            height: 40,
            textStyle: OrganismTheme.bodyMedium.copyWith(color: color),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: OrganismTheme.iconSizeSm,
                    color: color,
                  ),
                  const SizedBox(width: OrganismTheme.spacingMd),
                ],
                Text(item.label),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
