/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC KANBAN PANE (dy_kanban_pane.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Page-level Kanban stage column pane framing a sticky header bar (Stage Title, 
     Count Badge, Status Indicator Dot), vertical scrollable list of DyKanbanCard 
     items, and sticky footer (+ Add Item button / count total).
   - Styled using native `shadcn_flutter` tokens and framed in `shad.OutlinedContainer`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Evaluates stage status matching (UNCUT, IN CUTTING, MILL DISPATCH, COMPLETED).
   - Strictly uses native `shadcn_flutter` color, typography, and density scaling.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../micro/cards/dy_kanban_item.dart';

/// [DyKanbanPane] — Vertical Kanban Stage Column Pane with Sticky Header and Footer.
class DyKanbanPane extends StatelessWidget {
  final String stageTitle;
  final Color stageColor;
  final List<DyKanbanItem> items;
  final DyKanbanItem? selectedItem;
  final ValueChanged<DyKanbanItem> onItemSelected;
  final VoidCallback? onAddItem;

  const DyKanbanPane({
    super.key,
    required this.stageTitle,
    required this.stageColor,
    required this.items,
    this.selectedItem,
    required this.onItemSelected,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      backgroundColor: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. STICKY HEADER: Stage Title + Indicator Dot + Count Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * theme.scaling,
              vertical: 10 * theme.scaling,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.brightness == Brightness.dark
                  ? const Color(0xFF141210)
                  : const Color(0xFFFCFDFE),
              border: Border(
                bottom: BorderSide(color: colors.border, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                // Status Color Indicator Dot
                Container(
                  width: 8 * theme.scaling,
                  height: 8 * theme.scaling,
                  decoration: BoxDecoration(
                    color: stageColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // Stage Title
                Expanded(
                  child: Text(
                    stageTitle,
                    style: theme.typography.textSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),

                // Item Count Badge
                shad.SecondaryBadge(
                  child: Text(
                    '${items.length}',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. VERTICAL SCROLLABLE CARDS BODY
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No cards in $stageTitle',
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(10 * theme.scaling),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 8 * theme.scaling),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selectedItem?.id == item.id;
                      return DyKanbanCard(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => onItemSelected(item),
                      );
                    },
                  ),
          ),

          // 3. STICKY FOOTER: + Add Card CTA / Summary
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * theme.scaling,
              vertical: 8 * theme.scaling,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.brightness == Brightness.dark
                  ? const Color(0xFF141210)
                  : const Color(0xFFFCFDFE),
              border: Border(
                top: BorderSide(color: colors.border, width: 1.0),
              ),
            ),
            child: shad.GhostButton(
              size: shad.ButtonSize.small,
              onPressed: onAddItem,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(shad.LucideIcons.plus, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Add Card',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
