/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC TASKS SHELL (dy_shl_tasks.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Pipeline Kanban board & task card management page shell layout.
   - Encapsulates 4 stage columns (UNCUT, IN CUTTING, MILL DISPATCH, COMPLETED).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses `DyKanbanPane` for 4 stage columns.
   - Standardized layout framed directly under PageHeader.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../specs/dy_grid_system.dart';
import '../page/dy_kanban_pane.dart';
import '../micro/cards/dy_kanban_item.dart';

/// [DyShlTasks] — Page Shell Layout for Kanban Board Pipeline & Tasks.
class DyShlTasks extends StatelessWidget {
  final List<DyKanbanItem> items;

  const DyShlTasks({
    super.key,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    final sampleItems = items.isNotEmpty
        ? items
        : [
            const DyKanbanItem(
              id: 'k1',
              title: 'D-4089 Royal Silk Saree',
              voucherNo: 'CC-1041',
              partyName: 'Ambaji Silks & Textiles',
              designPattern: 'Lot #101',
              quantity: '45.0 Mts',
              amount: '₹37,890',
              status: 'UNCUT',
            ),
            const DyKanbanItem(
              id: 'k2',
              title: 'D-9012 Banarasi Zari Jaal',
              voucherNo: 'CC-1042',
              partyName: 'Vardhman Synthetics',
              designPattern: 'Lot #102',
              quantity: '38.5 Mts',
              amount: '₹35,100',
              status: 'IN CUTTING',
            ),
            const DyKanbanItem(
              id: 'k3',
              title: 'D-1055 Organza Floral Print',
              voucherNo: 'CC-1043',
              partyName: 'Kothari Weavers',
              designPattern: 'Lot #103',
              quantity: '52.0 Mts',
              amount: '₹43,000',
              status: 'MILL DISPATCH',
            ),
            const DyKanbanItem(
              id: 'k4',
              title: 'D-3301 Kanjivaram Border',
              voucherNo: 'CC-1044',
              partyName: 'Laxmi Digital Prints',
              designPattern: 'Lot #104',
              quantity: '60.0 Mts',
              amount: '₹51,200',
              status: 'COMPLETED',
            ),
          ];

    final stages = [
      {'title': 'UNCUT', 'color': const Color(0xFF3B82F6)},
      {'title': 'IN CUTTING', 'color': const Color(0xFFF59E0B)},
      {'title': 'MILL DISPATCH', 'color': const Color(0xFF8B5CF6)},
      {'title': 'COMPLETED', 'color': const Color(0xFF10B981)},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: stages.asMap().entries.map((entry) {
        final idx = entry.key;
        final stage = entry.value;
        final stageTitle = stage['title'] as String;
        final stageColor = stage['color'] as Color;
        final stageItems = sampleItems.where((i) => i.status == stageTitle).toList();

        return Expanded(
          flex: DyGridSystem.flexBoard4PaneEqual,
          child: Row(
            children: [
              Expanded(
                child: DyKanbanPane(
                  stageTitle: stageTitle,
                  stageColor: stageColor,
                  items: stageItems,
                  selectedItem: null,
                  onItemSelected: (_) {},
                  onAddItem: () {},
                ),
              ),
              if (idx < stages.length - 1) const shad.DensityGap(shad.gapLg),
            ],
          ),
        );
      }).toList(),
    );
  }
}
