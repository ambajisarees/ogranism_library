import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../models/production/model_cutting.dart';
import '../../../../../models/production/model_media.dart';
import '../../../../../services/production/service_media.dart';
import '../../../../../organism_design/index.dart';

/// [CuttingDetailCanvas] — Renders the detailed view of a selected Cutting Batch.
class CuttingDetailCanvas extends StatelessWidget {
  final CuttingBatchSummaryModel summary;
  final List<CuttingCardModel> siblingCards;
  final List<MediaModel> batchMedia;
  final bool loadingTimeline;
  final bool loadingBatchDetail;
  final Map<String, DateTime?> timelineDates;
  final VoidCallback onEdit;
  final Function(String side) onUploadScan;

  const CuttingDetailCanvas({
    super.key,
    required this.summary,
    required this.siblingCards,
    required this.batchMedia,
    required this.loadingTimeline,
    required this.loadingBatchDetail,
    required this.timelineDates,
    required this.onEdit,
    required this.onUploadScan,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    // Resolve Investment & Cost per Saree
    double totalInvestment = summary.totalInvestment ?? 0.0;
    if (totalInvestment <= 0) {
      for (final sibling in siblingCards) {
        totalInvestment += (sibling.wmts * sibling.rate) + (sibling.rmts * sibling.jobRate);
      }
    }
    double costPerPc = summary.costPerPc ?? 0.0;
    if (costPerPc <= 0 && summary.totalFreshPcs > 0) {
      costPerPc = totalInvestment / summary.totalFreshPcs;
    }

    // Media Front / Back filtering
    MediaModel? frontMedia;
    MediaModel? backMedia;
    for (final m in batchMedia) {
      if (m.side == 'F') {
        frontMedia = m;
      } else if (m.side == 'B') {
        backMedia = m;
      }
    }

    // Grid layout for Selected Lot Cards (rows of 6)
    final List<Widget> lotRows = [];
    if (siblingCards.isNotEmpty) {
      for (int i = 0; i < siblingCards.length; i += 6) {
        final chunk = siblingCards.sublist(
          i, 
          i + 6 > siblingCards.length ? siblingCards.length : i + 6
        );
        
        lotRows.add(
          Row(
            children: [
              ...chunk.map((sibling) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildSectionLotCard(context, colors, sibling),
                ),
              )),
              if (chunk.length < 6)
                ...List.generate(6 - chunk.length, (index) => const Expanded(child: SizedBox.shrink())),
            ],
          )
        );
        
        if (i + 6 < siblingCards.length) {
          lotRows.add(const SizedBox(height: 12));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(OrganismTheme.radiusMd),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. STICKY HEADER ──────────────────────────────────────
            Container(
              color: colors.surface,
              padding: const EdgeInsets.fromLTRB(
                OrganismTheme.spacingLg,
                OrganismTheme.spacingLg,
                OrganismTheme.spacingLg,
                OrganismTheme.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            summary.ccCode,
                            style: OrganismTheme.displayLarge(context),
                          ),
                          const SizedBox(width: 12),
                          CellBadge(
                            text: summary.sbStatus.toUpperCase(),
                            variant: summary.sbStatus.toUpperCase() == 'COMPLETED'
                                ? CellBadgeVariant.success
                                : CellBadgeVariant.primary,
                          ),
                        ],
                      ),
                      TissueButtonBar(
                        children: [
                          CellButton(
                            text: 'Print',
                            icon: LucideIcons.printer,
                            variant: CellButtonVariant.outline,
                            onPressed: null, // disabled for now
                          ),
                          CellButton(
                            text: 'Edit',
                            icon: LucideIcons.edit2,
                            variant: CellButtonVariant.primary,
                            onPressed: onEdit,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TissueReadOnlyField(
                          label: 'Mill Processing House',
                          value: summary.mill,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TissueReadOnlyField(
                          label: 'Base Grey Quality',
                          value: summary.greyQual,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildScanThumbnail(
                          context: context,
                          colors: colors,
                          title: 'FRONT SCAN',
                          side: 'F',
                          media: frontMedia,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildScanThumbnail(
                          context: context,
                          colors: colors,
                          title: 'BACK SCAN',
                          side: 'B',
                          media: backMedia,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: colors.border, height: 1, thickness: 1),

            // ── 2. SCROLLABLE BODY ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Production Lifecycle Timeline
                    Text(
                      'PRODUCTION LIFECYCLE PROGRESS',
                      style: OrganismTheme.titleMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    loadingTimeline
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : DomainCuttingTimeline(stageDates: timelineDates),
                    const SizedBox(height: OrganismTheme.spacingLg),
                    const Divider(),
                    const SizedBox(height: OrganismTheme.spacingLg),

                    // KPI Cards
                    Text(
                      'METRICS',
                      style: OrganismTheme.titleMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DomainKpiTile(
                            label: 'Fresh output'.toUpperCase(),
                            value: OrganismFormat.number(summary.totalFreshPcs),
                            unit: 'pcs',
                          ),
                        ),
                        const SizedBox(width: OrganismTheme.spacingMd),
                        Expanded(
                          child: DomainKpiTile(
                            label: 'Second output'.toUpperCase(),
                            value: OrganismFormat.number(summary.totalSecondPcs),
                            unit: 'pcs',
                          ),
                        ),
                        const SizedBox(width: OrganismTheme.spacingMd),
                        Expanded(
                          child: DomainKpiTile(
                            label: 'cut length'.toUpperCase(),
                            value: summary.cutLength.toStringAsFixed(2),
                            unit: 'mts',
                          ),
                        ),
                        const SizedBox(width: OrganismTheme.spacingMd),
                        Expanded(
                          child: DomainKpiTile(
                            label: 'saree weight'.toUpperCase(),
                            value: '${(summary.avgWt * 1000).toInt()}',
                            unit: 'g',
                          ),
                        ),
                        const SizedBox(width: OrganismTheme.spacingMd),
                        Expanded(
                          child: DomainKpiTile(
                            label: 'total investment'.toUpperCase(),
                            value: totalInvestment >= 100000 
                                ? (totalInvestment / 100000).toStringAsFixed(2)
                                : OrganismFormat.number(totalInvestment),
                            unit: totalInvestment >= 100000 ? 'Lakhs' : 'inr',
                          ),
                        ),
                        const SizedBox(width: OrganismTheme.spacingMd),
                        Expanded(
                          child: DomainKpiTile(
                            label: 'cost per pc'.toUpperCase(),
                            value: OrganismFormat.currency(costPerPc, decimals: 2),
                            unit: '/ saree',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OrganismTheme.spacingLg),
                    const Divider(),
                    const SizedBox(height: OrganismTheme.spacingLg),

                    // Selected Lot Rolls
                    Text(
                      'SELECTED GREY LOT ROLLS (${siblingCards.length})',
                      style: OrganismTheme.titleMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    loadingBatchDetail
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : siblingCards.isEmpty
                            ? TissueEmptyState(
                                icon: LucideIcons.layers,
                                title: 'No Lot Cards',
                                message: 'No rolls selected for this batch.',
                              )
                            : Column(
                                children: lotRows,
                              ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Divider(color: colors.border, height: 1, thickness: 1),

            // ── 3. STICKY FOOTER ──────────────────────────────────────
            Container(
              color: colors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: OrganismTheme.spacingLg,
                vertical: OrganismTheme.spacingMd,
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.user, size: 14, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Creator: ${(siblingCards.isNotEmpty && siblingCards.first.creator.isNotEmpty ? siblingCards.first.creator : "N/A").toUpperCase()}',
                    style: OrganismTheme.bodySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(LucideIcons.calendar, size: 14, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Create Time: ${siblingCards.isNotEmpty && siblingCards.first.createTime != null ? OrganismFormat.dateTime(siblingCards.first.createTime!) : OrganismFormat.dateTime(summary.cutDate)}',
                    style: OrganismTheme.bodySmall(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanThumbnail({
    required BuildContext context,
    required OrganismColors colors,
    required String title,
    required String side,
    required MediaModel? media,
  }) {
    final publicUrl = media != null ? MediaService().getPublicUrl(media.filePath) : '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: OrganismTheme.labelSmall(context).copyWith(
            color: colors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: media != null 
              ? () => _openMediaOverlay(context, publicUrl) 
              : () => onUploadScan(side),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
              border: Border.all(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: media != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        MediaService().getPublicUrl(media.filePath, width: 100, height: 100),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(LucideIcons.fileImage, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          media.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.uploadCloud, size: 16, color: colors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Upload',
                        style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _openMediaOverlay(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      barrierLabel: 'Close Image',
      pageBuilder: (context, _, __) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child: Center(
                  child: Image.network(url),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: SafeArea(
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionLotCard(
      BuildContext context, OrganismColors colors, CuttingCardModel sibling) {
    // Days ago calculation
    String daysAgoText = 'N/A';
    if (sibling.cutDate != null) {
      final diff = DateTime.now().difference(sibling.cutDate!).inDays;
      if (diff <= 0) {
        daysAgoText = 'Today';
      } else if (diff == 1) {
        daysAgoText = '1 day ago';
      } else {
        daysAgoText = '$diff days ago';
      }
    }

    return CellBox(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
      border: Border.all(color: colors.border),
      backgroundColor: colors.surfaceSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  '${sibling.reccardno}',
                  style: OrganismTheme.bodySmall(context).copyWith(
                    fontFamily: 'Mono',
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lot',
                style: OrganismTheme.bodySmall(context).copyWith(
                  color: colors.textMuted,
                ),
              ),
              Text(
                sibling.lot,
                style: OrganismTheme.bodyMedium(context).copyWith(
                  fontFamily: 'Mono',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mts',
                style: OrganismTheme.labelSmall(context).copyWith(
                  color: colors.textMuted,
                ),
              ),
              Text(
                'Pcs',
                style: OrganismTheme.labelSmall(context).copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sibling.rmts.toStringAsFixed(1),
                style: OrganismTheme.bodyMedium(context).copyWith(
                  fontFamily: 'Mono',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${sibling.pieces.toInt()}',
                style: OrganismTheme.bodyMedium(context).copyWith(
                  fontFamily: 'Mono',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 8),
          Text(
            daysAgoText,
            textAlign: TextAlign.center,
            style: OrganismTheme.bodySmall(context).copyWith(
              fontStyle: FontStyle.italic,
              color: colors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
