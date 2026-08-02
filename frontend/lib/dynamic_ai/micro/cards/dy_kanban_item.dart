/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC KANBAN CARD ITEM (dy_kanban_item.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Micro-level interactive card tile widget rendered inside Kanban stage columns (DyKanbanPane).
   - Displays Voucher No, Party Name, Design Pattern, Quantity, Amount, and Status Badge.
   - Provides hover animations, subtle elevation border, and click selection feedback.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses native `shadcn_flutter` color tokens (`colors.card`, `colors.accent`, `colors.border`).
   - Uses native typography (`textSmall`, `xSmall`, `mono`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../specs/dy_color_system.dart';

/// Data class representing a Kanban card item.
class DyKanbanItem {
  final String id;
  final String title;
  final String voucherNo;
  final String partyName;
  final String designPattern;
  final String quantity;
  final String amount;
  final String status;
  final Widget? statusBadge;
  final Map<String, dynamic>? rawData;

  const DyKanbanItem({
    required this.id,
    required this.title,
    required this.voucherNo,
    required this.partyName,
    required this.designPattern,
    required this.quantity,
    required this.amount,
    required this.status,
    this.statusBadge,
    this.rawData,
  });
}

/// [DyKanbanCard] — Card tile widget rendered inside DyKanbanPane.
class DyKanbanCard extends StatefulWidget {
  final DyKanbanItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const DyKanbanCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DyKanbanCard> createState() => _DyKanbanCardState();
}

class _DyKanbanCardState extends State<DyKanbanCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    final background = widget.isSelected || _isHovered
        ? DyColorSystem.resolveRootBackground(isDark)
        : colors.card;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.all(12 * theme.scaling),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(
              color: widget.isSelected
                  ? colors.primary
                  : (_isHovered ? colors.border.withAlpha(200) : colors.border),
              width: widget.isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Voucher No & Status Badge
              Row(
                children: [
                  Text(
                    widget.item.voucherNo,
                    style: theme.typography.mono.copyWith(
                      fontSize: 12 * theme.scaling,
                      fontWeight: FontWeight.w600,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const Spacer(),
                  widget.item.statusBadge ??
                      shad.OutlineBadge(child: Text(widget.item.status)),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Party Name / Weaver Title
              Text(
                widget.item.partyName,
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Row 3: Design & Quality Subtitle
              Text(
                widget.item.title,
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Row 4: Quantity & Amount (Mono metric row)
              Row(
                children: [
                  Text(
                    widget.item.quantity,
                    style: theme.typography.mono.copyWith(
                      fontSize: 12 * theme.scaling,
                      color: colors.mutedForeground,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.item.amount,
                    style: theme.typography.mono.copyWith(
                      fontSize: 13 * theme.scaling,
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
