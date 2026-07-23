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

  RealtimeChannel? _realtimeChannel;

  bool _isPickerActive = false;

  // Right Drawer Media Library Picker state
  String? _drawerSide;
  String _drawerSearch = '';
  List<MediaModel> _unlinkedMediaList = [];
  bool _isLoadingDrawerMedia = false;

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
    if (_isPickerActive) return;
    _isPickerActive = true;
    final summary = _batchSummary;
    if (summary == null) {
      _isPickerActive = false;
      return;
    }
    try {
      // Yield thread to let current gesture arena & button hover states settle
      await Future.delayed(Duration.zero);
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        final bytes = file.bytes ??
            (filePath != null ? await File(filePath).readAsBytes() : null);
        if (!mounted) return;
        if (bytes == null) {
          throw Exception('No file data available.');
        }

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
              });
          PlasmaToastManager.instance.show(context, 'Cutting card scan attached.', variant: CellBadgeVariant.success);
          _loadCards();
        }
      }
    } catch (e) {
      debugPrint('Error uploading side scan: $e');
      if (mounted) {
        setState(() {
          });
        PlasmaToastManager.instance.show(context, 'Upload failed: $e', variant: CellBadgeVariant.error);
      }
    } finally {
      _isPickerActive = false;
    }
  }

  void _openMediaPickerDrawer(String side) {
    _drawerSide = side;
    _drawerSearch = '';
    _unlinkedMediaList = [];
    _isLoadingDrawerMedia = false;

    PlasmaDrawer.show(
      context: context,
      title: 'Link ${side == 'F' ? 'Front' : 'Back'} Scan',
      subtitle: 'Select an unlinked scan from the media library to associate.',
      width: 420,
      content: StatefulBuilder(
        builder: (context, setDrawerState) {
          final colors = OrganismTheme.colorsOf(context);

          // Trigger loading of available media on open
          if (_unlinkedMediaList.isEmpty && !_isLoadingDrawerMedia && _drawerSearch.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadUnlinkedMediaForDrawer(setDrawerState);
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Box
              CellInput(
                placeholder: 'Search unlinked scans...',
                prefixIcon: LucideIcons.search,
                onChanged: (val) {
                  setDrawerState(() {
                    _drawerSearch = val;
                  });
                  _loadUnlinkedMediaForDrawer(setDrawerState);
                },
              ),
              const SizedBox(height: 16),

              // Drawer List
              if (_isLoadingDrawerMedia)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_unlinkedMediaList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No unlinked production media found.',
                      style: TextStyle(color: colors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _unlinkedMediaList.length,
                  itemBuilder: (context, idx) {
                    final media = _unlinkedMediaList[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: colors.surfaceSubtle,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.all(6),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: colors.border.withValues(alpha: 0.1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: media.thumbPath != null && media.thumbPath!.isNotEmpty
                              ? Image.network(
                                  MediaService().getPublicUrl(media.thumbPath!),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  MediaService().getPublicUrl(media.filePath, width: 80, height: 80),
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(LucideIcons.fileImage, size: 16),
                                ),
                        ),
                        title: Text(
                          media.fileName,
                          style: OrganismTheme.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          media.fileSizeFormatted,
                          style: TextStyle(fontSize: 10, color: colors.textMuted),
                        ),
                        trailing: CellButton(
                          text: 'Link',
                          variant: CellButtonVariant.primary,
                          onPressed: () async {
                            await _linkMediaFromLibrary(media);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadUnlinkedMediaForDrawer([StateSetter? setDrawerState]) async {
    if (setDrawerState != null) {
      setDrawerState(() {
        _isLoadingDrawerMedia = true;
      });
    } else {
      setState(() {
        _isLoadingDrawerMedia = true;
      });
    }
    try {
      final res = await MediaService().getMedia(
        limit: 100,
        isLinked: false,
        bucket: 'production',
        searchTerm: _drawerSearch,
      );
      if (mounted) {
        if (setDrawerState != null) {
          setDrawerState(() {
            _unlinkedMediaList = res.data;
            _isLoadingDrawerMedia = false;
          });
        } else {
          setState(() {
            _unlinkedMediaList = res.data;
            _isLoadingDrawerMedia = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading drawer media: $e');
      if (mounted) {
        if (setDrawerState != null) {
          setDrawerState(() {
            _isLoadingDrawerMedia = false;
          });
        } else {
          setState(() {
            _isLoadingDrawerMedia = false;
          });
        }
      }
    }
  }

  Future<void> _linkMediaFromLibrary(MediaModel media) async {
    final summary = _batchSummary;
    final side = _drawerSide;
    if (summary == null || side == null) return;

    setState(() {
    });

    try {
      // 1. Link media to the cutting card
      final ext = media.fileName.contains('.') ? media.fileName.split('.').last.toLowerCase() : 'jpg';
      final ccCode = 'CC-${summary.multiVno.toString().padLeft(4, '0')}';
      final targetFileName = '$ccCode-$side.$ext';
      final targetFilePath = 'production/cutting/${summary.multiVno}/$targetFileName';

      // Call DB RPC link_media_to_entity via MediaService
      final label = 'Cutting Card #${summary.multiVno}';
      await MediaService().linkToEntity(
        media.id,
        'cutting_batch',
        summary.multiVno.toString(),
        label,
      );

      // Update side and metadata on sb_media
      await Supabase.instance.client
          .schema('IMMBE2627')
          .from('sb_media')
          .update({
            'side': side,
            'media_type': 'cutting_card',
            'file_path': targetFilePath,
            'file_name': targetFileName,
            'display_name': '$ccCode · ${side == 'F' ? 'Front' : 'Back'}',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', media.id);

      // Also move/rename in Supabase Storage if the path changed
      try {
        if (media.filePath != targetFilePath) {
          await Supabase.instance.client.storage.from('ambaji-media').copy(media.filePath, targetFilePath);
          await Supabase.instance.client.storage.from('ambaji-media').remove([media.filePath]);
          
          if (media.thumbPath != null && media.thumbPath!.isNotEmpty) {
            final newThumbPath = 'production/cutting/${summary.multiVno}/thumbnails/$targetFileName';
            await Supabase.instance.client.storage.from('ambaji-media').copy(media.thumbPath!, newThumbPath);
            await Supabase.instance.client.storage.from('ambaji-media').remove([media.thumbPath!]);
            
            await Supabase.instance.client
                .schema('IMMBE2627')
                .from('sb_media')
                .update({'thumb_path': newThumbPath})
                .eq('id', media.id);
          }
        }
      } catch (e) {
        debugPrint('Storage relocation warning: $e');
      }

      // 2. If it's FRONT side, set sb_cardpic path on cutting card
      if (side == 'F') {
        await Supabase.instance.client
            .schema('IMMBE2627')
            .from('sb_cutdet_summary')
            .update({'sb_cardpic': targetFilePath})
            .eq('MULTI_VNO', summary.multiVno);

        await Supabase.instance.client
            .schema('IMMBE2627')
            .from('sb_cutdet')
            .update({'sb_cardpic': targetFilePath})
            .eq('MULTI_VNO', summary.multiVno);
      }
      if (!mounted) return;
      PlasmaToastManager.instance.show(context, 'Media item linked to cutting card.', variant: CellBadgeVariant.success);
      
      // Reload details
      final updatedSummary = await _service.getBatchSummary(summary.multiVno);
      final mediaList = await MediaService().getMediaForEntity('cutting_batch', summary.multiVno.toString());

      if (mounted) {
        setState(() {
          _batchSummary = updatedSummary;
          _selectedCard = updatedSummary;
          _batchMedia = mediaList;
          });
        _loadCards();
      }
    } catch (e) {
      debugPrint('Error linking media: $e');
      if (mounted) {
        setState(() {});
        PlasmaToastManager.instance.show(context, 'Linking failed: $e', variant: CellBadgeVariant.error);
      }
    }
  }

  Future<void> _delinkSpecificSideScan(String side, MediaModel media) async {
    final summary = _batchSummary;
    if (summary == null) return;

    final confirm = await PlasmaAlertDialog.show(
      context: context,
      title: 'Delink Scan?',
      message: 'Are you sure you want to delink this scan from the cutting card? The image will remain in the Media Library as unlinked.',
      isDestructive: true,
    );
    if (confirm != true) return;

    setState(() {
    });

    try {
      // 1. Delink from sb_media (marks is_linked = false, clears entity properties)
      await MediaService().delinkFromEntity(media.id);

      // 2. If it was the front scan, clear cardpic inside sb_cutdet tables
      if (side == 'F') {
        await Supabase.instance.client
            .schema('IMMBE2627')
            .from('sb_cutdet_summary')
            .update({'sb_cardpic': null})
            .eq('MULTI_VNO', summary.multiVno);

        await Supabase.instance.client
            .schema('IMMBE2627')
            .from('sb_cutdet')
            .update({'sb_cardpic': null})
            .eq('MULTI_VNO', summary.multiVno);
      }
      if (!mounted) return;
      PlasmaToastManager.instance.show(context, 'Scan delinked successfully.', variant: CellBadgeVariant.success);

      // Reload details
      final updatedSummary = await _service.getBatchSummary(summary.multiVno);
      final mediaList = await MediaService().getMediaForEntity('cutting_batch', summary.multiVno.toString());

      if (mounted) {
        setState(() {
          _batchSummary = updatedSummary;
          _selectedCard = updatedSummary;
          _batchMedia = mediaList;
          });
        _loadCards();
      }
    } catch (e) {
      debugPrint('Error delinking scan: $e');
      if (mounted) {
        setState(() {});
        PlasmaToastManager.instance.show(context, 'Delinking failed: $e', variant: CellBadgeVariant.error);
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
                  color: isSelected ? colors.primary.withValues(alpha: 0.04) : null,
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

  String _truncateMillName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length > 2) {
      return '${words[0]} ${words[1]}';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return SystemAppMasterLayout(
      paneHeader: OrganPaneHeader(
        title: 'Cuttings',
        searchController: _searchController,
        onSearchChanged: (v) {
          setState(() => _currentPage = 1);
          _loadCards();
        },
        searchPlaceholder: 'Search by CC No, Mill, Fabric...',
        onAddPressed: _startAddBatch,
        addLabel: 'Add',
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

          return TissueListCard.registry(
            isSelected: isSelected,
            onTap: () => _onCardSelected(summary),
            showDivider: true,
            registryDate: summary.cutDate,
            registryTitle: summary.greyQual,
            registrySubtitle: _truncateMillName(summary.mill),
            registryBadgeText: summary.ccCode.replaceAll('CC-', ''),
            registryMetricText: '${summary.totalFreshPcs.toInt()} PCS',
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
              onPickScan: _openMediaPickerDrawer,
              onDelinkScan: _delinkSpecificSideScan,
            )
          : null,
      isDetailVisible: _selectedCard != null,
      emptyTitle: 'No Cutting Batch Selected',
      emptyMessage: 'Select a batch from the registry to view its cutting metrics and status.',
      emptyIcon: LucideIcons.scissors,
    );
  }
}
