import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../../organism_design/index.dart';
import '../../../models/production/model_design.dart';
import '../../../services/production/service_designs.dart';

class DesignsScreen extends StatefulWidget {
  const DesignsScreen({super.key});

  @override
  State<DesignsScreen> createState() => _DesignsScreenState();
}

class _DesignsScreenState extends State<DesignsScreen> {
  final _service = DesignsService();

  List<DesignModel> _designs = [];
  DesignModel? _selectedDesign;
  Map<String, int> _kpis = {
    'in_production': 0,
    'at_mill': 0,
    'in_stock': 0,
    'archived': 0,
    'shop_stock': 0,
    'job_stock': 0,
  };

  List<String> _qualitiesList = [];

  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 24; // smaller grid count per page
  bool _isLoading = false;

  String _searchTerm = '';
  String? _filterQuality;
  String? _filterStatus;
  bool? _filterMaster;

  @override
  void initState() {
    super.initState();
    _loadQualities();
    _loadKPIs();
    _loadData();
  }

  Future<void> _loadQualities() async {
    final quals = await _service.getUniqueItemQCodes();
    if (mounted) {
      setState(() {
        _qualitiesList = quals;
      });
    }
  }

  Future<void> _loadKPIs() async {
    final stats = await _service.getDesignsKPIs();
    if (mounted) {
      setState(() {
        _kpis = stats;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final result = await _service.getDesigns(
      offset: (_currentPage - 1) * _limit,
      limit: _limit,
      searchTerm: _searchTerm,
      filterQuality: _filterQuality,
      filterStatus: _filterStatus,
      filterMaster: _filterMaster,
    );

    if (mounted) {
      setState(() {
        _designs = result.data;
        _totalCount = result.totalCount;
        if (_designs.isNotEmpty && _selectedDesign == null) {
          _selectedDesign = _designs.first;
        }
        _isLoading = false;
      });
    }
  }

  /// Trigger attachment upload for Set Pic, Set Poster, or PDF Catalog.
  Future<void> _uploadFile(DesignModel design, String bucketName, String columnName) async {
    try {
      final result = await FilePicker.pickFiles(
        type: columnName == 'catalog_pdf_path' ? FileType.custom : FileType.image,
        allowedExtensions: columnName == 'catalog_pdf_path' ? ['pdf'] : null,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading attachment...'), duration: Duration(seconds: 2)),
      );

      final path = await _service.uploadDesignFile(
        designId: design.id,
        designNo: design.designNo,
        bucketName: bucketName,
        columnName: columnName,
        fileName: file.name,
        bytes: bytes,
      );

      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
        // Reload detail and kpis
        await _loadKPIs();
        await _loadData();
        if (mounted) {
          setState(() {
            _selectedDesign = _designs.firstWhere((d) => d.id == design.id, orElse: () => design);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed.')),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
  }

  /// Edit Stock Counts Dialog
  void _showEditStockDialog(DesignModel design, String fieldName, String fieldLabel, int currentValue) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) {
        final colors = OrganismTheme.colorsOf(context);
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Adjust $fieldLabel', style: TextStyle(color: colors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Modify stock count for ${design.designNo}', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'New Count',
                  labelStyle: TextStyle(color: colors.textSecondary),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.warning)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final newValue = int.tryParse(controller.text) ?? currentValue;
                Navigator.pop(context);

                final success = await _service.updateDesign(design.id, {fieldName: newValue});
                if (success) {
                  await _loadKPIs();
                  await _loadData();
                  if (mounted) {
                    setState(() {
                      _selectedDesign = _designs.firstWhere((d) => d.id == design.id, orElse: () => design);
                    });
                  }
                }
              },
              child: Text('Save', style: TextStyle(color: colors.warning)),
            ),
          ],
        );
      },
    );
  }

  /// Create Design Dialog
  void _showCreateDesignDialog() {
    String? selectedQual = _qualitiesList.isNotEmpty ? _qualitiesList.first : null;
    String status = 'in_production';
    bool isMaster = false;
    final balanceController = TextEditingController(text: '0');
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final colors = OrganismTheme.colorsOf(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: colors.surface,
              title: Text('New Catalog SKU Design', style: TextStyle(color: colors.textPrimary)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select item quality and options. Index codes are auto-calculated on submission.',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Quality Selector dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedQual,
                      dropdownColor: colors.surface,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Base Quality Fabric',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                      ),
                      items: _qualitiesList.map((q) {
                        return DropdownMenuItem<String>(
                          value: q,
                          child: Text(q),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => selectedQual = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      dropdownColor: colors.surface,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Initial Status',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'in_production', child: Text('In Production')),
                        DropdownMenuItem(value: 'at_mill', child: Text('At Mill')),
                        DropdownMenuItem(value: 'in_stock', child: Text('In Stock')),
                        DropdownMenuItem(value: 'archived', child: Text('Archived')),
                      ],
                      onChanged: (val) {
                        setModalState(() => status = val ?? 'in_production');
                      },
                    ),
                    const SizedBox(height: 12),

                    // Master flag switch
                    Row(
                      children: [
                        Text('Is Master order holder?', style: TextStyle(color: colors.textPrimary)),
                        const Spacer(),
                        Switch(
                          value: isMaster,
                          activeThumbColor: colors.warning,
                          onChanged: (val) {
                            setModalState(() => isMaster = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Opening balance field
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Opening Balance (Pcs)',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Remarks field
                    TextField(
                      controller: remarksController,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedQual == null) return;
                    final opBal = int.tryParse(balanceController.text) ?? 0;
                    Navigator.pop(context);

                    final newDesign = await _service.createDesign(
                      itemQCode: selectedQual!,
                      status: status,
                      isMaster: isMaster,
                      openingBalance: opBal,
                      remarks: remarksController.text,
                    );

                    if (newDesign != null) {
                      await _loadKPIs();
                      await _loadData();
                      if (mounted) {
                        setState(() {
                          _selectedDesign = newDesign;
                        });
                      }
                    }
                  },
                  child: Text('Add Design', style: TextStyle(color: colors.warning)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      color: colors.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Designs Catalog',
                    style: OrganismTheme.displayLarge(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Product design SKU catalog and photoshoot media files linked to sales and tailors.',
                    style: OrganismTheme.bodyMedium(context),
                  ),
                ],
              ),
              const Spacer(),
              CellButton(
                text: 'Refresh',
                icon: LucideIcons.refreshCw,
                variant: CellButtonVariant.outline,
                onPressed: () {
                  _loadQualities();
                  _loadKPIs();
                  _loadData();
                },
              ),
              const SizedBox(width: 12),
              CellButton(
                text: 'New Design',
                icon: LucideIcons.plus,
                variant: CellButtonVariant.primary,
                onPressed: _showCreateDesignDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Row of 6 KPI cards
          Row(
            children: [
              Expanded(
                child: DomainKpiTile(
                  label: 'In Production',
                  value: _kpis['in_production'].toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DomainKpiTile(
                  label: 'At Mill',
                  value: _kpis['at_mill'].toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DomainKpiTile(
                  label: 'In Stock',
                  value: _kpis['in_stock'].toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DomainKpiTile(
                  label: 'Archived',
                  value: _kpis['archived'].toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DomainKpiTile(
                  label: 'Stock at Shop',
                  value: _kpis['shop_stock'].toString(),
                  unit: 'pcs',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DomainKpiTile(
                  label: 'Stock at Job',
                  value: _kpis['job_stock'].toString(),
                  unit: 'pcs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. FILTER, SORT, SEARCH AND PAGINATION BAR
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: CellInput(
                  placeholder: 'Search design or quality...',
                  prefixIcon: LucideIcons.search,
                  onChanged: (val) {
                    setState(() {
                      _searchTerm = val;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Filter Quality Dropdown
              Expanded(
                child: TissueDropdown<String?>(
                  value: _filterQuality,
                  items: [null, ..._qualitiesList],
                  itemLabelBuilder: (val) => val ?? 'All Qualities',
                  onChanged: (val) {
                    setState(() {
                      _filterQuality = val;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Filter Status Dropdown
              Expanded(
                child: TissueDropdown<String?>(
                  value: _filterStatus,
                  items: const [null, 'in_production', 'at_mill', 'in_stock', 'archived'],
                  itemLabelBuilder: (val) {
                    if (val == null) return 'All Statuses';
                    if (val == 'in_production') return 'In Production';
                    if (val == 'at_mill') return 'At Mill';
                    if (val == 'in_stock') return 'In Stock';
                    if (val == 'archived') return 'Archived';
                    return val;
                  },
                  onChanged: (val) {
                    setState(() {
                      _filterStatus = val;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Filter Master toggle
              CellBox(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Masters Only',
                      style: OrganismTheme.labelMedium(context),
                    ),
                    const SizedBox(width: 8),
                    CellCheckbox(
                      value: _filterMaster ?? false,
                      onChanged: (val) {
                        setState(() {
                          _filterMaster = (val == true) ? true : null;
                          _currentPage = 1;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Text(
                '$_currentPage / ${(_totalCount / _limit).ceil().clamp(1, 999)} ($_totalCount total)',
                style: TextStyle(color: colors.stone400, fontSize: 12),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(LucideIcons.chevronLeft, size: 18, color: _currentPage > 1 ? colors.stone200 : colors.stone600),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadData();
                      }
                    : null,
              ),
              IconButton(
                icon: Icon(LucideIcons.chevronRight, size: 18, color: _currentPage < (_totalCount / _limit).ceil() ? colors.stone200 : colors.stone600),
                onPressed: _currentPage < (_totalCount / _limit).ceil()
                    ? () {
                        setState(() => _currentPage++);
                        _loadData();
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. MAIN WORKSPACE ROW SPLIT (2/3 Grid + 1/3 Detail Panel)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2/3 Width Media Library Grid
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(OrganismTheme.radiusMd),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _designs.isEmpty
                            ? Center(
                                child: Text('No designs match current filters.', style: TextStyle(color: colors.textMuted)),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.76,
                                ),
                                itemCount: _designs.length,
                                itemBuilder: (context, index) {
                                  final design = _designs[index];
                                  final isSelected = _selectedDesign?.id == design.id;

                                  // Resolve model picture cover path
                                  final String? imgUrl = design.setPosterPath != null
                                      ? _service.getPublicFileUrl('Model_Pics', design.setPosterPath!)
                                      : null;

                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedDesign = design),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected ? colors.surfaceActive : colors.surface,
                                        border: Border.all(
                                          color: isSelected ? colors.primary : colors.border,
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(OrganismTheme.radiusMd),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Saree/Model Photo block
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colors.surfaceActive,
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(OrganismTheme.radiusMd - 1.0)),
                                                image: imgUrl != null
                                                    ? DecorationImage(
                                                        image: NetworkImage(imgUrl),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: imgUrl == null
                                                  ? Center(
                                                      child: Icon(
                                                        design.isMaster ? LucideIcons.star : LucideIcons.palette,
                                                        color: colors.textMuted,
                                                        size: 32,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),

                                          // Catalog card labels info
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        design.designNo,
                                                        style: OrganismTheme.bodyMedium(context).copyWith(
                                                          color: colors.textPrimary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (design.isMaster)
                                                      Icon(LucideIcons.star, color: colors.warning, size: 12),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  design.itemQCode,
                                                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    // Status Chip mini
                                                    _buildStatusPill(design.displayStatus, design.status, colors),
                                                    // Pieces count
                                                    Text(
                                                      '${design.stockReady} Pcs',
                                                      style: OrganismTheme.numericMedium(context).copyWith(
                                                        color: design.stockReady > 0 ? colors.success : colors.textMuted,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                const SizedBox(width: 20),

                // 1/3 Width Detail View
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(OrganismTheme.radiusMd),
                    ),
                    child: _selectedDesign == null
                        ? Center(
                            child: TissueEmptyState(
                              title: 'No Selection',
                              message: 'Select a design catalog card to view details.',
                              icon: LucideIcons.palette,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title Header pane
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _selectedDesign!.designNo,
                                                  style: OrganismTheme.titleLarge(context),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (_selectedDesign!.isMaster)
                                                Icon(LucideIcons.star, color: colors.warning, size: 16),
                                            ],
                                          ),
                                          Text(
                                            'Fabric: ${_selectedDesign!.itemQCode}',
                                            style: TextStyle(color: colors.textSecondary, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Quick Status Switcher Dropdown
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: colors.border),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedDesign!.status,
                                          dropdownColor: colors.surface,
                                          style: TextStyle(color: colors.textPrimary, fontSize: 11),
                                          items: const [
                                            DropdownMenuItem(value: 'in_production', child: Text('Prod')),
                                            DropdownMenuItem(value: 'at_mill', child: Text('Mill')),
                                            DropdownMenuItem(value: 'in_stock', child: Text('Stock')),
                                            DropdownMenuItem(value: 'archived', child: Text('Archive')),
                                          ],
                                          onChanged: (val) async {
                                            if (val != null) {
                                              final success = await _service.updateDesign(_selectedDesign!.id, {'status': val});
                                              if (success) {
                                                await _loadKPIs();
                                                await _loadData();
                                                if (mounted) {
                                                  setState(() {
                                                    _selectedDesign = _designs.firstWhere((d) => d.id == _selectedDesign!.id, orElse: () => _selectedDesign!);
                                                  });
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),

                                // Photoshoot set previews stacked
                                Text('PHOTOSHOOT & COLOR MATCHING MEDIA', style: TextStyle(color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    // Set Poster (1/2 width)
                                    Expanded(
                                      child: _buildMediaPickerBox(
                                        'Set Poster',
                                        _selectedDesign!.setPosterPath,
                                        'Model_Pics',
                                        'set_poster_path',
                                        colors,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Set Pic (1/2 width)
                                    Expanded(
                                      child: _buildMediaPickerBox(
                                        'Set Pic (Colors)',
                                        _selectedDesign!.setPicPath,
                                        'Saree_Pics',
                                        'set_pic_path',
                                        colors,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Catalog PDF Download Section
                                Text('CATALOG PDF BROCHURE', style: TextStyle(color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.fileText, color: _selectedDesign!.catalogPdfPath != null ? colors.error : colors.textMuted),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _selectedDesign!.catalogPdfPath != null ? 'Catalog document ready' : 'No Catalog PDF linked',
                                          style: TextStyle(color: colors.textPrimary, fontSize: 12),
                                        ),
                                      ),
                                      CellButton(
                                        text: _selectedDesign!.catalogPdfPath != null ? 'Replace' : 'Upload',
                                        variant: CellButtonVariant.ghost,
                                        isCompact: true,
                                        onPressed: () => _uploadFile(_selectedDesign!, 'Model_PDF', 'catalog_pdf_path'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Stock Ledger parameters block
                                Text('CURRENT STOCK BALANCES (PCS)', style: TextStyle(color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                const SizedBox(height: 8),
                                _buildStockLedgerRow('Opening Balance', _selectedDesign!.openingBalance, 'opening_balance', colors),
                                _buildStockLedgerRow('In Production / Job', _selectedDesign!.stockProduction, 'stock_production', colors),
                                _buildStockLedgerRow('Ready Stock / Shop', _selectedDesign!.stockReady, 'stock_ready', colors),
                                _buildStockLedgerRow('Sold Stock', _selectedDesign!.stockSold, 'stock_sold', colors),
                                _buildStockLedgerRow('Damaged / Seconds', _selectedDesign!.stockDamaged, 'stock_damaged', colors),

                                const SizedBox(height: 24),
                                // Remarks and edit panel
                                Text('REMARKS', style: TextStyle(color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedDesign!.remarks == null || _selectedDesign!.remarks!.isEmpty
                                      ? 'No remarks logged.'
                                      : _selectedDesign!.remarks!,
                                  style: TextStyle(color: colors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                                ),

                                const Divider(height: 36),

                                // Danger zone deletion
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CellButton(
                                      text: 'Delete design',
                                      icon: LucideIcons.trash2,
                                      variant: CellButtonVariant.outline,
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: colors.surface,
                                              title: Text('Delete ${_selectedDesign!.designNo}?', style: TextStyle(color: colors.textPrimary)),
                                              content: Text('Are you sure you want to delete this design catalog record? This action is permanent.', style: TextStyle(color: colors.textSecondary)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          final success = await _service.deleteDesign(_selectedDesign!.id);
                                          if (success) {
                                            setState(() {
                                              _selectedDesign = null;
                                            });
                                            await _loadKPIs();
                                            await _loadData();
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Status pills colored
  Widget _buildStatusPill(String label, String code, OrganismColors colors) {
    Color bg = colors.surfaceActive;
    Color fg = colors.textSecondary;

    if (code == 'in_production') {
      bg = colors.info.withValues(alpha: 0.12);
      fg = colors.info;
    } else if (code == 'at_mill') {
      bg = colors.warning.withValues(alpha: 0.12);
      fg = colors.warning;
    } else if (code == 'in_stock') {
      bg = colors.success.withValues(alpha: 0.12);
      fg = colors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Media picker drawer box
  Widget _buildMediaPickerBox(
    String label,
    String? path,
    String bucketName,
    String columnName,
    OrganismColors colors,
  ) {
    final String? resolvedUrl = path != null ? _service.getPublicFileUrl(bucketName, path) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _uploadFile(_selectedDesign!, bucketName, columnName),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: colors.surfaceActive,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(6),
              image: resolvedUrl != null
                  ? DecorationImage(image: NetworkImage(resolvedUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: resolvedUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.camera, color: colors.textMuted, size: 28),
                      const SizedBox(height: 8),
                      Text('Upload photo', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    ],
                  )
                : Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(LucideIcons.edit, color: Colors.white, size: 12),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Stock row item
  Widget _buildStockLedgerRow(String label, int value, String fieldName, OrganismColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          const Spacer(),
          Text(
            '$value Pcs',
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'Courier',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(LucideIcons.edit, color: colors.textMuted, size: 13),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showEditStockDialog(_selectedDesign!, fieldName, label, value),
          ),
        ],
      ),
    );
  }
}
