import 'dart:io';
import 'package:flutter/material.dart';
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

  // Filter & Sort State
  String? _selectedFilterKhata;
  String? _selectedFilterFabric;
  String _sortBy = 'DATE_DESC';
  List<String> _uniqueFilterKhatas = [];
  List<String> _uniqueFilterFabrics = [];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final tailors = await _service.getUniqueTailors(type: 'O6');
      final fabrics = await _service.getUniqueFabrics(type: 'O6');
      if (mounted) {
        setState(() {
          _uniqueFilterKhatas = tailors;
          _uniqueFilterFabrics = fabrics;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await _service.getJobReceives(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
        filterKhata: _selectedFilterKhata,
        filterFabric: _selectedFilterFabric,
        sortBy: _sortBy,
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
      // Yield thread to let current gesture arena & button hover states settle
      await Future.delayed(Duration.zero);
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes ?? await File(file.path!).readAsBytes();
        if (!mounted) return;
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
      if (!mounted) return;
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

  Widget _buildFilterPopover(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setPopoverState) {
        final colors = OrganismTheme.colorsOf(context);
        return CellBox(
          padding: const EdgeInsets.all(OrganismTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FILTER BY KHATA',
                style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 8),
              TissueDropdown<String?>(
                items: [null, ..._uniqueFilterKhatas],
                value: _selectedFilterKhata,
                itemLabelBuilder: (val) => val ?? 'All Khatas',
                onChanged: (val) {
                  setState(() {
                    _selectedFilterKhata = val;
                    _currentPage = 1;
                    _selectedReceive = null;
                  });
                  setPopoverState(() {});
                  _loadData();
                },
              ),
              const SizedBox(height: 16),
              Text(
                'FILTER BY FABRIC',
                style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 8),
              TissueDropdown<String?>(
                items: [null, ..._uniqueFilterFabrics],
                value: _selectedFilterFabric,
                itemLabelBuilder: (val) => val ?? 'All Fabrics',
                onChanged: (val) {
                  setState(() {
                    _selectedFilterFabric = val;
                    _currentPage = 1;
                    _selectedReceive = null;
                  });
                  setPopoverState(() {});
                  _loadData();
                },
              ),
              if (_selectedFilterKhata != null || _selectedFilterFabric != null) ...[
                const SizedBox(height: 16),
                CellButton(
                  text: 'Clear Filters',
                  variant: CellButtonVariant.outline,
                  onPressed: () {
                    setState(() {
                      _selectedFilterKhata = null;
                      _selectedFilterFabric = null;
                      _currentPage = 1;
                      _selectedReceive = null;
                    });
                    setPopoverState(() {});
                    _loadData();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortPopover(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setPopoverState) {
        final colors = OrganismTheme.colorsOf(context);
        final List<Map<String, dynamic>> sortOptions = [
          {'label': 'Date: Latest First', 'value': 'DATE_DESC', 'icon': LucideIcons.calendarRange},
          {'label': 'Date: Oldest First', 'value': 'DATE_ASC', 'icon': LucideIcons.calendarRange},
          {'label': 'Job No: High to Low', 'value': 'JOBNO_DESC', 'icon': LucideIcons.hash},
          {'label': 'Job No: Low to High', 'value': 'JOBNO_ASC', 'icon': LucideIcons.hash},
        ];

        return CellBox(
          padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingSm),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortOptions.map<Widget>((opt) {
                final isSelected = opt['value'] == _sortBy;
                return Container(
                  color: isSelected ? colors.primary.withValues(alpha: 0.04) : null,
                  child: CellListTile(
                    title: opt['label'],
                    leading: Icon(opt['icon'], size: 14, color: isSelected ? colors.primary : colors.textMuted),
                    onTap: () {
                      setState(() {
                        _sortBy = opt['value'];
                        _currentPage = 1;
                        _selectedReceive = null;
                      });
                      setPopoverState(() {});
                      _loadData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(fontSize: 14);

    return SystemAppMasterLayout(
      isDetailVisible: _selectedReceive != null,
      paneHeader: OrganPaneHeader(
        title: 'Job Inward',
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
        primaryAction: const CellButton(
          text: 'Add',
          icon: LucideIcons.plus,
          variant: CellButtonVariant.primary,
          isCompact: true,
          onPressed: null, // Disabled
        ),
        filterContent: _buildFilterPopover(context),
        filterWidth: 260.0,
        sortContent: _buildSortPopover(context),
        sortWidth: 260.0,
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

          return TissueListCard.registry(
            isSelected: isSelected,
            onTap: () => _onReceiveSelected(item),
            showDivider: true,
            badgeColor: colors.success, // success green color for receives
            registryDate: item.date,
            registryTitle: item.tailorName ?? item.tailorCode,
            registrySubtitle: item.itemReceived ?? 'No Items Received',
            registryBadgeText: '${item.vno}',
            registryMetricText: '${item.totPcs} PCS',
          );
        },
      ),
      sectionCanvas: _selectedReceive == null ? null : _buildSectionCanvas(colors, monoStyle),
      emptyTitle: 'No Job Inward Record Selected',
      emptyMessage: 'Select a job inward record from the list to view stitching metrics and lines.',
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
