import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:textile_erp/organism_design/index.dart';
import '../../../../models/production/model_jobwork.dart';
import '../../../../models/production/model_media.dart';
import '../../../../services/production/service_jobwork.dart';
import '../../../../services/production/service_media.dart';

/// [InwardTab] — Handles the Stitching Receive (O6) transaction registry,
/// detail canvas, and physical challan scan attachments. Ported from job_work_tab.dart.
class InwardTab extends StatefulWidget {
  const InwardTab({super.key});

  @override
  State<InwardTab> createState() => _InwardTabState();
}

class _InwardTabState extends State<InwardTab> {
  final _service = JobWorkService();

  List<JobReceiveModel> _receives = [];
  JobReceiveModel? _selectedReceive;

  List<JobWorkDetailLineModel> _detailLines = [];
  List<MediaModel> _attachedMedia = [];
  
  bool _isLoading = false;
  bool _isDetailLoading = false;

  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  String _searchTerm = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await _service.getJobReceives(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      if (mounted) {
        setState(() {
          _receives = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
          // Auto-select first item
          if (_receives.isNotEmpty && _selectedReceive == null) {
            _onReceiveSelected(_receives.first);
          }
        });
      }
    } catch (e) {
      debugPrint('Error in InwardTab._loadData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onReceiveSelected(JobReceiveModel receive) async {
    setState(() {
      _selectedReceive = receive;
      _isDetailLoading = true;
      _detailLines = [];
      _attachedMedia = [];
    });

    try {
      final lines = await _service.getJobWorkLines(receive.vno, 'O6');
      final media = await MediaService().getMediaForEntity('stitching_receive', receive.vno.toString());
      
      if (mounted && _selectedReceive?.vno == receive.vno) {
        setState(() {
          _detailLines = lines;
          _attachedMedia = media;
          _isDetailLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading details for receive #${receive.vno}: $e');
      if (mounted && _selectedReceive?.vno == receive.vno) {
        setState(() => _isDetailLoading = false);
      }
    }
  }

  Future<void> _attachChallanScan(int vno) async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes ?? await File(file.path!).readAsBytes();

        PlasmaToastManager.instance.show(context, 'Uploading scan...', variant: CellBadgeVariant.primary);

        await MediaService().uploadFile(
          bytes,
          file.name,
          bucket: 'production',
          entityType: 'stitching_receive',
          entityId: vno.toString(),
          entityLabel: 'O6 Receive #$vno',
          mediaType: 'challan_scan',
        );

        final media = await MediaService().getMediaForEntity('stitching_receive', vno.toString());
        if (mounted) {
          setState(() {
            _attachedMedia = media;
          });
          PlasmaToastManager.instance.show(context, 'Challan scan attached.', variant: CellBadgeVariant.success);
        }
      }
    } catch (e) {
      debugPrint('Error uploading challan scan: $e');
      if (mounted) {
        PlasmaToastManager.instance.show(context, 'Upload failed: $e', variant: CellBadgeVariant.error);
      }
    }
  }

  Future<void> _removeChallanScan(String mediaId, int vno) async {
    try {
      final confirm = await PlasmaAlertDialog.show(
        context: context,
        title: 'Delete Scan?',
        message: 'Are you sure you want to delete this challan scan?',
        isDestructive: true,
      );
      if (confirm != true) return;

      await MediaService().archiveMedia(mediaId);

      final media = await MediaService().getMediaForEntity('stitching_receive', vno.toString());
      if (mounted) {
        setState(() {
          _attachedMedia = media;
        });
        PlasmaToastManager.instance.show(context, 'Scan deleted.', variant: CellBadgeVariant.success);
      }
    } catch (e) {
      debugPrint('Error removing challan scan: $e');
    }
  }

  Widget _buildMetric(String label, String value) {
    final colors = OrganismTheme.colorsOf(context);
    return Column(
      children: [
        Text(label, style: OrganismTheme.labelMedium(context).copyWith(
          color: colors.textMuted,
          letterSpacing: 1.1,
        )),
        Text(value, style: OrganismTheme.monoBody(context).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        )),
      ],
    );
  }

  Widget _buildMediaAttachmentsSection(OrganismColors colors, TextStyle monoStyle, int vno) {
    return CellBox(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      child: _attachedMedia.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _attachedMedia.map((media) {
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
                              MediaService().getPublicUrl(media.filePath),
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
                                  onPressed: () => _removeChallanScan(media.id, vno),
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
                    text: 'Attach Another Challan',
                    icon: LucideIcons.plus,
                    variant: CellButtonVariant.outline,
                    isCompact: true,
                    onPressed: () => _attachChallanScan(vno),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                children: [
                  Icon(LucideIcons.fileImage, size: 28, color: colors.textMuted),
                  const SizedBox(height: 8),
                  const Text('No physical challan scans attached.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  CellButton(
                    text: 'Attach Challan Scan',
                    icon: LucideIcons.plus,
                    variant: CellButtonVariant.outline,
                    isCompact: true,
                    onPressed: () => _attachChallanScan(vno),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(fontSize: 14);

    return SystemAppMasterLayout(
      isDetailVisible: _selectedReceive != null,
      paneHeader: OrganPaneHeader(
        title: 'Job Receive (O6)',
        searchController: _searchController,
        onSearchChanged: (val) {
          setState(() {
            _searchTerm = val;
            _currentPage = 1;
            _selectedReceive = null;
          });
          _loadData();
        },
        searchPlaceholder: 'Search by Tailor...',
      ),
      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _receives.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (p) {
          setState(() {
            _currentPage = p;
            _selectedReceive = null;
          });
          _loadData();
        },
        itemBuilder: (context, index) {
          final item = _receives[index];
          final isSelected = _selectedReceive?.vno == item.vno;

          return TissueListCard(
            isSelected: isSelected,
            isCompact: false,
            showDivider: true,
            onTap: () => _onReceiveSelected(item),
            leading: CellCardAvatar(date: item.date),
            title: Text(
              item.tailorName ?? item.tailorCode,
              style: OrganismTheme.bodyLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Receipt No: ${item.vno} • ${item.totPcs} Pieces', style: OrganismTheme.bodySmall(context)),
            trailing: Text(
              'O6',
              style: monoStyle.copyWith(
                color: colors.success,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            footer: Row(
              children: [
                Text('${item.totMts.toStringAsFixed(1)} Mts', style: monoStyle.copyWith(fontSize: 12, color: colors.textSecondary)),
                const Spacer(),
                Text(
                  item.date.toIso8601String().split('T')[0],
                  style: monoStyle.copyWith(fontSize: 11, color: colors.textMuted),
                ),
              ],
            ),
          );
        },
      ),
      sectionCanvas: _selectedReceive == null ? null : _buildSectionCanvas(colors, monoStyle),
      emptyTitle: 'No Job Receive Record Selected',
      emptyMessage: 'Select a job receive record from the list to view stitching metrics and lines.',
      emptyIcon: LucideIcons.packageCheck,
    );
  }

  Widget _buildSectionCanvas(OrganismColors colors, TextStyle monoStyle) {
    final receive = _selectedReceive!;
    return OrganSectionCanvas(
      title: 'Receive Challan #${receive.vno}',
      actions: const [
        CellButton(text: 'Print', icon: LucideIcons.printer, variant: CellButtonVariant.ghost),
      ],
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Stitching Tailor'),
                  TissueCardContent(
                    child: Text(
                      receive.tailorName ?? receive.tailorCode,
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
                  const TissueCardHeader(title: 'Receive Date'),
                  TissueCardContent(
                    child: Text(
                      receive.date.toIso8601String().split('T')[0],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TissueCardHeader(title: 'Summary Metrics'),
            TissueCardContent(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('TOTAL METERS', '${receive.totMts.toStringAsFixed(1)} M'),
                  _buildMetric('TOTAL PIECES', '${receive.totPcs} Pcs'),
                  _buildMetric('FINAL AMT', '₹${receive.finalAmt.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('RECEIVED PIECES (O6 LINES)', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        if (_isDetailLoading)
          Column(
            children: List.generate(3, (idx) => Padding(
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
                  const CellSkeleton(width: 60, height: 14),
                ],
              ),
            )),
          )
        else if (_detailLines.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No fabric detail lines found for this receive voucher.'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _detailLines.length,
            itemBuilder: (context, index) {
              final line = _detailLines[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CellBadge(text: '${line.srNo}', variant: CellBadgeVariant.secondary),
                title: Text(line.quality, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qty: ${line.pieces.toInt()} Pcs / ${line.meters.toStringAsFixed(1)} Mts'),
                    if (line.stageVno != null && line.stageVno! > 0)
                      Text(
                        'From Stitching Dispatch: #${line.stageVno}',
                        style: TextStyle(color: colors.success, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${line.rate.toStringAsFixed(2)}', style: monoStyle),
                    const SizedBox(width: 8),
                    CellBadge(
                      text: line.isClosed ? 'CLOSED' : 'OPEN',
                      variant: line.isClosed ? CellBadgeVariant.success : CellBadgeVariant.secondary,
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        Text('ATTACHED CHALLAN SCANS', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        _buildMediaAttachmentsSection(colors, monoStyle, receive.vno),
      ],
    );
  }
}
