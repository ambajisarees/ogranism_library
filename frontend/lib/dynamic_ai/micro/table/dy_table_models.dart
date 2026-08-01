/// LLM NOTE: DyTable Data Models
/// - Level: Core Data Table Layer
/// - Purpose: Data model definitions for DyTable master coordinator, column specifications, row types, and pin states.

library;

import 'package:flutter/widgets.dart';

/// Tier level of row in the 3-tiered table hierarchy:
/// - [group]: Group summary row (Surface background token, semibold text, always has expand chevron)
/// - [def]: Primary document header row (Card surface background, foreground text, chevron only if child rows exist)
/// - [child]: Line items detail row (Card surface background, muted foreground text, right-aligned indented divider, no chevron)
enum DyTableRowType {
  group,
  def,
  child,
}

/// Column Specification model for [DyTable].
class DyTableColumnSpec {
  final String key;
  final String label;
  final double width;
  final int flex;
  final bool isNumeric;
  final bool isSortable;
  final bool isPinnedLeft;
  final bool isPinnedRight;
  final Alignment textAlignment;

  const DyTableColumnSpec({
    required this.key,
    required this.label,
    this.width = 120.0,
    this.flex = 1,
    this.isNumeric = false,
    this.isSortable = true,
    this.isPinnedLeft = false,
    this.isPinnedRight = false,
    this.textAlignment = Alignment.centerLeft,
  });
}

/// Dynamic Row Data model for [DyTable].
class DyTableRowData {
  final String id;
  final DyTableRowType rowType;
  final String? parentId;
  final String? voucherNo;
  final String? partyName;
  final String? imagePath;
  final String? title;
  final Map<String, dynamic> data;
  final List<DyTableRowData> children;
  final bool isExpanded;
  final bool isSelected;
  final Map<String, dynamic>? rawData;

  DyTableRowData({
    required this.id,
    this.rowType = DyTableRowType.def,
    this.parentId,
    String? voucherNo,
    String? partyName,
    String? designPattern,
    String? quantity,
    String? amount,
    double amountValue = 0.0,
    String? status,
    String? expandedDetails,
    this.imagePath,
    this.title,
    Map<String, dynamic>? data,
    List<DyTableRowData>? children,
    List<DyTableRowData>? childRows,
    this.isExpanded = false,
    this.isSelected = false,
    Map<String, dynamic>? rawData,
  })  : voucherNo = voucherNo ?? (data?['vno'] as String?),
        partyName = partyName ?? (data?['partyName'] as String?),
        children = children ?? childRows ?? const [],
        rawData = rawData ?? data,
        data = {
          if (voucherNo != null) 'vno': voucherNo,
          if (partyName != null) 'partyName': partyName,
          if (designPattern != null) 'designPattern': designPattern,
          if (quantity != null) 'quantity': quantity,
          if (amount != null) 'amount': amount,
          if (status != null) 'status': status,
          if (expandedDetails != null) 'expandedDetails': expandedDetails,
          ...?data,
          ...?rawData,
        };

  bool get hasChildren => children.isNotEmpty;
  List<DyTableRowData> get childRows => children;

  String? get designPattern => data['designPattern'] as String?;
  String? get quantity => data['quantity'] as String?;
  String? get amount => data['amount'] as String?;
  String? get status => data['status'] as String?;
  String? get expandedDetails => data['expandedDetails'] as String?;

  DyTableRowData copyWith({
    bool? isExpanded,
    bool? isSelected,
  }) {
    return DyTableRowData(
      id: id,
      rowType: rowType,
      parentId: parentId,
      voucherNo: voucherNo,
      partyName: partyName,
      imagePath: imagePath,
      title: title,
      data: data,
      children: children,
      isExpanded: isExpanded ?? this.isExpanded,
      isSelected: isSelected ?? this.isSelected,
      rawData: rawData,
    );
  }
}
