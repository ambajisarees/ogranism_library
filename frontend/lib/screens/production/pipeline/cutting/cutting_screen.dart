import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../models/production/model_cutting.dart';
import '../../../../models/production/model_media.dart';
import '../../../../services/production/service_cutting.dart';
import '../../../../services/production/service_media.dart';
import '../../../../organism_design/index.dart';
import 'widgets/cutting_detail_canvas.dart';
import 'widgets/cutting_form_overlay.dart';

/// [CuttingScreen] — Orchestrator for the Cutting Cards workstation.
class CuttingScreen extends StatefulWidget {
  const CuttingScreen({super.key});

  @override
  State<CuttingScreen> createState() => _CuttingScreenState();
}

class _CuttingScreenState extends State<CuttingScreen> {
  final CuttingService _service = CuttingService();

  // Registry Card List
  List<CuttingBatchSummaryModel> _cards = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _limit = 50;
  int _totalCount = 0;

  final TextEditingController _searchController = TextEditingController();

  // Selected Detail variables
  CuttingBatchSummaryModel? _selectedCard;
  CuttingBatchSummaryModel? _batchSummary;
  List<CuttingCardModel> _siblingCards = [];
  bool _loadingBatchDetail = false;

  // Timeline and scans
  Map<String, DateTime?> _timelineDates = {};
  bool _loadingTimeline = false;
  List<MediaModel> _batchMedia = [];
  bool _loadingMedia = false;

  RealtimeChannel? _realtimeChannel;

  // Filters & Sorting state
  String? _selectedFilterMill;
  String? _selectedFilterFabric;
  String _sortBy = 'CC_DESC';
  List<String> _uniqueFilterMills = [];
  List<String> _uniqueFilterFabrics = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
    _loadFilterOptions();
    _setupRealtime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  void _setupRealtime() {
    _realtimeChannel = Supabase.instance.client
        .channel('sb_cutdet_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'IMMBE2627',
          table: 'sb_cutdet',
          callback: (payload) {
            if (mounted) {
              _loadCards();
              if (_selectedCard != null) {
                _onCardSelected(_selectedCard!);
              }
            }
          },
        );
    _realtimeChannel!.subscribe();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final mills = await _service.getUniqueMills();
      final qualities = await _service.getUniqueQualities();
      if (mounted) {
        setState(() {
          _uniqueFilterMills = mills;
          _uniqueFilterFabrics = qualities;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final results = await _service.getCuttingBatches(
      offset: (_currentPage - 1) * _limit,
      limit: _limit,
      searchQuery: _searchController.text,
      filterMill: _selectedFilterMill,
      filterFabric: _selectedFilterFabric,
      sortBy: _sortBy,
    );
    if (mounted) {
      setState(() {
        _cards = results.data;
        _totalCount = results.totalCount;
        _isLoading = false;
        if (_cards.isNotEmpty && _selectedCard == null) {
          _onCardSelected(_cards.first);
        }
      });
    }
  }

  Future<void> _onCardSelected(CuttingBatchSummaryModel batch) async {
    if (!mounted) return;
    setState(() {
      _selectedCard = batch;
      _batchSummary = batch;
      _siblingCards = [];
      _timelineDates = {};
      _batchMedia = [];
      _loadingBatchDetail = true;
      _loadingTimeline = true;
      _loadingMedia = true;
    });

    final siblings = await _service.getSiblingCards(batch.multiVno);
    
    final Map<String, DateTime?> dates = {};
    if (batch.greyPurchaseDate != null || batch.stockReceivedDate != null) {
      dates['grey_purchase'] = batch.greyPurchaseDate;
      dates['print_program'] = null;
      dates['stock_received'] = batch.stockReceivedDate;
      dates['batch_cut'] = batch.cutDate;
      dates['job_issued'] = batch.jobIssuedDate;
      dates['job_received'] = batch.jobReceivedDate;
    } else {
      try {
        final timelineData = await _service.getBatchTimeline(batch.multiVno);
        timelineData.forEach((key, val) {
          dates[key] = val != null ? DateTime.tryParse(val) : null;
        });
      } catch (e) {
        debugPrint('Error fetching fallback timeline: $e');
      }
    }

    List<MediaModel> mediaList = [];
    try {
      mediaList = await MediaService().getMediaForEntity('cutting_batch', batch.multiVno.toString());
    } catch (e) {
      debugPrint('Error fetching media: $e');
    }

    if (mounted && _selectedCard?.multiVno == batch.multiVno) {
      setState(() {
        _siblingCards = siblings;
        _timelineDates = dates;
        _batchMedia = mediaList;
        _loadingBatchDetail = false;
        _loadingTimeline = false;
        _loadingMedia = false;
      });
    }
  }

  Future<bool> _handleCloseAddRequest() async {
    final confirm = await PlasmaAlertDialog.show(
      context: context,
      title: 'Discard Entry?',
      message: 'You have unsaved changes in this cutting batch. Are you sure you want to discard them?',
      isDestructive: true,
      confirmText: 'Discard',
    );

    if (confirm == true) {
      if (mounted) {
        KineticWorkspaceProvider.of(context).hideOverlay();
      }
      return true;
    }
    return false;
  }

  void _handleSaveSuccess(Map<String, dynamic> result) async {
    final targetMultiVno = (result['multi_vno'] as num?)?.toInt();
    
    PlasmaToastManager.instance.show(
      context, 
      _selectedCard != null
          ? 'Saved successfully! Batch #$targetMultiVno updated.'
          : 'Saved successfully! Batch #$targetMultiVno created.', 
      variant: CellBadgeVariant.success
    );

    if (mounted) {
      setState(() {
        _selectedCard = null;
        _batchSummary = null;
        _siblingCards = [];
      });
      KineticWorkspaceProvider.of(context).hideOverlay();
      await _loadCards();
      
      if (targetMultiVno != null && _cards.isNotEmpty) {
        final updatedBatch = _cards.firstWhere(
          (c) => c.multiVno == targetMultiVno,
          orElse: () => _cards.first,
        );
        _onCardSelected(updatedBatch);
      }
    }
  }

  void _startAddBatch() {
    KineticWorkspaceProvider.of(context).showOverlay(
      content: CuttingFormOverlay(
        onClose: () => _handleCloseAddRequest(),
        onSaved: (result) => _handleSaveSuccess(result),
      ),
      onCloseRequest: _handleCloseAddRequest,
    );
  }

  void _startEditBatch(CuttingBatchSummaryModel batch) {
    KineticWorkspaceProvider.of(context).showOverlay(
      content: CuttingFormOverlay(
        editBatch: batch,
        siblingCards: _siblingCards,
        onClose: () => _handleCloseAddRequest(),
        onSaved: (result) => _handleSaveSuccess(result),
      ),
      onCloseRequest: _handleCloseAddRequest,
    );
  }

  Future<void> _uploadSpecificSideScan(String side) async {
    final summary = _batchSummary;
    if (summary == null) return;
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        final bytes = file.bytes ??
            (filePath != null ? await File(filePath).readAsBytes() : null);
        if (bytes == null) {
          throw Exception('No file data available.');
        }

        setState(() {
          _loadingMedia = true;
        });

        PlasmaToastManager.instance.show(context, 'Uploading scan...', variant: CellBadgeVariant.primary);

        final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
        final ccCode = 'CC-${summary.multiVno.toString().padLeft(4, '0')}';
        final targetFileName = '$ccCode-$side.$ext';

        final mediaId = await MediaService().uploadFile(
          bytes,
          targetFileName,
          bucket: 'production',
          entityType: 'cutting_batch',
          entityId: summary.multiVno.toString(),
          mediaType: 'cutting_card',
        );

        if (mediaId.isNotEmpty) {
          final storagePath = 'production/cutting/${summary.multiVno}/$targetFileName';
          await Supabase.instance.client
              .schema('IMMBE2627')
              .from('sb_cutdet_summary')
              .update({'sb_cardpic': storagePath})
              .eq('MULTI_VNO', summary.multiVno);

          await Supabase.instance.client
              .schema('IMMBE2627')
              .from('sb_cutdet')
              .update({'sb_cardpic': storagePath})
              .eq('MULTI_VNO', summary.multiVno);
        }

        // Reload details
        final updatedSummary = await _service.getBatchSummary(summary.multiVno);
        final mediaList = await MediaService().getMediaForEntity('cutting_batch', summary.multiVno.toString());

        if (mounted) {
          setState(() {
            _batchSummary = updatedSummary;
            _selectedCard = updatedSummary;
            _batchMedia = mediaList;
            _loadingMedia = false;
          });
          PlasmaToastManager.instance.show(context, 'Cutting card scan attached.', variant: CellBadgeVariant.success);
          _loadCards();
        }
      }
    } catch (e) {
      debugPrint('Error uploading side scan: $e');
      if (mounted) {
        setState(() {
          _loadingMedia = false;
        });
        PlasmaToastManager.instance.show(context, 'Upload failed: $e', variant: CellBadgeVariant.error);
      }
    }
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
                'FILTER BY MILL',
                style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 8),
              TissueDropdown<String?>(
                items: [null, ..._uniqueFilterMills],
                value: _selectedFilterMill,
                itemLabelBuilder: (val) => val ?? 'All Mills',
                onChanged: (val) {
                  setState(() {
                    _selectedFilterMill = val;
                    _currentPage = 1;
                  });
                  setPopoverState(() {});
                  _loadCards();
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
                  });
                  setPopoverState(() {});
                  _loadCards();
                },
              ),
              if (_selectedFilterMill != null || _selectedFilterFabric != null) ...[
                const SizedBox(height: 16),
                CellButton(
                  text: 'Clear Filters',
                  variant: CellButtonVariant.outline,
                  onPressed: () {
                    setState(() {
                      _selectedFilterMill = null;
                      _selectedFilterFabric = null;
                      _currentPage = 1;
                    });
                    setPopoverState(() {});
                    _loadCards();
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
          {'label': 'CC No: High to Low', 'value': 'CC_DESC', 'icon': LucideIcons.hash},
          {'label': 'CC No: Low to High', 'value': 'CC_ASC', 'icon': LucideIcons.hash},
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
                  color: isSelected ? colors.primary.withOpacity(0.04) : null,
                  child: CellListTile(
                    title: opt['label'],
                    leading: Icon(opt['icon'], size: 14, color: isSelected ? colors.primary : colors.textMuted),
                    onTap: () {
                      setState(() {
                        _sortBy = opt['value'];
                        _currentPage = 1;
                      });
                      setPopoverState(() {});
                      _loadCards();
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

    return SystemAppMasterLayout(
      paneHeader: OrganPaneHeader(
        title: 'Cutting Cards',
        searchController: _searchController,
        onSearchChanged: (v) {
          setState(() => _currentPage = 1);
          _loadCards();
        },
        searchPlaceholder: 'Search by CC No, Mill, Fabric...',
        onAddPressed: _startAddBatch,
        addLabel: 'Add Batch',
        filterContent: _buildFilterPopover(context),
        filterWidth: 260.0,
        sortContent: _buildSortPopover(context),
        sortWidth: 260.0,
      ),
      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _cards.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _loadCards();
        },
        itemBuilder: (context, index) {
          final summary = _cards[index];
          final isSelected = _selectedCard?.multiVno == summary.multiVno;

          return TissueListCard(
            isSelected: isSelected,
            onTap: () => _onCardSelected(summary),
            showDivider: true,
            leading: CellCardAvatar(
              date: summary.cutDate,
            ),
            title: Text(
              summary.greyQual.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OrganismTheme.bodyMedium(context).copyWith(
                fontFamily: 'Mono',
                fontWeight: FontWeight.bold,
                color: isSelected ? colors.primary : colors.textPrimary,
              ),
            ),
            subtitle: Text(
              summary.mill.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OrganismTheme.bodySmall(context).copyWith(
                fontFamily: 'Mono',
                color: isSelected ? colors.primary.withOpacity(0.8) : colors.textSecondary,
              ),
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CellBadge(
                  text: summary.ccCode,
                  variant: CellBadgeVariant.secondary,
                ),
                Text(
                  '${summary.totalFreshPcs.toInt()} Pcs',
                  style: OrganismTheme.bodyMedium(context).copyWith(
                    fontFamily: 'Mono',
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colors.primary : colors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      sectionCanvas: _selectedCard != null && _batchSummary != null
          ? CuttingDetailCanvas(
              summary: _batchSummary!,
              siblingCards: _siblingCards,
              batchMedia: _batchMedia,
              loadingTimeline: _loadingTimeline,
              loadingBatchDetail: _loadingBatchDetail,
              timelineDates: _timelineDates,
              onEdit: () => _startEditBatch(_batchSummary!),
              onUploadScan: _uploadSpecificSideScan,
            )
          : null,
      isDetailVisible: _selectedCard != null,
      emptyTitle: 'No Cutting Batch Selected',
      emptyMessage: 'Select a batch from the registry to view its cutting metrics and status.',
      emptyIcon: LucideIcons.scissors,
    );
  }
}
