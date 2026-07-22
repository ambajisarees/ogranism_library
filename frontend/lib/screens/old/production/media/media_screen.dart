import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:textile_erp/organism_design/index.dart';
import '../../../../models/production/model_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/production/service_media.dart';
import '../../../../services/masters/service_masters.dart';
import '../../../../services/production/service_cutting.dart';
import '../../../../services/production/service_jobwork.dart';
import '../../../../models/production/model_media_suggestion.dart';


class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final _service = MediaService();
  final _mastersService = MastersService();
  final _cuttingService = CuttingService();
  final _jobWorkService = JobWorkService();

  // Left Pane State
  String _selectedBucket = 'all';
  String? _selectedMediaType;
  bool? _isLinkedFilter;
  String _searchTerm = '';

  // Data Loading State
  List<MediaModel> _mediaList = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  String _sortBy = 'created_at_desc';

  // Selection State
  MediaModel? _selectedMedia;
  final Set<String> _selectedIds = {}; // For bulk actions
  bool _isMultiSelectMode = false;

  // Autocomplete Link State inside right pane
  String _linkEntityType = 'cutting_batch'; // 'quality', 'cutting_batch', 'stitching_dispatch', 'stitching_receive'
  List<Map<String, String>> _autocompleteResults = [];
  bool _isAutocompleteLoading = false;
  Map<String, String>? _selectedEntityResult;
  
  // Smart Linker State
  bool _isSmartLinkerActive = false;
  List<SmartLinkSuggestion> _suggestions = [];
  int _suggestionsCount = 0;

  // Progress Overlay State
  String? _progressMessage;
  double? _progressValue;
  String? _progressSubtitle;

  // Metadata edit controllers
  late TextEditingController _displayNameController;

  // Bucket Count Cache
  Map<String, int> _bucketCounts = {
    'all': 0,
    'sales': 0,
    'production': 0,
    'billing': 0,
    'general': 0,
  };

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _loadData();
    _loadBucketCounts();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadBucketCounts() async {
    try {
      final res = await _service.getMedia(limit: 5000);
      final list = res.data;
      final counts = {
        'all': list.length,
        'sales': list.where((m) => m.bucket == 'sales').length,
        'production': list.where((m) => m.bucket == 'production').length,
        'billing': list.where((m) => m.bucket == 'billing').length,
        'general': list.where((m) => m.bucket == 'general').length,
      };
      if (mounted) {
        setState(() {
          _bucketCounts = counts;
        });
      }
      await _loadSuggestionsCount();
    } catch (e) {
      debugPrint('Error loading bucket counts: $e');
    }
  }

  Future<void> _loadSuggestionsCount() async {
    try {
      final res = await _service.getSmartLinkSuggestions();
      final count = res.where((s) => s.hasMatches).length;
      if (mounted) {
        setState(() {
          _suggestionsCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error loading suggestions count: $e');
    }
  }

  Future<void> _loadSuggestions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _suggestions = [];
    });
    try {
      final res = await _service.getSmartLinkSuggestions();
      if (mounted) {
        setState(() {
          _suggestions = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    if (_isSmartLinkerActive) {
      await _loadSuggestions();
      return;
    }
    setState(() => _isLoading = true);

    try {
      final result = await _service.getMedia(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        bucket: _selectedBucket,
        mediaType: _selectedMediaType,
        isLinked: _isLinkedFilter,
        searchTerm: _searchTerm,
        sortBy: _sortBy,
      );

      if (mounted) {
        setState(() {
          _mediaList = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading media: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handle autocomplete searches based on selected entity type
  Future<void> _searchAutocomplete(String val) async {
    if (val.isEmpty) {
      setState(() {
        _autocompleteResults = [];
        _selectedEntityResult = null;
      });
      return;
    }

    setState(() => _isAutocompleteLoading = true);

    try {
      List<Map<String, String>> results = [];
      if (_linkEntityType == 'quality') {
        final res = await _mastersService.getQualities(searchTerm: val, limit: 10);
        results = res.data.map((q) => {
          'id': q.qcode,
          'label': q.name,
        }).toList();
      } else if (_linkEntityType == 'cutting_batch') {
        final res = await _cuttingService.getCuttingBatches(searchQuery: val, limit: 10);
        results = res.data.map((b) => {
          'id': b.multiVno.toString(),
          'label': 'Batch #${b.multiVno} (${b.mill} - ${b.greyQual})',
        }).toList();
      } else if (_linkEntityType == 'stitching_dispatch') {
        final res = await _jobWorkService.getJobDispatches(searchTerm: val, limit: 10);
        results = res.data.map((d) => {
          'id': d.vno.toString(),
          'label': 'Dispatch #${d.vno} (Tailor: ${d.tailorName ?? d.tailorCode})',
        }).toList();
      } else if (_linkEntityType == 'stitching_receive') {
        final res = await _jobWorkService.getJobReceives(searchTerm: val, limit: 10);
        results = res.data.map((r) => {
          'id': r.vno.toString(),
          'label': 'Receive #${r.vno} (Tailor: ${r.tailorName ?? r.tailorCode})',
        }).toList();
      }

      if (mounted) {
        setState(() {
          _autocompleteResults = results;
          _isAutocompleteLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading autocomplete results: $e');
      if (mounted) {
        setState(() {
          _autocompleteResults = [];
          _isAutocompleteLoading = false;
        });
      }
    }
  }

  // Bulk Upload Flow
  Future<void> _handleUpload(List<FilePickerResultFile> files) async {
    if (files.isEmpty) return;

    // Show Bucket Dialog before starting upload
    final uploadConfig = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _UploadConfigDialog(bucket: _selectedBucket),
    );

    if (uploadConfig == null) return; // Cancelled

    final bucket = uploadConfig['bucket']!;
    final mediaType = uploadConfig['mediaType'] == 'none' ? null : uploadConfig['mediaType'];

    final totalFiles = files.length;
    setState(() {
      _isLoading = true;
      _progressMessage = 'Preparing files...';
      _progressValue = 0.0;
      _progressSubtitle = '0 of $totalFiles · 0% completed';
    });

    int uploadCount = 0;
    for (int i = 0; i < totalFiles; i++) {
      final file = files[i];
      final currentPct = (i + 1) / totalFiles;
      setState(() {
        _progressMessage = 'Uploading ${file.name}';
        _progressValue = currentPct;
        _progressSubtitle = '${i + 1} of $totalFiles · ${(currentPct * 100).toInt()}% completed';
      });

      try {
        final Uint8List bytes = file.bytes ?? await File(file.path!).readAsBytes();
        await _service.uploadFile(
          bytes,
          file.name,
          bucket: bucket,
          mediaType: mediaType,
        );
        uploadCount++;
      } catch (e) {
        debugPrint('Upload failed for ${file.name}: $e');
        if (mounted) {
          PlasmaToastManager.instance.show(
            context,
            'Upload failed for ${file.name}: $e',
            variant: CellBadgeVariant.error,
          );
        }
      }
    }

    // Refresh UI & clear progress
    setState(() {
      _currentPage = 1;
      _progressMessage = null;
      _progressValue = null;
      _progressSubtitle = null;
    });
    await _loadData();
    await _loadBucketCounts();
    if (mounted) {
      PlasmaToastManager.instance.show(context, 'Successfully uploaded $uploadCount files.', variant: CellBadgeVariant.success);
    }
  }

  void _triggerFilePicker() async {
    try {
      // Yield thread to let current gesture arena & button hover states settle
      await Future.delayed(Duration.zero);
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files.map((f) => FilePickerResultFile(
          name: f.name,
          path: f.path,
          bytes: f.bytes,
        )).toList();
        _handleUpload(files);
      }
    } catch (e) {
      debugPrint('File picking error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(fontSize: 13);

    return DropTarget(
      onDragDone: (detail) async {
        final files = detail.files;
        if (files.isNotEmpty) {
          final mapped = files.map((f) => FilePickerResultFile(
            name: f.name,
            path: f.path,
          )).toList();
          _handleUpload(mapped);
        }
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            setState(() {
              _isMultiSelectMode = false;
              _selectedIds.clear();
              _selectedMedia = null;
            });
          },
          const SingleActivator(LogicalKeyboardKey.delete): () {
            if (_isMultiSelectMode && _selectedIds.isNotEmpty) {
              _bulkArchive();
            } else if (_selectedMedia != null) {
              _archiveSingle(_selectedMedia!.id);
            }
          }
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              SystemAppMasterLayout(
                isDetailVisible: true,
                paneHeader: OrganPaneHeader(
                  title: 'Media Explorer',
                  primaryAction: Row(
                    children: [
                      CellButton(
                        text: 'Wipe All',
                        icon: LucideIcons.trash2,
                        variant: CellButtonVariant.destructive,
                        onPressed: _wipeAllMedia,
                      ),
                      const SizedBox(width: 8),
                      CellButton(
                        icon: LucideIcons.refreshCw,
                        variant: CellButtonVariant.ghost,
                        onPressed: () async {
                          setState(() {
                            _currentPage = 1;
                          });
                          await _loadData();
                          await _loadBucketCounts();
                          if (!context.mounted) return;
                          PlasmaToastManager.instance.show(context, 'Media registry refreshed.', variant: CellBadgeVariant.success);
                        },
                      ),
                    ],
                  ),
                  onSearchChanged: (val) {
                    setState(() {
                      _searchTerm = val;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
                paneList: _buildLeftPane(colors, monoStyle),
                sectionCanvas: Row(
                  children: [
                    Expanded(
                      child: _isSmartLinkerActive
                          ? _buildSmartLinkerArea(colors, monoStyle)
                          : _buildGridArea(colors, monoStyle),
                    ),
                    if (_selectedMedia != null && !_isSmartLinkerActive)
                      _buildRightDetailPane(colors, monoStyle),
                  ],
                ),
              ),
              if (_progressMessage != null)
                _buildProgressOverlay(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverlay(OrganismColors colors) {
    final pct = _progressValue ?? 0.0;
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: OrganismTheme.shadowLg,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _progressMessage ?? 'Processing...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  minHeight: 6,
                ),
              ),
              if (_progressSubtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  _progressSubtitle!,
                  style: TextStyle(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.right,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // left Sidebar Pane: Buckets and Filter inputs
  Widget _buildLeftPane(OrganismColors colors, TextStyle monoStyle) {
    return Material(
      color: colors.surfaceSubtle,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(OrganismTheme.spacingMd),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            CellButton(
              text: 'Bulk Upload Files',
              icon: LucideIcons.upload,
              variant: CellButtonVariant.primary,
              onPressed: _triggerFilePicker,
            ),
            const SizedBox(height: 16),
            Text('BUCKETS', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
            const SizedBox(height: 8),
            _buildBucketItem('all', LucideIcons.folderClosed, 'All Files', colors, monoStyle),
            _buildBucketItem('sales', LucideIcons.handshake, 'Sales Assets', colors, monoStyle),
            _buildBucketItem('production', LucideIcons.factory, 'Production Scans', colors, monoStyle),
            _buildBucketItem('billing', LucideIcons.receipt, 'Bill Invoices', colors, monoStyle),
            _buildBucketItem('general', LucideIcons.folderHeart, 'General / Unsorted', colors, monoStyle),
            const SizedBox(height: 12),
            _buildSmartLinkerSidebarItem(colors, monoStyle),
            const SizedBox(height: 24),
            Text('LINKAGE FILTER', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _isLinkedFilter == null,
                    onSelected: (val) {
                      setState(() {
                        _isLinkedFilter = null;
                        _currentPage = 1;
                      });
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Linked'),
                    selected: _isLinkedFilter == true,
                    onSelected: (val) {
                      setState(() {
                        _isLinkedFilter = true;
                        _currentPage = 1;
                      });
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Unsorted'),
                    selected: _isLinkedFilter == false,
                    onSelected: (val) {
                      setState(() {
                        _isLinkedFilter = false;
                        _currentPage = 1;
                      });
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('SORT ORDER', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _sortBy,
              items: const [
                DropdownMenuItem(value: 'created_at_desc', child: Text('Upload Date (Newest)')),
                DropdownMenuItem(value: 'file_name_asc', child: Text('Name (A-Z)')),
                DropdownMenuItem(value: 'file_size_desc', child: Text('Size (Largest)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _sortBy = val;
                    _currentPage = 1;
                  });
                  _loadData();
                }
              },
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBucketItem(String key, IconData icon, String title, OrganismColors colors, TextStyle monoStyle) {
    final isSelected = _selectedBucket == key;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
      leading: Icon(icon, size: 16, color: isSelected ? colors.primary : colors.textSecondary),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? colors.primary : colors.textPrimary,
      )),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${_bucketCounts[key] ?? 0}',
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? colors.background : colors.textSecondary,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _selectedBucket = key;
          _currentPage = 1;
          _selectedMedia = null;
          _isSmartLinkerActive = false;
        });
        _loadData();
      },
    );
  }

  // Middle Content Area: Responsive Grid of files
  Widget _buildGridArea(OrganismColors colors, TextStyle monoStyle) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mediaList.isEmpty) {
      return Center(
        child: TissueEmptyState(
          title: 'No media assets found',
          message: 'Drag & Drop image files here or select "Bulk Upload Files" to begin cataloging.',
          icon: LucideIcons.image,
        ),
      );
    }

    final totalPages = (_totalCount / _limit).ceil().clamp(1, 999);

    return Column(
      children: [
        if (_isMultiSelectMode)
          _buildBulkActionBar(colors),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: _mediaList.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final media = _mediaList[index];
                final isSelected = _selectedMedia?.id == media.id;
                final isChecked = _selectedIds.contains(media.id);

                return InkWell(
                  onTap: () {
                    if (_isMultiSelectMode) {
                      setState(() {
                        if (isChecked) {
                          _selectedIds.remove(media.id);
                        } else {
                          _selectedIds.add(media.id);
                        }
                      });
                    } else {
                      setState(() {
                        _selectedMedia = media;
                        _displayNameController.text = media.displayName ?? media.fileName;
                        _autocompleteResults = [];
                        _selectedEntityResult = null;
                      });
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _isMultiSelectMode = true;
                      _selectedIds.add(media.id);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary.withValues(alpha: 0.05) : colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : (isChecked ? colors.success : colors.border),
                        width: isSelected || isChecked ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                color: colors.surfaceSubtle,
                                child: Image.network(
                                  media.thumbPath != null && media.thumbPath!.isNotEmpty
                                      ? _service.getPublicUrl(media.thumbPath!)
                                      : _service.getPublicUrl(media.filePath, width: 200, height: 200),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    LucideIcons.fileImage,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    media.displayName ?? media.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: OrganismTheme.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      CellBadge(
                                        text: media.isLinked ? 'LINKED' : 'UNSORTED',
                                        variant: media.isLinked ? CellBadgeVariant.success : CellBadgeVariant.warning,
                                      ),
                                      const Spacer(),
                                      Text(
                                        media.fileSizeFormatted,
                                        style: monoStyle.copyWith(fontSize: 10, color: colors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Hover/Select Checkbox
                        if (_isMultiSelectMode)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(media.id);
                                  } else {
                                    _selectedIds.remove(media.id);
                                  }
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        TissuePagination(
          currentPage: _currentPage,
          totalPages: totalPages,
          totalCount: _totalCount,
          limit: _limit,
          onPageChanged: (p) {
            setState(() => _currentPage = p);
            _loadData();
          },
        ),
      ],
    );
  }

  Widget _buildBulkActionBar(OrganismColors colors) {
    return Container(
      color: colors.success.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(LucideIcons.checkSquare, size: 16, color: colors.success),
          const SizedBox(width: 8),
          Text(
            '${_selectedIds.length} files selected',
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.success),
          ),
          const Spacer(),
          CellButton(
            text: 'Bulk Link',
            icon: LucideIcons.link,
            variant: CellButtonVariant.primary,
            onPressed: _showBulkLinkDialog,
          ),
          const SizedBox(width: 8),
          CellButton(
            text: 'Bulk Archive',
            icon: LucideIcons.trash2,
            variant: CellButtonVariant.destructive,
            onPressed: _bulkArchive,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () {
              setState(() {
                _isMultiSelectMode = false;
                _selectedIds.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  // Right Details Panel: Metadata + Linking
  Widget _buildRightDetailPane(OrganismColors colors, TextStyle monoStyle) {
    final media = _selectedMedia!;
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(left: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Close button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('File Properties', style: OrganismTheme.titleMedium(context)),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 16),
                  onPressed: () => setState(() => _selectedMedia = null),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full image preview
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      _service.getPublicUrl(media.filePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.fileImage, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display Name editable form
                  TissueFormField(
                    label: 'Display Name',
                    inputCell: CellInput(
                      controller: _displayNameController,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CellButton(
                    text: 'Rename File',
                    icon: LucideIcons.save,
                    variant: CellButtonVariant.secondary,
                    onPressed: () async {
                      try {
                        await _service.updateTags(media.id, media.tags);
                        await _service.moveToBucket(media.id, media.bucket, media.mediaType);
                        // Trigger simple metadata update
                        await Supabase.instance.client
                            .schema('IMMBE2627')
                            .from('sb_media')
                            .update({'display_name': _displayNameController.text})
                            .eq('id', media.id);
                        _loadData();
                        if (mounted) {
                          PlasmaToastManager.instance.show(context, 'Successfully renamed.', variant: CellBadgeVariant.success);
                        }
                      } catch (e) {
                        debugPrint('Rename failed: $e');
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Metadata Cards
                  _buildMetadataInfo('Storage Path', media.filePath, colors),
                  _buildMetadataInfo('File Size', media.fileSizeFormatted, colors),
                  _buildMetadataInfo('Bucket Category', media.bucketLabel, colors),
                  if (media.mediaType != null)
                    _buildMetadataInfo('Media Type', media.mediaType!, colors),
                  _buildMetadataInfo('Uploader', media.uploaderName ?? 'System', colors),
                  _buildMetadataInfo('Uploaded At', media.createdAt.toIso8601String().split('T')[0], colors),
                  const SizedBox(height: 24),

                  // Entity Linking Section
                  Text('ENTITY ASSOCIATION', style: OrganismTheme.labelMedium(context).copyWith(color: colors.textMuted)),
                  const SizedBox(height: 8),
                  if (media.isLinked) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.1),
                        border: Border.all(color: colors.success.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Linked to: ${media.entityType}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(media.entityLabel ?? media.entityId ?? '', style: TextStyle(color: colors.success, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          CellButton(
                            text: 'Unlink Asset',
                            icon: LucideIcons.link2Off,
                            variant: CellButtonVariant.ghost,
                            onPressed: () async {
                              await _service.linkToEntity(media.id, '', '', '');
                              _loadData();
                              setState(() {
                                _selectedMedia = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Selection autocomplete form
                    DropdownButtonFormField<String>(
                      initialValue: _linkEntityType,
                      items: const [
                        DropdownMenuItem(value: 'cutting_batch', child: Text('Cutting Batch')),
                        DropdownMenuItem(value: 'stitching_dispatch', child: Text('Stitching Dispatch (O5)')),
                        DropdownMenuItem(value: 'stitching_receive', child: Text('Stitching Receive (O6)')),
                        DropdownMenuItem(value: 'quality', child: Text('Quality QCode')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _linkEntityType = val;
                            _autocompleteResults = [];
                            _selectedEntityResult = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Entity...',
                        prefixIcon: Icon(LucideIcons.search, size: 14),
                      ),
                      onChanged: (val) {
                        _searchAutocomplete(val);
                      },
                    ),
                    if (_isAutocompleteLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    if (_autocompleteResults.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Material(
                          color: colors.surface,
                          elevation: 0,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 120),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _autocompleteResults.length,
                              itemBuilder: (context, idx) {
                                final res = _autocompleteResults[idx];
                                return ListTile(
                                  dense: true,
                                  title: Text(res['label']!),
                                  onTap: () {
                                    setState(() {
                                      _selectedEntityResult = res;
                                      _autocompleteResults = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    if (_selectedEntityResult != null) ...[
                      const SizedBox(height: 8),
                      Text('Selected: ${_selectedEntityResult!['label']}', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      CellButton(
                        text: 'Establish Link',
                        icon: LucideIcons.link,
                        variant: CellButtonVariant.primary,
                        onPressed: () async {
                          await _service.linkToEntity(
                            media.id,
                            _linkEntityType,
                            _selectedEntityResult!['id']!,
                            _selectedEntityResult!['label']!,
                          );
                          _loadData();
                          setState(() {
                            _selectedMedia = null;
                          });
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),

                  // Soft Delete
                  CellButton(
                    text: 'Archive Asset',
                    icon: LucideIcons.trash,
                    variant: CellButtonVariant.destructive,
                    onPressed: () => _archiveSingle(media.id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataInfo(String label, String value, OrganismColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: OrganismTheme.labelMedium(context).copyWith(fontSize: 10, color: colors.textMuted)),
          Text(value, style: OrganismTheme.bodySmall(context).copyWith(color: colors.textPrimary)),
        ],
      ),
    );
  }

  // Operations
  Future<void> _archiveSingle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive File'),
        content: const Text('Are you sure you want to soft-delete/archive this media asset?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Archive')),
        ],
      ),
    );

    if (confirm == true) {
      await _service.archiveMedia(id);
      setState(() {
        _selectedMedia = null;
      });
      _loadData();
      _loadBucketCounts();
    }
  }

  Future<void> _wipeAllMedia() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wipe All Media'),
        content: const Text('Are you sure you want to permanently delete all 495+ files from Supabase Storage and clear all database records? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('WIPE ALL'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final response = await _service.getMedia(limit: 5000);
        final list = response.data;
        
        final List<String> pathsToDelete = [];
        for (final m in list) {
          pathsToDelete.add(m.filePath);
          if (m.thumbPath != null && m.thumbPath!.isNotEmpty) {
            pathsToDelete.add(m.thumbPath!);
          }
        }

        if (pathsToDelete.isNotEmpty) {
          await Supabase.instance.client.storage.from('ambaji-media').remove(pathsToDelete);
        }

        await Supabase.instance.client
            .schema('IMMBE2627')
            .rpc('wipe_all_media');

        if (mounted) {
          PlasmaToastManager.instance.show(
            context,
            'Successfully wiped all media assets.',
            variant: CellBadgeVariant.success,
          );
        }
        
        setState(() {
          _isSmartLinkerActive = false;
        });
        await _loadData();
        await _loadBucketCounts();
      } catch (e) {
        if (mounted) {
          PlasmaToastManager.instance.show(
            context,
            'Wipe failed: $e',
            variant: CellBadgeVariant.error,
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _bulkArchive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Multiple Files'),
        content: Text('Are you sure you want to archive these ${_selectedIds.length} files?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Archive All')),
        ],
      ),
    );

    if (confirm == true) {
      await _service.bulkArchive(_selectedIds.toList());
      setState(() {
        _selectedIds.clear();
        _isMultiSelectMode = false;
      });
      _loadData();
      _loadBucketCounts();
    }
  }

  Future<void> _showBulkLinkDialog() async {
    final confirm = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _BulkLinkDialog(
        mastersService: _mastersService,
        cuttingService: _cuttingService,
        jobWorkService: _jobWorkService,
      ),
    );

    if (confirm != null) {
      final type = confirm['type']!;
      final id = confirm['id']!;
      final label = confirm['label']!;

      await _service.bulkLinkToEntity(_selectedIds.toList(), type, id, label);
      setState(() {
        _selectedIds.clear();
        _isMultiSelectMode = false;
      });
      _loadData();
      if (mounted) {
        PlasmaToastManager.instance.show(context, 'Bulk linkage established.', variant: CellBadgeVariant.success);
      }
    }
  }

  // --- SMART LINKER WIDGETS AND MUTATIONS ---

  Widget _buildSmartLinkerSidebarItem(OrganismColors colors, TextStyle monoStyle) {
    final isSelected = _isSmartLinkerActive;
    return Material(
      color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Icon(
            LucideIcons.sparkles,
            size: 16,
            color: isSelected ? colors.primary : colors.textSecondary,
          ),
          title: Text(
            'Smart Linker',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colors.primary : colors.textPrimary,
            ),
          ),
          trailing: _suggestionsCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _suggestionsCount.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () {
            setState(() {
              _isSmartLinkerActive = true;
              _selectedBucket = 'all';
              _selectedMedia = null;
            });
            _loadData();
          },
        ),
      ),
    );
  }


  Widget _buildSmartLinkerArea(OrganismColors colors, TextStyle monoStyle) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions.isEmpty) {
      return const Center(
        child: TissueEmptyState(
          title: 'All caught up!',
          message: 'No unlinked files with match suggestions were found.',
          icon: LucideIcons.checkCheck,
        ),
      );
    }

    final matched = _suggestions.where((s) => s.hasMatches).toList();
    final unmatched = _suggestions.where((s) => !s.hasMatches).toList();

    return Column(
      children: [
        _buildSmartLinkerHeader(colors, matched.length),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (matched.isNotEmpty) ...[
                  Text(
                    'AUTO-MATCHED SUGGESTIONS (${matched.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: matched.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (c, i) => _buildSuggestionRow(colors, monoStyle, matched[i]),
                  ),
                  const SizedBox(height: 24),
                ],
                if (unmatched.isNotEmpty) ...[
                  Text(
                    'UNMATCHED UPLOADS (${unmatched.length}) — Manually Link or Skip',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: unmatched.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (c, i) => _buildSuggestionRow(colors, monoStyle, unmatched[i]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartLinkerHeader(OrganismColors colors, int matchedCount) {
    final checkedSuggestions = _suggestions.where((s) => s.isChecked && s.selectedOption != null).toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(LucideIcons.sparkles, color: colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Smart Linker Suggestions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
          ),
          const Spacer(),
          CellButton(
            text: 'Link Selected (${checkedSuggestions.length})',
            icon: LucideIcons.link2,
            variant: CellButtonVariant.primary,
            onPressed: checkedSuggestions.isEmpty ? null : _bulkLinkCheckedSuggestions,
          ),
          const SizedBox(width: 8),
          CellButton(
            text: 'Refresh',
            icon: LucideIcons.refreshCw,
            variant: CellButtonVariant.outline,
            onPressed: _loadSuggestions,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionRow(OrganismColors colors, TextStyle monoStyle, SmartLinkSuggestion suggestion) {
    final media = suggestion.media;
    final contextLabel = suggestion.folderContext.toUpperCase().replaceAll('_', ' ');

    return CellBox(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: colors.surface,
      borderRadius: OrganismTheme.borderSm,
      border: Border.all(
        color: suggestion.isChecked ? colors.primary.withValues(alpha: 0.3) : colors.border,
      ),
      child: Row(
        children: [
          Checkbox(
            value: suggestion.isChecked,
            activeColor: colors.primary,
            onChanged: (val) {
              setState(() {
                suggestion.isChecked = val ?? false;
              });
            },
          ),
          const SizedBox(width: 8),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              media.thumbPath != null && media.thumbPath!.isNotEmpty
                  ? _service.getPublicUrl(media.thumbPath!)
                  : _service.getPublicUrl(media.filePath, width: 100, height: 100),
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(LucideIcons.fileImage, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CellBadge(
                      text: contextLabel,
                      variant: suggestion.folderContext == 'general'
                          ? CellBadgeVariant.secondary
                          : CellBadgeVariant.outline,
                    ),
                    if (suggestion.side != null) ...[
                      const SizedBox(width: 6),
                      CellBadge(
                        text: suggestion.side == 'F' ? '▲ FRONT' : '▼ BACK',
                        variant: suggestion.side == 'F'
                            ? CellBadgeVariant.primary
                            : CellBadgeVariant.warning,
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      media.fileSizeFormatted,
                      style: TextStyle(color: colors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Builder(
              builder: (context) {
                // If there's a selected option and it's a cutting card, compute the proposed target filename
                String? proposedRename;
                if (suggestion.selectedOption?.entityType == 'cutting_batch' && suggestion.side != null) {
                  final entityId = suggestion.selectedOption!.entityId;
                  final multiVno = int.tryParse(entityId) ?? 0;
                  final ccCode = 'CC-${multiVno.toString().padLeft(4, '0')}';
                  final ext = media.fileName.contains('.') ? media.fileName.split('.').last.toLowerCase() : 'jpg';
                  proposedRename = '$ccCode-${suggestion.side}.$ext';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    suggestion.hasMatches
                        ? (suggestion.matchOptions.length == 1
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.successSubtle,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.checkCircle2, color: colors.success, size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        suggestion.matchOptions.first.entityLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: colors.success, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(LucideIcons.alertTriangle, color: colors.warning, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: TissueDropdown<MatchedEntityOption>(
                                      items: suggestion.matchOptions,
                                      value: suggestion.selectedOption,
                                      onChanged: (val) {
                                        setState(() {
                                          suggestion.selectedOption = val;
                                        });
                                      },
                                      itemLabelBuilder: (opt) => opt.entityLabel,
                                    ),
                                  ),
                                ],
                              ))
                        : _buildManualLinkerCell(colors, suggestion),
                    if (proposedRename != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Text(
                          '➔ Rename to: $proposedRename',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
            ),
          ),
          const SizedBox(width: 16),
          CellButton(
            text: 'Link',
            icon: LucideIcons.link,
            variant: CellButtonVariant.outline,
            onPressed: suggestion.selectedOption == null
                ? null
                : () => _linkSingleSuggestion(suggestion),
          ),
          const SizedBox(width: 4),
          CellButton(
            text: 'Skip',
            icon: LucideIcons.x,
            variant: CellButtonVariant.ghost,
            onPressed: () => _archiveSingle(media.id),
          ),
        ],
      ),
    );
  }

  Widget _buildManualLinkerCell(OrganismColors colors, SmartLinkSuggestion suggestion) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'No auto-matches. Select target manually.',
            style: TextStyle(color: colors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(width: 8),
        CellButton(
          text: 'Select Target',
          icon: LucideIcons.search,
          variant: CellButtonVariant.ghost,
          onPressed: () => _showManualLinkPopover(suggestion),
        ),
      ],
    );
  }

  Future<void> _showManualLinkPopover(SmartLinkSuggestion suggestion) async {
    String selectedType = 'cutting_batch';
    Map<String, String>? entityResult;
    List<Map<String, String>> localResults = [];
    bool isSearching = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manual Link Selection'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioGroup<String>(
                      groupValue: selectedType,
                      onChanged: (v) => setDialogState(() => selectedType = v!),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: 'cutting_batch',
                              ),
                              const Text('Cutting'),
                              Radio<String>(
                                value: 'stitching_dispatch',
                              ),
                              const Text('Dispatch O5'),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'stitching_receive',
                              ),
                              const Text('Receive O6'),
                              Radio<String>(
                                value: 'bill',
                              ),
                              const Text('Bill Invoice'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TissueFormField(
                      label: 'Search Voucher/Serial Number',
                      inputCell: CellInput(
                        placeholder: 'Enter serial number...',
                        onChanged: (val) async {
                          if (val.isEmpty) {
                            setDialogState(() {
                              localResults = [];
                              entityResult = null;
                            });
                            return;
                          }
                          setDialogState(() => isSearching = true);
                          List<Map<String, String>> results = [];
                          try {
                            if (selectedType == 'cutting_batch') {
                              final res = await _cuttingService.getCuttingBatches(searchQuery: val, limit: 10);
                              results = res.data.map((b) => {
                                'id': b.multiVno.toString(),
                                'label': 'Batch #${b.multiVno} (${b.mill})',
                              }).toList();
                            } else if (selectedType == 'stitching_dispatch') {
                              final res = await _jobWorkService.getJobDispatches(searchTerm: val, limit: 10);
                              results = res.data.map((d) => {
                                'id': d.vno.toString(),
                                'label': 'Dispatch #${d.vno} (Challan:${d.challanNo ?? "N/A"}, Tailor:${d.tailorCode})',
                              }).toList();
                            } else if (selectedType == 'stitching_receive') {
                              final res = await _jobWorkService.getJobReceives(searchTerm: val, limit: 10);
                              results = res.data.map((r) => {
                                'id': r.vno.toString(),
                                'label': 'Receive #${r.vno} (Challan:${r.challanNo ?? "N/A"}, Tailor:${r.tailorCode})',
                              }).toList();
                            } else if (selectedType == 'bill') {
                              final res = await _mastersService.getParties(searchTerm: val, limit: 10, offset: 0);
                              results = res.data.map((p) => {
                                'id': p.code,
                                'label': '${p.name} (${p.city})',
                              }).toList();
                            }
                          } catch (e) {
                            debugPrint('Manual search error: $e');
                          }
                          setDialogState(() {
                            localResults = results;
                            isSearching = false;
                          });
                        },
                      ),
                    ),
                    if (isSearching)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    if (!isSearching && localResults.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            height: 150,
                            child: ListView.builder(
                              itemCount: localResults.length,
                              itemBuilder: (c, idx) {
                                final r = localResults[idx];
                                final isSel = entityResult?['id'] == r['id'];
                                return ListTile(
                                  dense: true,
                                  tileColor: isSel ? Theme.of(c).colorScheme.primaryContainer.withValues(alpha: 0.15) : null,
                                  title: Text(r['label']!),
                                  trailing: isSel ? const Icon(Icons.check, size: 14) : null,
                                  onTap: () {
                                    setDialogState(() {
                                      entityResult = r;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: entityResult == null
                      ? null
                      : () {
                          setState(() {
                            suggestion.selectedOption = MatchedEntityOption(
                              entityType: selectedType,
                              entityId: entityResult!['id']!,
                              entityLabel: entityResult!['label']!,
                            );
                            suggestion.isChecked = true;
                          });
                          Navigator.pop(context);
                        },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _bulkLinkCheckedSuggestions() async {
    final checked = _suggestions.where((s) => s.isChecked && s.selectedOption != null).toList();
    if (checked.isEmpty) return;

    final total = checked.length;
    setState(() {
      _isLoading = true;
      _progressMessage = 'Preparing linkages...';
      _progressValue = 0.0;
      _progressSubtitle = '0 of $total · 0% completed';
    });

    try {
      await _service.bulkLinkSuggestions(
        checked,
        onProgress: (current, totalVal, status) {
          setState(() {
            _progressMessage = status;
            _progressValue = current / totalVal;
            _progressSubtitle = '$current of $totalVal · ${(current / totalVal * 100).toInt()}% completed';
          });
        },
      );

      if (!mounted) return;
      PlasmaToastManager.instance.show(
        context,
        'Successfully linked ${checked.length} files.',
        variant: CellBadgeVariant.success,
      );
      setState(() {
        _isSmartLinkerActive = false;
        _progressMessage = null;
        _progressValue = null;
        _progressSubtitle = null;
      });
      await _loadData();
      await _loadBucketCounts();
    } catch (e) {
      if (!mounted) return;
      PlasmaToastManager.instance.show(
        context,
        'Failed to link suggestions: $e',
        variant: CellBadgeVariant.error,
      );
      setState(() {
        _isLoading = false;
        _progressMessage = null;
        _progressValue = null;
        _progressSubtitle = null;
      });
    }
  }

  Future<void> _linkSingleSuggestion(SmartLinkSuggestion suggestion) async {
    if (suggestion.selectedOption == null) return;
    setState(() {
      _isLoading = true;
      _progressMessage = 'Linking ${suggestion.media.fileName}';
      _progressValue = 0.5;
      _progressSubtitle = '1 of 1 · 50% completed';
    });
    try {
      await _service.bulkLinkSuggestions(
        [suggestion],
        onProgress: (current, totalVal, status) {
          setState(() {
            _progressMessage = status;
            _progressValue = current / totalVal;
            _progressSubtitle = '$current of $totalVal · ${(current / totalVal * 100).toInt()}% completed';
          });
        },
      );
      if (!mounted) return;
      PlasmaToastManager.instance.show(
        context,
        'Successfully linked ${suggestion.media.fileName}.',
        variant: CellBadgeVariant.success,
      );
      setState(() {
        _suggestions.remove(suggestion);
        _isLoading = false;
        _progressMessage = null;
        _progressValue = null;
        _progressSubtitle = null;
      });
      await _loadBucketCounts();
    } catch (e) {
      if (!mounted) return;
      PlasmaToastManager.instance.show(
        context,
        'Failed to link media: $e',
        variant: CellBadgeVariant.error,
      );
      setState(() {
        _isLoading = false;
        _progressMessage = null;
        _progressValue = null;
        _progressSubtitle = null;
      });
    }
  }

  }

// Bulk Link Modal helper
class _BulkLinkDialog extends StatefulWidget {
  final MastersService mastersService;
  final CuttingService cuttingService;
  final JobWorkService jobWorkService;

  const _BulkLinkDialog({
    required this.mastersService,
    required this.cuttingService,
    required this.jobWorkService,
  });

  @override
  State<_BulkLinkDialog> createState() => _BulkLinkDialogState();
}

class _BulkLinkDialogState extends State<_BulkLinkDialog> {
  String _type = 'cutting_batch';
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  Map<String, String>? _selected;

  Future<void> _runSearch(String val) async {
    if (val.isEmpty) {
      setState(() {
        _results = [];
        _selected = null;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      List<Map<String, String>> res = [];
      if (_type == 'quality') {
        final r = await widget.mastersService.getQualities(searchTerm: val, limit: 10);
        res = r.data.map((q) => {'id': q.qcode, 'label': q.name}).toList();
      } else if (_type == 'cutting_batch') {
        final r = await widget.cuttingService.getCuttingBatches(searchQuery: val, limit: 10);
        res = r.data.map((b) => {'id': b.multiVno.toString(), 'label': 'Batch #${b.multiVno} (${b.mill})'}).toList();
      } else if (_type == 'stitching_dispatch') {
        final r = await widget.jobWorkService.getJobDispatches(searchTerm: val, limit: 10);
        res = r.data.map((d) => {'id': d.vno.toString(), 'label': 'Dispatch #${d.vno} (Tailor: ${d.tailorName ?? d.tailorCode})'}).toList();
      }
      if (mounted) {
        setState(() {
          _results = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Link Association'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: const [
              DropdownMenuItem(value: 'cutting_batch', child: Text('Cutting Batch')),
              DropdownMenuItem(value: 'stitching_dispatch', child: Text('Stitching Dispatch (O5)')),
              DropdownMenuItem(value: 'quality', child: Text('Quality QCode')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _type = val;
                  _results = [];
                  _selected = null;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(labelText: 'Search Entity...'),
            onChanged: (val) {
              _runSearch(val);
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_results.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final r = _results[i];
                      return ListTile(
                        dense: true,
                        title: Text(r['label']!),
                        onTap: () => setState(() {
                          _selected = r;
                          _results = [];
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (_selected != null) ...[
            const SizedBox(height: 8),
            Text('Selected: ${_selected!['label']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ]
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, {'type': _type, 'id': _selected!['id']!, 'label': _selected!['label']!}),
          child: const Text('Link Assets'),
        ),
      ],
    );
  }
}

// Upload Config Dialog Modal
class _UploadConfigDialog extends StatefulWidget {
  final String bucket;
  const _UploadConfigDialog({required this.bucket});

  @override
  State<_UploadConfigDialog> createState() => _UploadConfigDialogState();
}

class _UploadConfigDialogState extends State<_UploadConfigDialog> {
  late String _bucket;
  String _mediaType = 'none';

  @override
  void initState() {
    super.initState();
    _bucket = widget.bucket == 'all' ? 'general' : widget.bucket;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Assets Configuration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _bucket,
            decoration: const InputDecoration(labelText: 'Category Bucket'),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('General / Unsorted')),
              DropdownMenuItem(value: 'production', child: Text('Production Media')),
              DropdownMenuItem(value: 'billing', child: Text('Billing / Invoices')),
              DropdownMenuItem(value: 'sales', child: Text('Sales Assets')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _bucket = val;
                  _mediaType = 'none';
                });
              }
            },
          ),
          const SizedBox(height: 16),
          if (_bucket == 'production') ...[
            DropdownButtonFormField<String>(
              initialValue: _mediaType,
              decoration: const InputDecoration(labelText: 'Classification Type'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Unclassified (default)')),
                DropdownMenuItem(value: 'cutting_card', child: Text('Cutting Card')),
                DropdownMenuItem(value: 'job_card', child: Text('Job Card')),
                DropdownMenuItem(value: 'job_saree', child: Text('Job Saree')),
                DropdownMenuItem(value: 'job_inward', child: Text('Job Inward')),
              ],
              onChanged: (val) => setState(() => _mediaType = val!),
            ),
          ] else if (_bucket == 'billing') ...[
            DropdownButtonFormField<String>(
              initialValue: _mediaType,
              decoration: const InputDecoration(labelText: 'Classification Type'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Unclassified (default)')),
                DropdownMenuItem(value: 'bill_scan', child: Text('Bill Invoice Scan')),
                DropdownMenuItem(value: 'challan_scan', child: Text('Challan Scan')),
              ],
              onChanged: (val) => setState(() => _mediaType = val!),
            ),
          ] else if (_bucket == 'sales') ...[
            DropdownButtonFormField<String>(
              initialValue: _mediaType,
              decoration: const InputDecoration(labelText: 'Classification Type'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Unclassified (default)')),
                DropdownMenuItem(value: 'set_pic', child: Text('Set Picture')),
                DropdownMenuItem(value: 'poster_pic', child: Text('WhatsApp Poster')),
              ],
              onChanged: (val) => setState(() => _mediaType = val!),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, {'bucket': _bucket, 'mediaType': _mediaType}),
          child: const Text('Start Upload'),
        ),
      ],
    );
  }
}

// Custom file picking wrapper representation
class FilePickerResultFile {
  final String name;
  final String? path;
  final Uint8List? bytes;

  FilePickerResultFile({
    required this.name,
    this.path,
    this.bytes,
  });
}
