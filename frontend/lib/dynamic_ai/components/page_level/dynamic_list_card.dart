import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DynamicListItem {
  final String id;
  final String title; // Middle mandatory
  final String? amount; // Middle mandatory / metric (13px mono)
  
  // Row 1: Top Optional
  final Widget? topLeading; // e.g. Status badge
  final String? topTrailing; // e.g. Date or tag
  
  // Row 3: Bottom Optional
  final String? subtitle; // e.g. Description / Party subtitle
  final String? indexNumber; // e.g. #10481
  
  final Map<String, dynamic>? rawData;

  const DynamicListItem({
    required this.id,
    required this.title,
    this.amount,
    this.topLeading,
    this.topTrailing,
    this.subtitle,
    this.indexNumber,
    this.rawData,
  });
}

class DynamicListCard extends StatefulWidget {
  final DynamicListItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const DynamicListCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DynamicListCard> createState() => _DynamicListCardState();
}

class _DynamicListCardState extends State<DynamicListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    
    final background = widget.isSelected
        ? colors.accent
        : (_isHovered ? colors.accent.withValues(alpha: 0.5) : Colors.transparent);

    final hasTopRow = widget.item.topLeading != null || widget.item.topTrailing != null;
    final hasBottomRow = widget.item.subtitle != null || widget.item.indexNumber != null;
        
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            border: Border(
              bottom: BorderSide(
                color: colors.border,
                width: 1.0,
              ),
              left: BorderSide(
                color: widget.isSelected ? colors.primary : Colors.transparent,
                width: 3.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Top Optional (Status Chip -> Spacer -> Date)
              if (hasTopRow) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.item.topLeading ?? const SizedBox.shrink(),
                    const Spacer(),
                    if (widget.item.topTrailing != null)
                      Text(
                        widget.item.topTrailing!,
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              
              // Row 2: Middle Mandatory (Title -> Spacer -> Amount)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: theme.typography.textSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.item.amount != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.item.amount!,
                      style: theme.typography.mono.copyWith(
                        fontSize: 13 * theme.scaling,
                        fontWeight: FontWeight.w500,
                        color: colors.foreground,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Row 3: Bottom Optional (Subtitle -> Spacer -> Index Number)
              if (hasBottomRow) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.subtitle ?? '',
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.item.indexNumber != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        widget.item.indexNumber!,
                        style: theme.typography.mono.copyWith(
                          fontSize: 12 * theme.scaling,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
