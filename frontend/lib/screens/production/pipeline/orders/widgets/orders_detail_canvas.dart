import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../models/production/model_jobwork.dart';
import '../../../../../models/production/model_media.dart';
import '../../../../../organism_design/index.dart';

/// [OrdersDetailCanvas] — Renders details for a selected Finish (O13) or Lace (O14) Purchase Order.
class OrdersDetailCanvas extends StatelessWidget {
  final JobReceiveModel order;
  final List<JobWorkDetailLineModel> detailLines;
  final List<MediaModel> attachedMedia;
  final bool isDetailLoading;
  final VoidCallback onAttachScan;
  final Function(String mediaId) onRemoveScan;

  const OrdersDetailCanvas({
    super.key,
    required this.order,
    required this.detailLines,
    required this.attachedMedia,
    required this.isDetailLoading,
    required this.onAttachScan,
    required this.onRemoveScan,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(fontSize: 14);

    final titlePrefix = order.type == 'O13' ? 'Finish PO' : 'Lace PO';

    return OrganSectionCanvas(
      title: '$titlePrefix #${order.vno}',
      actions: const [
        CellButton(
          text: 'Print',
          icon: LucideIcons.printer,
          variant: CellButtonVariant.ghost,
        ),
      ],
      children: [
        // Section 1: Header Metadata
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Vendor / Khata'),
                  TissueCardContent(
                    child: Text(
                      order.tailorName ?? order.tailorCode,
                      style: OrganismTheme.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Order Date'),
                  TissueCardContent(
                    child: Text(
                      order.date.toIso8601String().split('T')[0],
                      style: monoStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Challan Number'),
                  TissueCardContent(
                    child: Text(
                      order.challanNo?.isNotEmpty == true ? order.challanNo! : 'N/A',
                      style: monoStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Bill Number'),
                  TissueCardContent(
                    child: Text(
                      order.billNo?.isNotEmpty == true ? order.billNo! : 'N/A',
                      style: monoStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section 2: Summary Metrics
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TissueCardHeader(title: 'Summary Metrics'),
            TissueCardContent(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(context, colors, 'TOTAL METERS', '${order.totMts.toStringAsFixed(1)} M'),
                  _buildMetric(context, colors, 'TOTAL PIECES', '${order.totPcs} Pcs'),
                  _buildMetric(context, colors, 'FINAL AMT', '₹${order.finalAmt.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section 3: Detail lines
        Text('ORDER DETAIL LINES', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        if (isDetailLoading)
          Column(
            children: List.generate(
              3,
              (idx) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const CellSkeleton(width: 28, height: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CellSkeleton(width: 160 + (idx * 10.0), height: 14),
                          const SizedBox(height: 6),
                          const CellSkeleton(width: 120, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (detailLines.isEmpty)
          CellBox(
            padding: const EdgeInsets.all(OrganismTheme.spacingLg),
            child: Center(
              child: Text(
                'No line items found for this order.',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(2.5),
              },
              children: [
                // Table Header
                TableRow(
                  decoration: BoxDecoration(color: colors.surfaceMuted),
                  children: [
                    _buildTableHeaderCell(context, colors, '#'),
                    _buildTableHeaderCell(context, colors, 'Item Quality'),
                    _buildTableHeaderCell(context, colors, 'Meters'),
                    _buildTableHeaderCell(context, colors, 'Pcs'),
                    _buildTableHeaderCell(context, colors, 'Rate'),
                    _buildTableHeaderCell(context, colors, 'Amount'),
                  ],
                ),
                // Table Rows
                ...detailLines.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final line = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colors.border)),
                    ),
                    children: [
                      _buildTableCell(context, colors, '$idx', isMono: true),
                      _buildTableCell(context, colors, line.quality),
                      _buildTableCell(context, colors, line.meters.toStringAsFixed(1), isMono: true),
                      _buildTableCell(context, colors, '${line.pieces.toInt()}', isMono: true),
                      _buildTableCell(context, colors, '₹${line.rate.toStringAsFixed(2)}', isMono: true),
                      _buildTableCell(context, colors, '₹${line.amt.toStringAsFixed(2)}', isMono: true, isBold: true),
                    ],
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 32),

        // Section 4: Media Attachments
        Text('ATTACHED ORDER DOCUMENTS', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        _buildMediaAttachments(context, colors, monoStyle),
      ],
    );
  }

  Widget _buildMetric(BuildContext context, OrganismColors colors, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: OrganismTheme.labelSmall(context).copyWith(
            color: colors.textMuted,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          value,
          style: OrganismTheme.monoBody(context).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(BuildContext context, OrganismColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text.toUpperCase(),
        style: OrganismTheme.labelSmall(context).copyWith(
          color: colors.textMuted,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    BuildContext context,
    OrganismColors colors,
    String text, {
    bool isMono = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: (isMono ? OrganismTheme.monoBody(context) : OrganismTheme.bodyMedium(context)).copyWith(
          color: colors.textPrimary,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMediaAttachments(BuildContext context, OrganismColors colors, TextStyle monoStyle) {
    return CellBox(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      child: attachedMedia.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: attachedMedia.map((media) {
                    final imageUrl = media.filePath;
                    return Container(
                      width: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            color: colors.surfaceSubtle,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(LucideIcons.fileImage, size: 28),
                            ),
                          ),
                          Container(
                            color: colors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    media.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 12),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  color: colors.error,
                                  onPressed: () => onRemoveScan(media.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CellButton(
                    text: 'Attach Another Document',
                    icon: LucideIcons.plus,
                    variant: CellButtonVariant.outline,
                    isCompact: true,
                    onPressed: onAttachScan,
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                children: [
                  Icon(LucideIcons.fileImage, size: 28, color: colors.textMuted),
                  const SizedBox(height: 8),
                  const Text('No physical scans attached.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  CellButton(
                    text: 'Attach Scan',
                    icon: LucideIcons.plus,
                    variant: CellButtonVariant.outline,
                    isCompact: true,
                    onPressed: onAttachScan,
                  ),
                ],
              ),
            ),
    );
  }
}
