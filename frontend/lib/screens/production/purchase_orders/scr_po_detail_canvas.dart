/*
================================================================================
LLM CONTEXT & QUERY SPACE — PO DETAIL CANVAS (scr_po_detail_canvas.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Detailed inspection canvas & line-items table for a selected Purchase Order header.
   - Renders PO summary metrics card (Party, Quality, Date, Final Amount) and fetches line-items.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Accepts module domain model `MdlPoHeader`.
   - Uses `SrvPo` to fetch detail line items (`MdlPoLineItem`).
   - Requires composite join keys `CNO = header.cno AND VNO = header.vno AND TYPE = header.type`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Line item rate and amount fields default defensively (`?? 0.0`) when unpopulated in Airbyte sync.
   - Truncated text handles lengthy supplier names cleanly via native typography scaling.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Do Purchase Orders require attachment scan previews (PO PDF / Supplier Quotation scans) in this right-hand canvas?
================================================================================
*/

import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';

import '../../../models/production/mdl_po.dart';
import '../../../services/production/srv_po.dart';
import '../../../models/core/sq/sq_bills.dart';
import '../../../models/core/sq/sq_billdet.dart';
import '../../../dynamic_ai/components/page_level/dynamic_dense_table.dart';

/// [ScrPoDetailCanvas] — Detail inspection canvas & line-items table for Purchase Orders.
class ScrPoDetailCanvas extends StatefulWidget {
  final MdlPoHeader header;
  final VoidCallback? onClose;

  const ScrPoDetailCanvas({
    super.key,
    required this.header,
    this.onClose,
  });

  @override
  State<ScrPoDetailCanvas> createState() => _ScrPoDetailCanvasState();
}

class _ScrPoDetailCanvasState extends State<ScrPoDetailCanvas> {
  final SrvPo _poService = SrvPo();
  final NumberFormat _currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

  List<MdlPoLineItem> _lineItems = [];
  bool _isLoadingLineItems = true;

  @override
  void initState() {
    super.initState();
    _fetchLineItems();
  }

  @override
  void didUpdateWidget(covariant ScrPoDetailCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.header.vno != widget.header.vno || oldWidget.header.type != widget.header.type) {
      _fetchLineItems();
    }
  }

  Future<void> _fetchLineItems() async {
    setState(() {
      _isLoadingLineItems = true;
    });

    final items = await _poService.getPurchaseOrderLineItems(
      vno: widget.header.vno,
      type: widget.header.type,
      cno: widget.header.cno,
    );

    if (!mounted) return;
    setState(() {
      _lineItems = items;
      _isLoadingLineItems = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final h = widget.header;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header Info Card
        shad.Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        h.displayOrderNo,
                        style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      shad.Chip(
                        child: Text(h.type),
                      ),
                    ],
                  ),
                  if (widget.onClose != null)
                    shad.GhostButton(
                      onPressed: widget.onClose,
                      child: const Icon(Icons.close, size: 16),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      theme,
                      SqBillsLabels.party,
                      h.partyName.isNotEmpty ? h.partyName : 'N/A',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      theme,
                      SqBillsLabels.fabric,
                      h.quality.isNotEmpty ? h.quality : 'N/A',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      theme,
                      SqBillsLabels.date,
                      h.formattedDate,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      theme,
                      SqBillsLabels.finalAmt,
                      h.formattedFinalAmount(_currencyFmt),
                      isHighlight: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Line Items Table Section
        Expanded(
          child: shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Line Items (${_lineItems.length})',
                      style: theme.typography.h4.copyWith(fontSize: 14),
                    ),
                    if (_isLoadingLineItems)
                      Text('Loading...', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoadingLineItems
                      ? const Center(child: CircularProgressIndicator())
                      : _lineItems.isEmpty
                          ? Center(
                              child: Text(
                                'No line items found for ${h.displayOrderNo}',
                                style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                              ),
                            )
                          : DynamicDenseTable(
                              rows: _lineItems.map((item) => item.core.toRowData(_currencyFmt)).toList(),
                              columns: SqBilldetTableMapper.defaultColumns,
                            ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(shad.ThemeData theme, String label, String value, {bool isHighlight = false}) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.typography.xSmall.copyWith(color: colors.mutedForeground, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.typography.textSmall.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? colors.primary : colors.foreground,
          ),
        ),
      ],
    );
  }
}
