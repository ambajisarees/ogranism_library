import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:textile_erp/organism_design/index.dart';
import '../../models/model_jobwork.dart';
import '../../models/model_media.dart';
import '../../services/service_jobwork.dart';
import '../../services/service_media.dart';

class JobWorkScreen extends StatefulWidget {
  const JobWorkScreen({super.key});

  @override
  State<JobWorkScreen> createState() => _JobWorkScreenState();
}

class _JobWorkScreenState extends State<JobWorkScreen> with SingleTickerProviderStateMixin {
  final _service = JobWorkService();
  late TabController _tabController;

  final List<String> _tabNames = ['Job Dispatch (O5)', 'Job Receive (O6)'];

  // Tab 0: Job Dispatch Data
  List<JobDispatchModel> _dispatches = [];
  JobDispatchModel? _selectedDispatch;

  // Tab 1: Job Receive Data
  List<JobReceiveModel> _receives = [];
  JobReceiveModel? _selectedReceive;

  // Shared Detail Lines
  List<JobWorkDetailLineModel> _detailLines = [];
  List<JobWorkDetailLineModel> _linkedReceives = []; // For O5 dispatch details view
  List<MediaModel> _attachedMedia = [];
  bool _isLoading = false;
  bool _isDetailLoading = false;
  bool _isLinkedReceivesLoading = false;

  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentPage = 1;
          _selectedDispatch = null;
          _selectedReceive = null;
          _clearDetails();
        });
        _loadData();
      }
    });
    _loadData();
  }

  void _clearDetails() {
    _detailLines = [];
    _linkedReceives = [];
    _isDetailLoading = false;
    _isLinkedReceivesLoading = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (_tabController.index == 0) {
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
          });
        }
      } else {
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
          });
        }
      }
    } catch (e) {
      print('Error in JobWorkScreen._loadData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDetails(int vno, String type) async {
    setState(() {
      _isDetailLoading = true;
      _detailLines = [];
    });

    final lines = await _service.getJobWorkLines(vno, type);

    if (mounted) {
      setState(() {
        _detailLines = lines;
        _isDetailLoading = false;
      });
    }

    // If it's a dispatch (O5) entry, load any linked receive entries (O6) as well
    if (type == 'O5') {
      setState(() {
        _isLinkedReceivesLoading = true;
        _linkedReceives = [];
      });
      final linked = await _service.getReceivesForDispatch(vno);
      if (mounted) {
        setState(() {
          _linkedReceives = linked;
          _isLinkedReceivesLoading = false;
        });
      }
    }

    // Load media attachments
    final entityType = type == 'O5' ? 'stitching_dispatch' : 'stitching_receive';
    final media = await MediaService().getMediaForEntity(entityType, vno.toString());
    if (mounted) {
      setState(() {
        _attachedMedia = media;
      });
    }
  }

  Future<void> _attachChallanScan(String entityType, int vno) async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes ?? await File(file.path!).readAsBytes();
        
        PlasmaToastManager.instance.show(context, 'Uploading scan...', variant: CellBadgeVariant.primary);
        
        final typeLabel = entityType == 'stitching_dispatch' ? 'O5 Dispatch' : 'O6 Receive';
        await MediaService().uploadFile(
          bytes,
          file.name,
          bucket: 'production',
          entityType: entityType,
          entityId: vno.toString(),
          entityLabel: '$typeLabel #$vno',
          mediaType: 'challan_scan',
        );
        
        // Reload media attachments
        final media = await MediaService().getMediaForEntity(entityType, vno.toString());
        if (mounted) {
          setState(() {
            _attachedMedia = media;
          });
          PlasmaToastManager.instance.show(context, 'Challan scan attached.', variant: CellBadgeVariant.success);
        }
      }
    } catch (e) {
      print('Error uploading challan scan: $e');
      if (mounted) {
        PlasmaToastManager.instance.show(context, 'Upload failed: $e', variant: CellBadgeVariant.error);
      }
    }
  }

  Future<void> _removeChallanScan(String mediaId, String entityType, int vno) async {
    try {
      final confirm = await PlasmaAlertDialog.show(
        context: context,
        title: 'Delete Scan?',
        message: 'Are you sure you want to delete this challan scan?',
        isDestructive: true,
      );
      if (confirm != true) return;

      await MediaService().archiveMedia(mediaId);
      
      // Reload media attachments
      final media = await MediaService().getMediaForEntity(entityType, vno.toString());
      if (mounted) {
        setState(() {
          _attachedMedia = media;
        });
        PlasmaToastManager.instance.show(context, 'Scan deleted.', variant: CellBadgeVariant.success);
      }
    } catch (e) {
      print('Error removing challan scan: $e');
    }
  }

  Widget _buildMediaAttachmentsSection(OrganismColors colors, TextStyle monoStyle, String entityType, int vno) {
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
                                  onPressed: () => _removeChallanScan(media.id, entityType, vno),
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
                    onPressed: () => _attachChallanScan(entityType, vno),
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
                    onPressed: () => _attachChallanScan(entityType, vno),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(
      fontSize: 14,
    );

    final bool isDetailVisible = _tabController.index == 0
        ? _selectedDispatch != null
        : _selectedReceive != null;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () => _tabController.animateTo(0),
        const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () => _tabController.animateTo(1),
      },
      child: Focus(
        autofocus: true,
        child: SystemAppMasterLayout(
          isDetailVisible: isDetailVisible,
          tabs: TissueTabChrome(
            items: [
              CellTabItem(
                icon: LucideIcons.truck,
                title: _tabNames[0],
                kbdShortcut: 'Alt+1',
                isSelected: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
              CellTabItem(
                icon: LucideIcons.packageCheck,
                title: _tabNames[1],
                kbdShortcut: 'Alt+2',
                isSelected: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
            ],
          ),
          paneHeader: OrganPaneHeader(
            title: _tabNames[_tabController.index],
            onSearchChanged: (val) {
              setState(() {
                _searchTerm = val;
                _currentPage = 1;
              });
              _loadData();
            },
          ),
          paneList: OrganPaneList(
            isLoading: _isLoading,
            itemCount: _tabController.index == 0 ? _dispatches.length : _receives.length,
            currentPage: _currentPage,
            totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
            totalCount: _totalCount,
            limit: _limit,
            onPageChanged: (p) {
              setState(() => _currentPage = p);
              _loadData();
            },
            itemBuilder: (context, index) {
              if (_tabController.index == 0) {
                final item = _dispatches[index];
                final isSelected = _selectedDispatch?.vno == item.vno;

                return TissueListCard(
                  isSelected: isSelected,
                  isCompact: false,
                  showDivider: true,
                  onTap: () {
                    setState(() => _selectedDispatch = item);
                    _loadDetails(item.vno, 'O5');
                  },
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
              } else {
                final item = _receives[index];
                final isSelected = _selectedReceive?.vno == item.vno;

                return TissueListCard(
                  isSelected: isSelected,
                  isCompact: false,
                  showDivider: true,
                  onTap: () {
                    setState(() => _selectedReceive = item);
                    _loadDetails(item.vno, 'O6');
                  },
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
              }
            },
          ),
          sectionCanvas: _buildSectionCanvas(colors, monoStyle),
          emptyTitle: _tabNames[_tabController.index],
          emptyMessage: 'Select a job work record from the list to view detailed fabric dispatches or receipts.',
          emptyIcon: _tabController.index == 0 ? LucideIcons.truck : LucideIcons.packageCheck,
        ),
      ),
    );
  }

  Widget? _buildSectionCanvas(OrganismColors colors, TextStyle monoStyle) {
    if (_tabController.index == 0 && _selectedDispatch == null) return null;
    if (_tabController.index == 1 && _selectedReceive == null) return null;

    if (_tabController.index == 0) {
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
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
          _buildMediaAttachmentsSection(colors, monoStyle, 'stitching_dispatch', dispatch.vno),
        ],
      );
    } else {
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
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
          _buildMediaAttachmentsSection(colors, monoStyle, 'stitching_receive', receive.vno),
        ],
      );
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
}
