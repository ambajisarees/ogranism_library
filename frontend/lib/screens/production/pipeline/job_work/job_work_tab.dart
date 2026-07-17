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

/// Legacy compatibility wrapper stub. Delegates to [JobDispatchTab].
class JobWorkScreen extends StatelessWidget {
  const JobWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const JobDispatchTab();
  }
}

/// [JobDispatchTab] — Handles the Stitching Dispatch (O5) transaction registry,
/// detail canvas, linked stitching receives (returns), and challan scans.
class JobDispatchTab extends StatefulWidget {
  const JobDispatchTab({super.key});

  @override
  State<JobDispatchTab> createState() => _JobDispatchTabState();
}

class _JobDispatchTabState extends State<JobDispatchTab> {
  final _service = JobWorkService();

  List<JobDispatchModel> _dispatches = [];
  JobDispatchModel? _selectedDispatch;

  List<JobWorkDetailLineModel> _detailLines = [];
  List<JobWorkDetailLineModel> _linkedReceives = [];
  List<MediaModel> _attachedMedia = [];
  
  bool _isLoading = false;
  bool _isDetailLoading = false;
  bool _isLinkedReceivesLoading = false;

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
      final result = await _service.getJobDispatches(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      if (mounted) {
        setState(() {
          _dispatches = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
          // Auto-select first item
          if (_dispatches.isNotEmpty && _selectedDispatch == null) {
            _onDispatchSelected(_dispatches.first);
          }
        });
      }
    } catch (e) {
      debugPrint('Error in JobDispatchTab._loadData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onDispatchSelected(JobDispatchModel dispatch) async {
    setState(() {
      _selectedDispatch = dispatch;
      _isDetailLoading = true;
      _isLinkedReceivesLoading = true;
      _detailLines = [];
      _linkedReceives = [];
      _attachedMedia = [];
    });

    try {
      final lines = await _service.getJobWorkLines(dispatch.vno, 'O5');
      if (mounted && _selectedDispatch?.vno == dispatch.vno) {
        setState(() {
          _detailLines = lines;
          _isDetailLoading = false;
        });
      }

      final linked = await _service.getReceivesForDispatch(dispatch.vno);
      if (mounted && _selectedDispatch?.vno == dispatch.vno) {
        setState(() {
          _linkedReceives = linked;
          _isLinkedReceivesLoading = false;
        });
      }

      final media = await MediaService().getMediaForEntity('stitching_dispatch', dispatch.vno.toString());
      if (mounted && _selectedDispatch?.vno == dispatch.vno) {
        setState(() {
          _attachedMedia = media;
        });
      }
    } catch (e) {
      debugPrint('Error loading details for dispatch #${dispatch.vno}: $e');
      if (mounted && _selectedDispatch?.vno == dispatch.vno) {
        setState(() {
          _isDetailLoading = false;
          _isLinkedReceivesLoading = false;
        });
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
          entityType: 'stitching_dispatch',
          entityId: vno.toString(),
          entityLabel: 'O5 Dispatch #$vno',
          mediaType: 'challan_scan',
        );

        final media = await MediaService().getMediaForEntity('stitching_dispatch', vno.toString());
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

      final media = await MediaService().getMediaForEntity('stitching_dispatch', vno.toString());
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
      isDetailVisible: _selectedDispatch != null,
      paneHeader: OrganPaneHeader(
        title: 'Job Dispatch (O5)',
        searchController: _searchController,
        onSearchChanged: (val) {
          setState(() {
            _searchTerm = val;
            _currentPage = 1;
            _selectedDispatch = null;
          });
          _loadData();
        },
        searchPlaceholder: 'Search by Tailor...',
      ),
      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _dispatches.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (p) {
          setState(() {
            _currentPage = p;
            _selectedDispatch = null;
          });
          _loadData();
        },
        itemBuilder: (context, index) {
          final item = _dispatches[index];
          final isSelected = _selectedDispatch?.vno == item.vno;

          return TissueListCard(
            isSelected: isSelected,
            isCompact: false,
            showDivider: true,
            onTap: () => _onDispatchSelected(item),
            leading: CellCardAvatar(date: item.date),
            title: Text(
              item.tailorName ?? item.tailorCode,
              style: OrganismTheme.bodyLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Challan No: ${item.vno} • ${item.totPcs} Pieces', style: OrganismTheme.bodySmall(context)),
            trailing: Text(
              'O5',
              style: monoStyle.copyWith(
                color: colors.primary,
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
      sectionCanvas: _selectedDispatch == null ? null : _buildSectionCanvas(colors, monoStyle),
      emptyTitle: 'No Job Dispatch Record Selected',
      emptyMessage: 'Select a job dispatch record from the list to view detailed fabric dispatches.',
      emptyIcon: LucideIcons.truck,
    );
  }

  Widget _buildSectionCanvas(OrganismColors colors, TextStyle monoStyle) {
    final dispatch = _selectedDispatch!;
    return OrganSectionCanvas(
      title: 'Dispatch Challan #${dispatch.vno}',
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
                      dispatch.tailorName ?? dispatch.tailorCode,
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
                  const TissueCardHeader(title: 'Challan Date'),
                  TissueCardContent(
                    child: Text(
                      dispatch.date.toIso8601String().split('T')[0],
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
                  _buildMetric('TOTAL METERS', '${dispatch.totMts.toStringAsFixed(1)} M'),
                  _buildMetric('TOTAL PIECES', '${dispatch.totPcs} Pcs'),
                  _buildMetric('FINAL AMT', '₹${dispatch.finalAmt.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('FABRIC DETAILS (O5 LINES)', style: OrganismTheme.titleMedium(context)),
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
              child: Text('No fabric detail lines found for this dispatch.'),
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
                    if (line.cuttingCardNo != null && line.cuttingCardNo! > 0)
                      Text(
                        'Cutting Card Reference: #${line.cuttingCardNo}',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${line.rate.toStringAsFixed(2)}', style: monoStyle),
                    const SizedBox(width: 8),
                    CellBadge(
                      text: line.isClosed ? 'CLOSED' : 'PENDING',
                      variant: line.isClosed ? CellBadgeVariant.success : CellBadgeVariant.warning,
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        Text('LINKED STITCHING RETURNS (O6)', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        if (_isLinkedReceivesLoading)
          Column(
            children: List.generate(2, (idx) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(LucideIcons.packageCheck, size: 16, color: Colors.transparent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CellSkeleton(width: 180 + (idx * 15.0), height: 14),
                        const SizedBox(height: 6),
                        const CellSkeleton(width: 140, height: 10),
                      ],
                    ),
                  ),
                  const CellSkeleton(width: 50, height: 14),
                ],
              ),
            )),
          )
        else if (_linkedReceives.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No returns recorded yet for this dispatch.'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _linkedReceives.length,
            itemBuilder: (context, index) {
              final line = _linkedReceives[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(LucideIcons.packageCheck, size: 16),
                title: Text('Receipt #${line.vno} (Line ${line.srNo})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Received: ${line.pieces.toInt()} Pcs / ${line.meters.toStringAsFixed(1)} Mts'),
                trailing: Text('Line Status: ${line.isClosed ? 'Closed' : 'Open'}', style: monoStyle.copyWith(fontSize: 12)),
              );
            },
          ),
        const SizedBox(height: 24),
        Text('ATTACHED CHALLAN SCANS', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        _buildMediaAttachmentsSection(colors, monoStyle, dispatch.vno),
      ],
    );
  }
}
