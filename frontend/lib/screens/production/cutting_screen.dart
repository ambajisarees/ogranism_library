import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../organism_design/index.dart';
import '../../models/model_cutting.dart';
import '../../services/service_cutting.dart';
import '../../services/service_media.dart';

class CuttingScreen extends StatefulWidget {
  const CuttingScreen({super.key});

  @override
  State<CuttingScreen> createState() => _CuttingScreenState();
}

class _CuttingScreenState extends State<CuttingScreen> {
  final CuttingService _service = CuttingService();
  final TextEditingController _searchController = TextEditingController();

  List<CuttingBatchSummaryModel> _cards = [];
  CuttingBatchSummaryModel? _selectedCard;
  bool _isLoading = true;

  // Pagination State
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;

  // Sibling & Summary Detail State
  CuttingBatchSummaryModel? _batchSummary;
  List<CuttingCardModel> _siblingCards = [];
  bool _loadingBatchDetail = false;

  // --- Batch Creation State ---
  DateTime _batchDate = DateTime.now();
  List<String> _selectedQualities = [];
  String? _selectedMill;
  double _cutLength = 5.20; // default 5.20 as requested
  String _groupBy = 'NONE'; // NONE, DATE, DESNO
  Map<String, bool> _expandedGroups = {};
  int? _editingMultiVno;
  
  // Selection Lookups
  List<String> _qualities = [];
  List<String> _mills = [];
  List<Map<String, dynamic>> _availableTakas = [];
  List<Map<String, dynamic>> _selectedTakaRows = [];
  bool _loadingAvailable = false;

  // Metric Inputs
  final TextEditingController _freshPcsController = TextEditingController(text: '0');
  final TextEditingController _secondPcsController = TextEditingController(text: '0');
  final TextEditingController _sareeWtController = TextEditingController(text: '400'); // default 400 grams
  final TextEditingController _fentWtController = TextEditingController(text: '0.00');
  
  // Summary inputs
  String _selectedJobType = 'Standard Cutting';
  String _selectedValueAddition = 'None';
  final TextEditingController _screenController = TextEditingController();
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _startMultiVnoController = TextEditingController();

  RealtimeChannel? _realtimeChannel;

  // Filters & Sorting state
  String? _selectedFilterMill;
  String? _selectedFilterFabric;
  String _sortBy = 'DATE_DESC';
  List<String> _uniqueFilterMills = [];
  List<String> _uniqueFilterFabrics = [];

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
      print('Error loading filter options: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
    _loadQualities();
    _loadFilterOptions();
    _setupRealtime();
  }

  @override
  void dispose() {
    _freshPcsController.dispose();
    _secondPcsController.dispose();
    _sareeWtController.dispose();
    _fentWtController.dispose();
    _screenController.dispose();
    _picController.dispose();
    _startMultiVnoController.dispose();
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
              _loadAvailableTakas();
              _loadCards();
            }
          },
        );
    _realtimeChannel!.subscribe();
  }

  Future<void> _loadQualities() async {
    final list = await _service.getUniqueQualities();
    if (mounted) {
      setState(() {
        _qualities = list;
      });
    }
  }

  Future<void> _loadMills() async {
    final list = await _service.getUniqueMills();
    if (mounted) {
      setState(() {
        _mills = list;
      });
    }
  }

  Future<void> _loadAvailableTakas() async {
    if (_selectedQualities.isEmpty || _selectedMill == null) return;
    setState(() => _loadingAvailable = true);
    final list = await _service.getAvailableTakas(
      greyQuals: _selectedQualities,
      mill: _selectedMill!,
      editMultiVno: _editingMultiVno,
    );
    if (mounted) {
      setState(() {
        _availableTakas = list;
        if (_editingMultiVno != null && _selectedTakaRows.isEmpty) {
          final siblingCardNos = _siblingCards.map((c) => c.reccardno).toSet();
          _selectedTakaRows = _availableTakas.where((row) {
            final cardNo = (row['CARDNO'] as num?)?.toInt() ?? 0;
            return siblingCardNos.contains(cardNo);
          }).toList();
        }
        _loadingAvailable = false;
      });
    }
  }

  Future<void> _loadNextMultiVno() async {
    final nextNo = await _service.getNextMultiVno();
    if (mounted) {
      setState(() {
        _startMultiVnoController.text = nextNo.toString();
      });
    }
  }

  Future<void> _onQualitiesChanged(List<String> qList) async {
    setState(() {
      _selectedQualities = qList;
      _availableTakas = [];
      _selectedTakaRows = [];
      _groupBy = 'NONE';
      _expandedGroups = {};
    });
    if (qList.isNotEmpty) {
      final Set<String> allMills = {};
      for (final q in qList) {
        final millsForQ = await _service.getUniqueMillsForQuality(q);
        allMills.addAll(millsForQ);
      }
      if (mounted) {
        setState(() {
          _mills = allMills.toList();
        });
      }
    } else {
      await _loadMills();
    }
    await _loadAvailableTakas();
  }

  Future<void> _onMillChanged(String? m) async {
    setState(() {
      _selectedMill = m;
      _availableTakas = [];
      _selectedTakaRows = [];
      _groupBy = 'NONE';
      _expandedGroups = {};
    });
    if (_selectedQualities.isNotEmpty && m != null) {
      await _loadAvailableTakas();
    }
  }

  Future<void> _handleCloseAddRequest() async {
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
              children: sortOptions.map((opt) {
                final isSelected = _sortBy == opt['value'];
                return ListTile(
                  dense: true,
                  leading: Icon(opt['icon'] as IconData, size: 14, color: isSelected ? colors.primary : colors.textMuted),
                  title: Text(
                    opt['label'] as String,
                    style: OrganismTheme.bodyMedium(context).copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                  trailing: isSelected ? Icon(LucideIcons.check, size: 14, color: colors.primary) : null,
                  onTap: () {
                    setState(() {
                      _sortBy = opt['value'] as String;
                      _currentPage = 1;
                    });
                    setPopoverState(() {});
                    _loadCards();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCardSelected(CuttingBatchSummaryModel batch) async {
    setState(() {
      _selectedCard = batch;
      _batchSummary = batch;
      _siblingCards = [];
      _loadingBatchDetail = true;
    });

    final siblings = await _service.getSiblingCards(batch.multiVno);
    if (mounted && _selectedCard?.multiVno == batch.multiVno) {
      setState(() {
        _siblingCards = siblings;
        _loadingBatchDetail = false;
      });
    }
  }

  Future<void> _saveBatch() async {
    if (_selectedQualities.isEmpty || _selectedMill == null) {
      PlasmaToastManager.instance.show(context, 'Please select at least one Quality and a Mill first.', variant: CellBadgeVariant.warning);
      return;
    }
    if (_selectedTakaRows.isEmpty) {
      PlasmaToastManager.instance.show(context, 'Please select at least one Taka card.', variant: CellBadgeVariant.warning);
      return;
    }

    final totalFresh = double.tryParse(_freshPcsController.text) ?? 0.0;
    if (totalFresh <= 0) {
      PlasmaToastManager.instance.show(context, 'Please enter a valid fresh piece count.', variant: CellBadgeVariant.warning);
      return;
    }

    try {
      final payload = {
        'mill': _selectedMill,
        'greyqual': _selectedQualities.join(', '),
        'cut_date': _batchDate.toIso8601String(),
        'cut_length': _cutLength,
        'avg_wt': (double.tryParse(_sareeWtController.text) ?? 400.0) / 1000.0, // convert g to kg
        'total_fresh_pcs': totalFresh.toInt(),
        'total_second_pcs': (double.tryParse(_secondPcsController.text) ?? 0.0).toInt(),
        'total_fent_wt': double.tryParse(_fentWtController.text) ?? 0.0,
        'job_type': _selectedJobType,
        'value_addition': _selectedValueAddition,
        'screen': _screenController.text.isNotEmpty ? _screenController.text : null,
        'sb_cardpic': _picController.text.isNotEmpty ? _picController.text : null,
        'selected_cards': _selectedTakaRows,
        'start_multi_vno': int.tryParse(_startMultiVnoController.text) ?? 0,
        'edit_multi_vno': _editingMultiVno,
      };

      PlasmaToastManager.instance.show(context, 'Saving cutting batch transaction...', variant: CellBadgeVariant.primary);

      final result = await _service.saveCuttingBatch(payload);

      if (mounted) {
        final targetMultiVno = (result?['multi_vno'] as num?)?.toInt();

        PlasmaToastManager.instance.show(
          context, 
          _editingMultiVno != null
              ? 'Saved successfully! Batch #$_editingMultiVno updated.'
              : 'Saved successfully! Batch #$targetMultiVno created.', 
          variant: CellBadgeVariant.success
        );

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
    } catch (e) {
      if (mounted) {
        final cleanError = e.toString()
            .replaceAll('Exception:', '')
            .replaceAll('PostgrestException:', '')
            .trim();
        PlasmaToastManager.instance.show(
          context, 
          'Failed to save batch: $cleanError', 
          variant: CellBadgeVariant.error
        );
      }
    }
  }

  Future<void> _startEditBatch(CuttingBatchSummaryModel batch) async {
    final controller = KineticWorkspaceProvider.of(context);

    // Pre-populate creation state with this batch's values
    setState(() {
      _editingMultiVno = batch.multiVno;
      _selectedQualities = batch.greyQual.split(', ').map((s) => s.trim()).toList();
      _selectedMill = batch.mill;
      _batchDate = batch.cutDate;
      _cutLength = batch.cutLength;
      
      _freshPcsController.text = batch.totalFreshPcs.toString();
      _secondPcsController.text = batch.totalSecondPcs.toString();
      _sareeWtController.text = (batch.avgWt * 1000.0).round().toString(); // Kg to Grams
      _fentWtController.text = batch.totalFentWt.toString();
      _screenController.text = batch.screen ?? '';
      _picController.text = batch.sbCardPic ?? '';
      _startMultiVnoController.text = batch.multiVno.toString();
      
      // Initialize selected cards and available cards
      _availableTakas = [];
      _selectedTakaRows = [];
    });

    // Load qualities, mills, and the available takas
    await _loadQualities();
    await _loadMills();
    
    // We already have sibling cards loaded in state as _siblingCards!
    // But we need to make sure we query available takas, which will fetch the cut cards of this batch too
    // since we set _editingMultiVno!
    await _loadAvailableTakas();

    if (!mounted) return;

    // Show overlay
    controller.showOverlay(
      content: _buildAddCanvas(context),
      onCloseRequest: _handleCloseAddRequest,
    );
  }

  Future<void> _attachCuttingCardScan() async {
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
          entityType: 'cutting_batch',
          entityId: _batchSummary!.multiVno.toString(),
          entityLabel: 'Batch #${_batchSummary!.multiVno}',
          mediaType: 'cutting_card_front',
        );
        
        // Reload batch summary
        final updatedSummary = await _service.getBatchSummary(_batchSummary!.multiVno);
        if (mounted && updatedSummary != null) {
          setState(() {
            _batchSummary = updatedSummary;
            _selectedCard = updatedSummary;
          });
          PlasmaToastManager.instance.show(context, 'Cutting card scan attached.', variant: CellBadgeVariant.success);
          _loadCards();
        }
      }
    } catch (e) {
      print('Error uploading cutting card scan: $e');
      if (mounted) {
        PlasmaToastManager.instance.show(context, 'Upload failed: $e', variant: CellBadgeVariant.error);
      }
    }
  }

  Future<void> _removeCuttingCardScan() async {
    try {
      final confirm = await PlasmaAlertDialog.show(
        context: context,
        title: 'Delete Scan?',
        message: 'Are you sure you want to delete this cutting card scan?',
        isDestructive: true,
      );
      if (confirm != true) return;

      final mediaList = await MediaService().getMediaForEntity('cutting_batch', _batchSummary!.multiVno.toString());
      for (final m in mediaList) {
        await MediaService().archiveMedia(m.id);
      }
      
      // Clear columns directly in DB
      await Supabase.instance.client
          .schema('IMMBE2627')
          .from('sb_cutdet_summary')
          .update({'sb_cardpic': null})
          .eq('MULTI_VNO', _batchSummary!.multiVno);

      await Supabase.instance.client
          .schema('IMMBE2627')
          .from('sb_cutdet')
          .update({'sb_cardpic': null})
          .eq('MULTI_VNO', _batchSummary!.multiVno);

      final updatedSummary = await _service.getBatchSummary(_batchSummary!.multiVno);
      if (mounted && updatedSummary != null) {
        setState(() {
          _batchSummary = updatedSummary;
          _selectedCard = updatedSummary;
        });
        PlasmaToastManager.instance.show(context, 'Scan detached.', variant: CellBadgeVariant.success);
        _loadCards();
      }
    } catch (e) {
      print('Error removing scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final controller = KineticWorkspaceProvider.of(context);

    return SystemAppMasterLayout(
      paneHeader: OrganPaneHeader(
        title: 'Cutting Cards',
        searchController: _searchController,
        onSearchChanged: (val) {
          setState(() {
            _currentPage = 1;
          });
          _loadCards();
        },
        filterContent: _buildFilterPopover(context),
        sortContent: _buildSortPopover(context),
        onAddPressed: () {
          // Reset dialog state
          setState(() {
            _editingMultiVno = null;
            _selectedQualities = [];
            _selectedMill = null;
            _availableTakas = [];
            _selectedTakaRows = [];
            _batchDate = DateTime.now();
            _cutLength = 5.20; // default 5.20 as requested
            _groupBy = 'NONE';
            _expandedGroups = {};
            _freshPcsController.text = '0';
            _secondPcsController.text = '0';
            _sareeWtController.text = '400';
            _fentWtController.text = '0.00';
            _screenController.clear();
            _picController.clear();
            _startMultiVnoController.clear();
          });
          _loadQualities();
          _loadMills();
          _loadNextMultiVno();
          controller.showOverlay(
            content: _buildAddCanvas(context),
            onCloseRequest: _handleCloseAddRequest,
          );
        },
      ),
      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _cards.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (p) {
          setState(() => _currentPage = p);
          _loadCards();
        },
        itemBuilder: (context, index) {
          final batch = _cards[index];
          final isSelected = _selectedCard?.multiVno == batch.multiVno;

          return Padding(
            padding: const EdgeInsets.only(bottom: OrganismTheme.spacingSm),
            child: TissueListCard(
              isCompact: false,
              leading: CellCardAvatar(date: batch.cutDate),
              title: Text(
                batch.greyQual,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                batch.mill,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: CellBadge(
                text: batch.ccCode,
                variant: CellBadgeVariant.primary,
              ),
              footer: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${batch.totalFreshPcs} Pcs',
                  style: OrganismTheme.bodySmall(context).copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              isSelected: isSelected,
              onTap: () => _onCardSelected(batch),
            ),
          );
        },
      ),
      sectionCanvas:
          _selectedCard != null ? _buildSectionCanvas(context, colors) : null,
      isDetailVisible: _selectedCard != null,

      emptyTitle: 'No Cutting Batch Selected',
      emptyMessage:
          'Select a batch from the registry to view its cutting metrics and status.',
      emptyIcon: LucideIcons.scissors,
    );
  }

  Widget _buildAddCanvas(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setStateOverlay) {
        final colors = OrganismTheme.colorsOf(context);

        // ── Live Calculations ─────────────────────────────────────────

        final double totalReceivedMts = _selectedTakaRows.fold(
          0.0,
          (sum, row) =>
              sum +
              ((row['RMTS'] as num?)?.toDouble() ??
                  (row['PMTS'] as num?)?.toDouble() ??
                  (row['WMTS'] as num?)?.toDouble() ??
                  0.0),
        );
        final double totalInputMts = _selectedTakaRows.fold(
          0.0,
          (sum, row) =>
              sum +
              ((row['WMTS'] as num?)?.toDouble() ?? 0.0),
        );
        final double shortagePct = totalInputMts > 0
            ? (totalReceivedMts / totalInputMts * 100)
            : 0.0;

        final double avgWtKg =
            (double.tryParse(_sareeWtController.text) ?? 400.0) / 1000.0;
        final double totalFreshPcs =
            double.tryParse(_freshPcsController.text) ?? 0.0;
        final double totalSecondPcs =
            double.tryParse(_secondPcsController.text) ?? 0.0;
        final double totalFentWt =
            double.tryParse(_fentWtController.text) ?? 0.0;

        // Fresh Fabric
        final double calculatedFreshMts = totalFreshPcs * _cutLength;
        final double freshPct = totalReceivedMts > 0
            ? (calculatedFreshMts / totalReceivedMts * 100)
            : 0.0;

        // Second Fabric (assume cut of 5)
        final double calculatedSecondMts = totalSecondPcs * 5.0;
        final double secondPct = totalReceivedMts > 0
            ? (calculatedSecondMts / totalReceivedMts * 100)
            : 0.0;

        // Fent Fabric (derived by weight)
        final double calculatedFentMts = avgWtKg > 0
            ? (totalFentWt / avgWtKg) * _cutLength
            : 0.0;
        final double fentPct = totalReceivedMts > 0
            ? (calculatedFentMts / totalReceivedMts * 100)
            : 0.0;

        final int rollCount = _selectedTakaRows.length;

        return OrganThreePaneCanvas(
          title: 'New Cutting Card Batch',
          onClose: _handleCloseAddRequest,

          // ── Header Actions (Button Bar) ─────────────────────────────
          trailingAction: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CellButton(
                text: 'Cancel',
                icon: LucideIcons.x,
                variant: CellButtonVariant.outline,
                onPressed: () => _handleCloseAddRequest(),
              ),
              const SizedBox(width: OrganismTheme.spacingSm),
              CellButton(
                text: rollCount > 0
                    ? 'Confirm Batch · $rollCount rolls'
                    : 'Confirm Batch',
                icon: LucideIcons.check,
                variant: CellButtonVariant.primary,
                onPressed: rollCount > 0 ? () => _saveBatch() : null,
              ),
            ],
          ),

          stepBar: ThreePaneStepBar(
            steps: [
              ThreePaneStep(
                label: 'GREY QUALITY',
                isComplete: _selectedQualities.isNotEmpty,
                child: CellAutocomplete<String>(
                  isCompact: true,
                  placeholder: 'Search Quality...',
                  items: _qualities,
                  isMultiSelect: true,
                  selectedValues: _selectedQualities,
                  onSelectedValuesChanged: (qList) async {
                    await _onQualitiesChanged(qList);
                    setStateOverlay(() {});
                  },
                  labelBuilder: (v) => v,
                ),
              ),
              ThreePaneStep(
                label: 'PROCESSING MILL',
                isComplete: _selectedMill != null,
                child: CellAutocomplete<String>(
                  isCompact: true,
                  placeholder: _selectedQualities.isEmpty
                      ? 'Select quality first'
                      : 'Search Mill...',
                  items: _mills,
                  value: _selectedMill,
                  onChanged: (v) async {
                    await _onMillChanged(v);
                    setStateOverlay(() {});
                  },
                  labelBuilder: (v) => v,
                ),
              ),
              ThreePaneStep(
                label: 'CUT DATE',
                isComplete: true,
                child: CellDatePicker(
                  isCompact: true,
                  value: _batchDate,
                  onChanged: (d) {
                    setState(() => _batchDate = d);
                    setStateOverlay(() {});
                  },
                ),
              ),
            ],
          ),

          // ── LEFT PANE: FIFO Millrec Cards (Expanded) ──────────────────
          leftPane: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Consistent Header Bar for Left Pane (FIFO)
              _buildPaneHeader(
                context,
                colors,
                title: 'Available Takas',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Group By: ',
                      style: OrganismTheme.bodySmall(context).copyWith(
                        color: colors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CellToggleGroup<String>(
                      value: _groupBy,
                      items: const ['NONE', 'DATE', 'DESNO'],
                      itemBuilder: (v) => Text(
                        v,
                        style: const TextStyle(fontSize: 10),
                      ),
                      onChanged: (v) {
                        setStateOverlay(() {
                          _groupBy = v;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Card List / Groups
              Expanded(
                child: _loadingAvailable
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedQualities.isEmpty || _selectedMill == null
                        ? TissueEmptyState(
                            icon: LucideIcons.search,
                            title: 'Pending Selection',
                            message:
                                'Select Quality then Mill above to load available taka cards.',
                          )
                        : _availableTakas.isEmpty
                            ? TissueEmptyState(
                                icon: LucideIcons.checkSquare,
                                title: 'No Pending Takas',
                                message:
                                    'All rolls for this Quality + Mill are already cut.',
                              )
                            : _buildGroupedTakaList(context, colors, setStateOverlay),
              ),
            ],
          ),

          // ── CENTER PANE: Batch Spec Form (Fixed 340) ──────────────────
          centerPane: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Consistent Header Bar for Center Pane (Specs)
              _buildPaneHeader(
                context,
                colors,
                title: 'Batch Specs',
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Multi Card No
                      TissueFormField(
                        label: 'MULTI CARD NO',
                        inputCell: CellInput(
                          controller: _startMultiVnoController,
                          isNumeric: true,
                          placeholder: 'Auto-generating...',
                          onChanged: (v) {
                            setStateOverlay(() {});
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingLg),

                      // Cut Length field
                      TissueFormField(
                        label: 'CUT LENGTH (MTS)',
                        inputCell: CellInputNumber(
                          initialValue: _cutLength,
                          onChanged: (v) {
                            if (v != null) {
                              setStateOverlay(() => _cutLength = v);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingSm),
                      CellToggleGroup<double?>(
                        value: [5.20, 5.35, 6.00, 6.25].contains(_cutLength) ? _cutLength : null,
                        items: const [5.20, 5.35, 6.00, 6.25],
                        itemBuilder: (v) => Text(v!.toStringAsFixed(2)),
                        onChanged: (v) {
                          if (v != null) {
                            setStateOverlay(() => _cutLength = v);
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: OrganismTheme.spacingLg),

                      // Fresh Pieces
                      TissueFormField(
                        label: 'TOTAL FRESH PIECES',
                        inputCell: CellInputNumber(
                          initialValue: double.tryParse(_freshPcsController.text) ?? 0.0,
                          suffix: 'PCS',
                          onChanged: (v) {
                            _freshPcsController.text = (v ?? 0).toInt().toString();
                            setStateOverlay(() {});
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingLg),

                      // Second Pieces
                      TissueFormField(
                        label: 'TOTAL SECOND PIECES',
                        inputCell: CellInputNumber(
                          initialValue: double.tryParse(_secondPcsController.text) ?? 0.0,
                          suffix: 'PCS',
                          onChanged: (v) {
                            _secondPcsController.text = (v ?? 0).toInt().toString();
                            setStateOverlay(() {});
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingLg),

                      // Saree Weight
                      TissueFormField(
                        label: 'SAREE WEIGHT (GRAMS)',
                        inputCell: CellInputNumber(
                          initialValue: double.tryParse(_sareeWtController.text) ?? 400.0,
                          suffix: 'G',
                          onChanged: (v) {
                            _sareeWtController.text = (v ?? 400).toInt().toString();
                            setStateOverlay(() {});
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingLg),

                      // Fent Weight
                      TissueFormField(
                        label: 'FENT WEIGHT (KG)',
                        inputCell: CellInputNumber(
                          initialValue: double.tryParse(_fentWtController.text) ?? 0.0,
                          suffix: 'KG',
                          onChanged: (v) {
                            _fentWtController.text = (v ?? 0.0).toStringAsFixed(2);
                            setStateOverlay(() {});
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── RIGHT PANE: Live Performance (Fixed 300) ──────────────────
          rightPane: Container(
            color: colors.surfaceSubtle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Consistent Header Bar for Right Pane (Live Performance)
                _buildPaneHeader(
                  context,
                  colors,
                  title: 'Live Performance',
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Total input meters hero
                        Container(
                          padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius:
                                BorderRadius.circular(OrganismTheme.radiusMd),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL RECEIVED METERS',
                                style: OrganismTheme.labelSmall(context)
                                    .copyWith(color: colors.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${totalReceivedMts.toStringAsFixed(1)} Mts',
                                style: OrganismTheme.titleLarge(context).copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Mono',
                                  fontSize: 28,
                                  color: totalReceivedMts > 0
                                      ? colors.primary
                                      : colors.textMuted,
                                ),
                              ),
                              if (_selectedMill != null &&
                                  _selectedQualities.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '$rollCount rolls · ${_selectedQualities.join(', ')}',
                                  style: OrganismTheme.bodySmall(context)
                                      .copyWith(color: colors.textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: OrganismTheme.spacingLg),

                        _buildProgressBarRow(
                          context,
                          colors,
                          label: 'Shortage (Rec/Input)',
                          percentage: shortagePct,
                          color: colors.textMuted,
                          subtitle: '${totalReceivedMts.toStringAsFixed(1)} / ${totalInputMts.toStringAsFixed(1)} Mts',
                        ),
                        _buildProgressBarRow(
                          context,
                          colors,
                          label: 'Fresh Recovery',
                          percentage: freshPct,
                          color: colors.primary,
                          subtitle: '${calculatedFreshMts.toStringAsFixed(1)} / ${totalReceivedMts.toStringAsFixed(1)} Mts',
                        ),
                        _buildProgressBarRow(
                          context,
                          colors,
                          label: 'Seconds (Cut of 5)',
                          percentage: secondPct,
                          color: colors.warning,
                          subtitle: '${calculatedSecondMts.toStringAsFixed(1)} / ${totalReceivedMts.toStringAsFixed(1)} Mts',
                        ),
                        _buildProgressBarRow(
                          context,
                          colors,
                          label: 'Fents (By Weight)',
                          percentage: fentPct,
                          color: colors.error,
                          subtitle: '${calculatedFentMts.toStringAsFixed(1)} / ${totalReceivedMts.toStringAsFixed(1)} Mts',
                        ),

                        if (rollCount == 0) ...[
                          const SizedBox(height: OrganismTheme.spacingMd),
                          Container(
                            padding: const EdgeInsets.all(OrganismTheme.spacingSm),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(OrganismTheme.radiusSm),
                              border: Border.all(
                                  color: colors.warning.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.triangleAlert,
                                    size: 14, color: colors.warning),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Select takas to begin',
                                    style: OrganismTheme.bodySmall(context)
                                        .copyWith(color: colors.warning),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ); // OrganThreePaneCanvas
      }, // StatefulBuilder builder
    ); // StatefulBuilder
  } // _buildAddCanvas


  Widget _buildProgressBarRow(
    BuildContext context,
    OrganismColors colors, {
    required String label,
    required double percentage,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: OrganismTheme.labelSmall(context).copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: OrganismTheme.bodySmall(context).copyWith(
                        color: colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: OrganismTheme.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Mono',
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 8,
            width: double.infinity,
            color: colors.border,
            child: Row(
              children: [
                if (percentage > 0)
                  Expanded(
                    flex: (percentage.clamp(0.0, 100.0) * 10).toInt(),
                    child: Container(color: color),
                  ),
                Expanded(
                  flex: ((100.0 - percentage.clamp(0.0, 100.0)) * 10).toInt(),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: OrganismTheme.spacingMd),
      ],
    );
  }

  Widget _buildPaneHeader(
    BuildContext context,
    OrganismColors colors, {
    required String title,
    Widget? trailing,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: OrganismTheme.spacingMd,
        vertical: OrganismTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: OrganismTheme.bodySmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildGroupedTakaList(
      BuildContext context, OrganismColors colors, StateSetter setStateOverlay) {
    Map<String, List<Map<String, dynamic>>> groupedTakas = {};
    for (var card in _availableTakas) {
      final double jobRate = (card['JOBRATE'] as num?)?.toDouble() ??
          (card['jobrate'] as num?)?.toDouble() ??
          0.0;
      final String rateStr = 'Rate: ₹${jobRate.toStringAsFixed(1)}';

      String groupName;
      if (_groupBy == 'DATE') {
        final ddateStr = card['DDATE'] != null
            ? card['DDATE'].toString().split('T')[0]
            : 'N/A';
        groupName = '$rateStr · $ddateStr';
      } else if (_groupBy == 'DESNO') {
        final desNo = card['SAREEDES']?.toString() ?? 'N/A';
        groupName = '$rateStr · Design #$desNo';
      } else {
        groupName = rateStr;
      }

      groupedTakas.putIfAbsent(groupName, () => []).add(card);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingSm),
      children: groupedTakas.entries.map((entry) {
        final groupName = entry.key;
        final groupItems = entry.value;
        final isExpanded = _expandedGroups[groupName] ?? true;

        return _GroupWidget(
          title: groupName,
          items: groupItems,
          selectedItems: _selectedTakaRows,
          isExpanded: isExpanded,
          onToggle: () {
            setStateOverlay(() {
              _expandedGroups[groupName] = !isExpanded;
            });
          },
          onSelectAll: (checked) {
            setStateOverlay(() {
              if (checked) {
                for (var item in groupItems) {
                  final exists = _selectedTakaRows.any(
                      (sel) => sel['CARDNO'] == item['CARDNO']);
                  if (!exists) {
                    _selectedTakaRows.add(item);
                  }
                }
              } else {
                final cardNosToRemove =
                    groupItems.map((item) => item['CARDNO']).toSet();
                _selectedTakaRows.removeWhere(
                    (sel) => cardNosToRemove.contains(sel['CARDNO']));
              }
            });
            setState(() {});
          },
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(OrganismTheme.spacingMd),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              mainAxisSpacing: OrganismTheme.spacingMd,
              crossAxisSpacing: OrganismTheme.spacingMd,
              childAspectRatio: 0.95,
            ),
            itemCount: groupItems.length,
            itemBuilder: (context, index) {
              final card = groupItems[index];
              final cardNo = (card['CARDNO'] as num?)?.toInt() ?? 0;
              final lot = card['LOT'] as String? ?? 'N/A';
              final double cardJobRate = (card['JOBRATE'] as num?)?.toDouble() ??
                  (card['jobrate'] as num?)?.toDouble() ??
                  0.0;
              final rmts = (card['PMTS'] as num?)?.toDouble() ??
                  (card['WMTS'] as num?)?.toDouble() ??
                  (card['RMTS'] as num?)?.toDouble() ??
                  0.0;
              final rpcs = (card['RPCS'] as num?)?.toInt() ?? 0;
              final ddateStr = card['DDATE'] != null
                  ? card['DDATE'].toString().split('T')[0]
                  : 'N/A';
              final remark = (card['RECRMK'] as String? ?? '').trim();
              final isChecked = _selectedTakaRows
                  .any((row) => (row['CARDNO'] as num?)?.toInt() == cardNo);

              Color badgeColor = colors.textMuted;
              if (remark.toLowerCase().contains('raw')) {
                badgeColor = colors.textMuted;
              } else if (remark.toLowerCase().contains('emr')) {
                badgeColor = const Color(0xFF2E7D52);
              } else if (remark.toLowerCase().contains('must')) {
                badgeColor = const Color(0xFFB8860B);
              } else if (remark.toLowerCase().contains('mar') ||
                  remark.toLowerCase().contains('bur')) {
                badgeColor = const Color(0xFF8B2252);
              } else if (remark.toLowerCase().contains('ivo')) {
                badgeColor = const Color(0xFF8B7355);
              } else if (remark.isNotEmpty) {
                badgeColor = colors.primary;
              }

              return GestureDetector(
                onTap: () {
                  setStateOverlay(() {
                    if (isChecked) {
                      _selectedTakaRows.removeWhere(
                          (row) => (row['CARDNO'] as num?)?.toInt() == cardNo);
                    } else {
                      _selectedTakaRows.add(card);
                    }
                  });
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(OrganismTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? colors.primary.withValues(alpha: 0.08)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(OrganismTheme.radiusSm),
                    border: Border.all(
                      color: isChecked ? colors.primary : colors.border,
                      width: isChecked ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$cardNo',
                              style: OrganismTheme.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Mono',
                                color: colors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            isChecked
                                ? LucideIcons.circleCheck
                                : LucideIcons.circle,
                            size: 14,
                            color: isChecked ? colors.primary : colors.textMuted,
                          ),
                        ],
                      ),
                      Text(
                        'Lot $lot · ₹${cardJobRate.toStringAsFixed(1)}',
                        style: OrganismTheme.bodySmall(context).copyWith(
                          color: colors.textMuted,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '${rmts.toStringAsFixed(1)} mts',
                        style: OrganismTheme.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Mono',
                        ),
                      ),
                      if (rpcs > 0)
                        Text(
                          '$rpcs pcs',
                          style: OrganismTheme.bodySmall(context).copyWith(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      Text(
                        ddateStr,
                        style: OrganismTheme.bodySmall(context).copyWith(
                          fontSize: 9,
                          color: colors.textMuted,
                        ),
                      ),
                      if (remark.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: badgeColor.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            remark.length > 10
                                ? remark.substring(0, 10)
                                : remark,
                            style: OrganismTheme.labelSmall(context)
                                .copyWith(color: badgeColor, fontSize: 8),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }


  Widget _buildSectionCanvas(BuildContext context, OrganismColors colors) {

    if (_selectedCard == null) return const SizedBox.shrink();

    final card = _selectedCard!;

    return ListView(
      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
      children: [
        // Sibling Roll Batch Header Card (Dashboard summary)
        if (_batchSummary != null) ...[
          CellBox(
            padding: const EdgeInsets.all(OrganismTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BATCH CUTTING SUMMARY',
                            style: OrganismTheme.labelSmall(context)
                                .copyWith(color: colors.textMuted)),
                        Text(_batchSummary!.ccCode,
                            style: OrganismTheme.displayLarge(context)),
                      ],
                    ),
                    Row(
                      children: [
                        CellButton(
                          text: 'Edit Batch',
                          icon: LucideIcons.edit2,
                          variant: CellButtonVariant.outline,
                          isCompact: true,
                          onPressed: () => _startEditBatch(_batchSummary!),
                        ),
                        const SizedBox(width: OrganismTheme.spacingSm),
                        CellBadge(
                          text: _batchSummary!.sbStatus,
                          variant: CellBadgeVariant.primary,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: OrganismTheme.spacingXl),
                
                Row(
                  children: [
                    Expanded(child: _buildDetailedRow(context, 'Mill Processing House', _batchSummary!.mill)),
                    const SizedBox(width: OrganismTheme.spacingLg),
                    Expanded(child: _buildDetailedRow(context, 'Base Grey Quality', _batchSummary!.greyQual)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildDetailedRow(context, 'Selected Slicing Cut', '${_batchSummary!.cutLength.toStringAsFixed(2)} Mts')),
                    const SizedBox(width: OrganismTheme.spacingLg),
                    Expanded(child: _buildDetailedRow(context, 'Avg Saree Weight', '${(_batchSummary!.avgWt * 1000).toInt()} Grams')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildDetailedRow(context, 'Job Cost Type', _batchSummary!.jobType)),
                    const SizedBox(width: OrganismTheme.spacingLg),
                    Expanded(child: _buildDetailedRow(context, 'Value Addition', _batchSummary!.valueAddition)),
                  ],
                ),
                if (_batchSummary!.screen != null)
                  _buildDetailedRow(context, 'Printing Screen Reference', _batchSummary!.screen!),

                const SizedBox(height: OrganismTheme.spacingLg),
                const Divider(),
                const SizedBox(height: OrganismTheme.spacingMd),
                
                // Aggregates Grid
                Text('BATCH QUANTITATIVE PERFORMANCES', style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted)),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(context, colors, 'TOTAL FRESH PCS',
                          '${_batchSummary!.totalFreshPcs} Pcs', LucideIcons.layers),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: _buildMetricCard(context, colors, 'TOTAL FRESH METERS',
                          '${_batchSummary!.totalFreshMts.toStringAsFixed(1)} Mts', LucideIcons.ruler),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: _buildMetricCard(context, colors, 'TOTAL SAREE WEIGHT',
                          '${_batchSummary!.totalSareeWt.toStringAsFixed(1)} KG', LucideIcons.scale),
                    ),
                  ],
                ),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(context, colors, 'TOTAL SECOND PCS',
                          '${_batchSummary!.totalSecondPcs} Pcs', LucideIcons.alertCircle),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: _buildMetricCard(context, colors, 'TOTAL SECOND METERS',
                          '${_batchSummary!.totalSecondMts.toStringAsFixed(1)} Mts', LucideIcons.alertOctagon),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: _buildMetricCard(context, colors, 'TOTAL FENT WASTE',
                          '${_batchSummary!.totalFentMts.toStringAsFixed(1)} Mts', LucideIcons.trash2),
                    ),
                  ],
                ),

                const SizedBox(height: OrganismTheme.spacingXl),

                // Recovery Splitting chart
                Text('BATCH RECOVERY SPLITTING', style: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted)),
                const SizedBox(height: OrganismTheme.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    color: colors.border,
                    child: Row(
                      children: [
                        if (_batchSummary!.freshPct > 0)
                          Expanded(
                            flex: _batchSummary!.freshPct.toInt(),
                            child: Container(color: colors.primary, child: const Center(child: Text('F', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)))),
                          ),
                        if (_batchSummary!.secondPct > 0)
                          Expanded(
                            flex: _batchSummary!.secondPct.toInt(),
                            child: Container(color: colors.warning, child: const Center(child: Text('S', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)))),
                          ),
                        if (_batchSummary!.fentPct > 0)
                          Expanded(
                            flex: _batchSummary!.fentPct.toInt(),
                            child: Container(color: colors.error, child: const Center(child: Text('W', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)))),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacingXs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fresh Recovery: ${_batchSummary!.freshPct.toStringAsFixed(1)}%', style: OrganismTheme.bodySmall(context).copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
                    Text('Seconds Recovery: ${_batchSummary!.secondPct.toStringAsFixed(1)}%', style: OrganismTheme.bodySmall(context).copyWith(color: colors.warning, fontWeight: FontWeight.bold)),
                    Text('Fent Waste: ${_batchSummary!.fentPct.toStringAsFixed(1)}%', style: OrganismTheme.bodySmall(context).copyWith(color: colors.error, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingLg),
        ],

        // CUTTING CARD PHOTO ATTACHMENT SECTION
        Text('CUTTING CARD SCAN', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: OrganismTheme.spacingSm),
        CellBox(
          padding: const EdgeInsets.all(OrganismTheme.spacingMd),
          child: _batchSummary!.sbCardPic != null && _batchSummary!.sbCardPic!.isNotEmpty
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        MediaService().getPublicUrl(_batchSummary!.sbCardPic!, width: 240, height: 240),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(LucideIcons.fileImage, size: 36),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('A photo scan is attached to this cutting batch.', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Path: ${_batchSummary!.sbCardPic}', style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CellButton(
                                text: 'Change Picture',
                                icon: LucideIcons.refreshCw,
                                variant: CellButtonVariant.outline,
                                isCompact: true,
                                onPressed: _attachCuttingCardScan,
                              ),
                              const SizedBox(width: 8),
                              CellButton(
                                text: 'Delete Scan',
                                icon: LucideIcons.trash2,
                                variant: CellButtonVariant.destructive,
                                isCompact: true,
                                onPressed: _removeCuttingCardScan,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Icon(LucideIcons.fileImage, size: 32, color: colors.textMuted),
                        const SizedBox(height: 8),
                        Text('No cutting card photo attached.', style: TextStyle(color: colors.textMuted)),
                        const SizedBox(height: 12),
                        CellButton(
                          text: 'Attach Card Picture',
                          icon: LucideIcons.plus,
                          variant: CellButtonVariant.outline,
                          isCompact: true,
                          onPressed: _attachCuttingCardScan,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: OrganismTheme.spacingLg),

        // Sibling Roll breakdown PlutoGrid
        Text('PRO-RATA BREAKDOWN BY TAKA ROLLS', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: OrganismTheme.spacingSm),
        
        Container(
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: OrganismTheme.borderSm,
          ),
          child: _loadingBatchDetail
              ? const Center(child: CircularProgressIndicator())
              : _siblingCards.isEmpty
                  ? _buildFallbackSingleRollInfo(context, card)
                  : _buildSiblingCardsGrid(context, colors),
        ),

        const SizedBox(height: OrganismTheme.spacingXl),

        // Footer Info
        CellBox(
          padding: const EdgeInsets.all(OrganismTheme.spacingMd),
          backgroundColor: colors.surfaceSubtle,
          child: Row(
            children: [
              Icon(LucideIcons.activity, size: 16, color: colors.textMuted),
              const SizedBox(width: 8),
              Text('Status: ${card.sbStatus}',
                  style: OrganismTheme.bodySmall(context)),
              if (_siblingCards.isNotEmpty && _siblingCards.first.creator.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(LucideIcons.user, size: 14, color: colors.textMuted),
                const SizedBox(width: 6),
                Text('Creator: ${_siblingCards.first.creator.toUpperCase()}',
                    style: OrganismTheme.bodySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    )),
              ],
              const Spacer(),
              Text(
                  'Cut Date: ${card.cutDate.toLocal().toString().split(' ')[0]}',
                  style: OrganismTheme.bodySmall(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackSingleRollInfo(BuildContext context, CuttingBatchSummaryModel batch) {
    return const Center(
      child: Text('No sibling rolls found for this batch.'),
    );
  }

  Widget _buildSiblingCardsGrid(BuildContext context, OrganismColors colors) {
    final List<PlutoColumn> columns = [
      PlutoColumn(
        title: 'CUT CARD NO',
        field: 'cut_card_no',
        type: PlutoColumnType.number(),
        width: 140,
      ),
      PlutoColumn(
        title: 'GREY CARD (TAKA)',
        field: 'card_no',
        type: PlutoColumnType.number(),
        width: 160,
      ),
      PlutoColumn(
        title: 'LOT',
        field: 'lot',
        type: PlutoColumnType.text(),
        width: 110,
      ),
      PlutoColumn(
        title: 'INPUT RMTS',
        field: 'rmts',
        type: PlutoColumnType.number(format: '#,##0.00'),
        width: 130,
      ),
      PlutoColumn(
        title: 'FRESH CPCS',
        field: 'cpcs',
        type: PlutoColumnType.number(),
        width: 130,
      ),
      PlutoColumn(
        title: 'FRESH CMTS',
        field: 'cmts',
        type: PlutoColumnType.number(format: '#,##0.00'),
        width: 130,
      ),
      PlutoColumn(
        title: 'SECONDS',
        field: 'seconds',
        type: PlutoColumnType.number(),
        width: 120,
      ),
      PlutoColumn(
        title: 'FENT MTS',
        field: 'fent_mts',
        type: PlutoColumnType.number(format: '#,##0.00'),
        width: 120,
      ),
      PlutoColumn(
        title: 'FENT WT (KG)',
        field: 'fent_wt',
        type: PlutoColumnType.number(format: '0.000'),
        width: 130,
      ),
    ];

    final List<PlutoRow> rows = _siblingCards.map((sibling) {
      return PlutoRow(cells: {
        'cut_card_no': PlutoCell(value: sibling.cutCardNo),
        'card_no': PlutoCell(value: sibling.cardNo),
        'lot': PlutoCell(value: sibling.lot),
        'rmts': PlutoCell(value: sibling.rmts),
        'cpcs': PlutoCell(value: sibling.pieces.toInt()),
        'cmts': PlutoCell(value: sibling.meters),
        'seconds': PlutoCell(value: sibling.seconds.toInt()),
        'fent_mts': PlutoCell(value: sibling.fentMts),
        'fent_wt': PlutoCell(value: sibling.fentWt),
      });
    }).toList();

    return PlutoGrid(
      columns: columns,
      rows: rows,
      onChanged: (PlutoGridOnChangedEvent event) {},
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBackgroundColor: colors.surface,
          rowColor: colors.surface,
          gridBorderColor: colors.border,
          columnTextStyle: OrganismTheme.labelSmall(context).copyWith(color: colors.textMuted),
          cellTextStyle: OrganismTheme.bodyMedium(context).copyWith(fontFamily: 'Mono'),
          activatedColor: colors.primary.withValues(alpha: 0.1),
          iconColor: colors.primary,
        ),
      ),
    );
  }

  Widget _buildDetailedRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OrganismTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: OrganismTheme.bodyMedium(context)
                  .copyWith(color: OrganismTheme.colorsOf(context).textMuted)),
          Text(value,
              style: OrganismTheme.bodyMedium(context)
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, OrganismColors colors,
      String label, String value, IconData icon) {
    return CellBox(
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colors.textMuted),
              const SizedBox(width: 8),
              Text(label,
                  style: OrganismTheme.labelSmall(context)
                      .copyWith(color: colors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: OrganismTheme.titleLarge(context)
                  .copyWith(fontFamily: 'Mono')),
        ],
      ),
    );
  }
}

class _GroupWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> selectedItems;
  final Function(bool) onSelectAll;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _GroupWidget({
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelectAll,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final allSelected = items.isNotEmpty &&
        items.every((item) =>
            selectedItems.any((sel) => sel['CARDNO'] == item['CARDNO']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OrganismTheme.spacingMd,
            vertical: OrganismTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            border: Border(
              top: BorderSide(color: colors.border),
              bottom: BorderSide(color: colors.border),
            ),
          ),
          child: Row(
            children: [
              CellCheckbox(
                value: allSelected,
                onChanged: (val) {
                  onSelectAll(val);
                },
              ),
              const SizedBox(width: OrganismTheme.spacingSm),
              Expanded(
                child: Text(
                  '$title (${items.length} rolls)',
                  style: OrganismTheme.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded
                      ? LucideIcons.chevronDown
                      : LucideIcons.chevronRight,
                  size: 18,
                  color: colors.textMuted,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
        if (isExpanded) child,
      ],
    );
  }
}


