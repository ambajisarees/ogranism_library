/*
================================================================================
LLM CONTEXT & QUERY SPACE — ADD / CONVERT SOURCE & DESIGN MODAL
================================================================================
1. DOMAIN & PURPOSE:
   - Dual-mode modal for creating & editing Vendor Sources (`IMMBE2627.sb_sources`)
     and promoting/converting them into Commercial Designs (`IMMBE2627.sb_designs`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Tab 0 (`Vendor Source`): Entry via `MILL_PROGRAM` or `FINISH_PURCHASE`;
     mints `source_code` (`<4-ALPHA-VENDOR>-<source_des_no>`, e.g. `AAIS-402`);
     stores vendor metadata inside `origin_specs` JSONB only.
   - Tab 1 (`Commercial Design`): Links strictly to `sb_item` (`parent_item`) and
     an active `sb_sources` row (`active_source_id`); computes live `comp_score`
     and auto-generates `pending_tasks` inside `sb_designs`.
   - Allows 1-click "Save & Convert to Design" from any Mill / Top-Dyed Source.

3. UI & SHADCN FLUTTER COMPLIANCE:
   - Uses `shad.showOverlay`, `shad.OutlinedContainer`, `shad.PrimaryButton`,
     `shad.SecondaryButton`, `shad.OutlineButton`, `shad.GhostButton`,
     `shad.TextField` (`skipInputFeatureFocusTraversal: true`), `shad.DensityGap`,
     and native theme tokens strictly.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future Cutting Card & Job Card screens can launch this modal directly
     pre-populated with a chosen `MdlSource`.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/masters/items/mdl_sb_item.dart';
import '../../../models/masters/mdl_design.dart';
import '../../../services/masters/srv_design.dart';

/// Opens the Source & Design Add/Edit Modal. Returns `true` when saved.
Future<bool> showDsnAddEditDialog(
  BuildContext context, {
  int initialTab = 0,
  MdlSource? existingSource,
  MdlDesign? existingDesign,
}) async {
  bool saved = false;
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: true),
    builder: (overlayCtx) {
      return Center(
        child: DiaDsnAddEdit(
          initialTab: initialTab,
          existingSource: existingSource,
          existingDesign: existingDesign,
          onSaved: () {
            saved = true;
            shad.closeOverlay(overlayCtx);
          },
          onCancel: () => shad.closeOverlay(overlayCtx),
        ),
      );
    },
  );
  await completer.future;
  return saved;
}

class DiaDsnAddEdit extends StatefulWidget {
  final int initialTab; // 0 = Vendor Source, 1 = Commercial Design
  final MdlSource? existingSource;
  final MdlDesign? existingDesign;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const DiaDsnAddEdit({
    super.key,
    this.initialTab = 0,
    this.existingSource,
    this.existingDesign,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<DiaDsnAddEdit> createState() => _DiaDsnAddEditState();
}

class _DiaDsnAddEditState extends State<DiaDsnAddEdit> {
  final SrvDesign _srv = SrvDesign();

  late int _activeTab;
  bool _isLoadingInit = true;
  bool _isSaving = false;
  String? _errorMsg;

  // Lookups
  List<MdlSource> _availableSources = [];
  List<MdlSbItem> _parentItems = [];

  // ----------------- TAB 0: SOURCE CONTROLLERS -----------------
  SourceEntryStage _entryStage = SourceEntryStage.millProgram;
  SareeType _srcSareeType = SareeType.printed;
  final TextEditingController _vendorNameCtrl = TextEditingController();
  final TextEditingController _vendorCodeCtrl = TextEditingController();
  final TextEditingController _srcDesNoCtrl = TextEditingController();
  final TextEditingController _baseFabricCtrl = TextEditingController();
  final TextEditingController _srcRateCtrl = TextEditingController();
  final TextEditingController _colorOptsCtrl = TextEditingController();
  final TextEditingController _srcFinalColorsCtrl = TextEditingController();

  // ----------------- TAB 1: DESIGN CONTROLLERS -----------------
  SareeType _dsnSareeType = SareeType.printed;
  DesignStage _lifecycleStage = DesignStage.millStage;
  bool _isMaster = false;
  String? _selectedParentItemId;
  String? _selectedSourceId;
  final TextEditingController _desNoCtrl = TextEditingController(text: '001');
  final TextEditingController _finalCutCtrl =
      TextEditingController(text: '6.30');
  final TextEditingController _finalWtCtrl =
      TextEditingController(text: '450');
  final TextEditingController _pcsPerSetCtrl = TextEditingController(text: '6');
  final TextEditingController _dsnColorsCtrl = TextEditingController();
  final TextEditingController _printFamilyCtrl = TextEditingController();
  final TextEditingController _borderStyleCtrl = TextEditingController();
  final TextEditingController _occasionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeTab = widget.existingDesign != null ? 1 : widget.initialTab;
    _hydrateFromExisting();
    _loadLookups();
  }

  void _hydrateFromExisting() {
    final s = widget.existingSource;
    if (s != null) {
      _entryStage = s.entryStage;
      _srcSareeType = s.sareeType;
      _vendorNameCtrl.text = s.vendorName;
      _vendorCodeCtrl.text = s.vendorCode;
      _srcDesNoCtrl.text = s.sourceDesNo;
      _baseFabricCtrl.text = s.baseFabric;
      _srcRateCtrl.text =
          s.originRate > 0 ? s.originRate.toStringAsFixed(2) : '';
      _colorOptsCtrl.text = s.colorOptions.join(', ');
      _srcFinalColorsCtrl.text = s.finalColors.join(', ');
    }

    final d = widget.existingDesign;
    if (d != null) {
      _dsnSareeType = d.sareeType;
      _lifecycleStage = d.lifecycleStage;
      _isMaster = d.isMaster;
      _selectedParentItemId = d.parentItemId;
      _selectedSourceId = d.activeSourceId;
      _desNoCtrl.text = d.desNo;
      if (d.finalCut > 0) _finalCutCtrl.text = d.finalCut.toStringAsFixed(2);
      if (d.finalWeight > 0) {
        _finalWtCtrl.text = d.finalWeight.toStringAsFixed(0);
      }
      _pcsPerSetCtrl.text = d.pcsPerSet.toString();
      _dsnColorsCtrl.text = d.finalColors.join(', ');
      _printFamilyCtrl.text = d.printFamily;
      _borderStyleCtrl.text = d.borderStyle;
      _occasionCtrl.text = d.occasion;
    }
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait([
      _srv.getSources(),
      _srv.getFinishedSareeItems(),
    ]);
    if (!mounted) return;
    setState(() {
      _availableSources = results[0] as List<MdlSource>;
      _parentItems = results[1] as List<MdlSbItem>;
      if (_selectedParentItemId == null && _parentItems.isNotEmpty) {
        _selectedParentItemId = _parentItems.first.id;
      }
      if (_selectedSourceId == null && widget.existingSource?.id != null) {
        _applySourceToDesign(widget.existingSource!);
      }
      _isLoadingInit = false;
    });
  }

  @override
  void dispose() {
    _vendorNameCtrl.dispose();
    _vendorCodeCtrl.dispose();
    _srcDesNoCtrl.dispose();
    _baseFabricCtrl.dispose();
    _srcRateCtrl.dispose();
    _colorOptsCtrl.dispose();
    _srcFinalColorsCtrl.dispose();
    _desNoCtrl.dispose();
    _finalCutCtrl.dispose();
    _finalWtCtrl.dispose();
    _pcsPerSetCtrl.dispose();
    _dsnColorsCtrl.dispose();
    _printFamilyCtrl.dispose();
    _borderStyleCtrl.dispose();
    _occasionCtrl.dispose();
    super.dispose();
  }

  List<String> _splitColors(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String get _previewSourceCode {
    final prefix = _vendorCodeCtrl.text.trim().isNotEmpty
        ? _vendorCodeCtrl.text.trim()
        : _vendorNameCtrl.text.trim();
    return MdlSource.formatSourceCode(prefix, _srcDesNoCtrl.text);
  }

  MdlSbItem? get _selectedParentItem {
    for (final item in _parentItems) {
      if (item.id == _selectedParentItemId) return item;
    }
    return null;
  }

  String get _previewDesCode {
    final item = _selectedParentItem;
    if (item == null) return _desNoCtrl.text.trim().toUpperCase();
    return MdlDesign.formatDesCode(item.itemCode, _desNoCtrl.text);
  }

  void _applySourceToDesign(MdlSource src) {
    _selectedSourceId = src.id;
    _dsnSareeType = src.sareeType;
    if (_dsnColorsCtrl.text.trim().isEmpty) {
      final cols = src.finalColors.isNotEmpty ? src.finalColors : src.colorOptions;
      _dsnColorsCtrl.text = cols.join(', ');
    }
  }

  MdlDesign _buildDraftDesign() {
    final double cut = double.tryParse(_finalCutCtrl.text.trim()) ?? 6.30;
    final double wt = double.tryParse(_finalWtCtrl.text.trim()) ?? 0.0;
    final int pcs = int.tryParse(_pcsPerSetCtrl.text.trim()) ?? 6;
    final double bundleWt = (wt > 0 && pcs > 0) ? (wt * pcs) / 1000.0 : 0.0;
    final cols = _splitColors(_dsnColorsCtrl.text);

    return MdlDesign(
      id: widget.existingDesign?.id,
      desCode: _previewDesCode,
      desNo: _desNoCtrl.text.trim().toUpperCase(),
      sareeType: _dsnSareeType,
      parentItemId: _selectedParentItemId ?? '',
      isMaster: _isMaster,
      activeSourceId: _selectedSourceId,
      activeSpecs: {
        'final_cut': cut,
        'final_weight': wt,
        'pcs_per_set': pcs,
        'final_bundle_weight': double.parse(bundleWt.toStringAsFixed(3)),
        'final_colors': cols,
      },
      designAttributes: {
        if (_printFamilyCtrl.text.trim().isNotEmpty)
          'print_family': _printFamilyCtrl.text.trim().toUpperCase(),
        if (_borderStyleCtrl.text.trim().isNotEmpty)
          'border_style': _borderStyleCtrl.text.trim().toUpperCase(),
        if (_occasionCtrl.text.trim().isNotEmpty)
          'occasion': _occasionCtrl.text.trim().toUpperCase(),
        if (cols.isNotEmpty) 'dominant_colors': cols.take(3).toList(),
      },
      thumbUrl: widget.existingDesign?.thumbUrl,
      mediaUrls: widget.existingDesign?.mediaUrls ?? const [],
      pdfPaths: widget.existingDesign?.pdfPaths ?? const [],
      lifecycleStage: _lifecycleStage,
    );
  }

  Future<void> _saveSource({required bool convertToDesign}) async {
    final desNo = _srcDesNoCtrl.text.trim().toUpperCase();
    final vendorName = _vendorNameCtrl.text.trim();
    if (vendorName.isEmpty && _vendorCodeCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Enter a Mill / Weaver Vendor Name or Code.');
      return;
    }
    if (desNo.isEmpty) {
      setState(() => _errorMsg = 'Enter the Vendor Design No (source_des_no).');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      final String computedCode = _previewSourceCode;
      final String fourAlpha = computedCode.split('-').first;
      final double rate = double.tryParse(_srcRateCtrl.text.trim()) ?? 0.0;
      final colorOpts = _splitColors(_colorOptsCtrl.text);
      final finalCols = _splitColors(_srcFinalColorsCtrl.text);

      final draftSrc = MdlSource(
        id: widget.existingSource?.id,
        sourceDesNo: desNo,
        sourceCode: computedCode,
        sareeType: _srcSareeType,
        entryStage: _entryStage,
        originSpecs: {
          'vendor_code': fourAlpha,
          'vendor_name': vendorName.isNotEmpty ? vendorName : fourAlpha,
          'base_fabric': _baseFabricCtrl.text.trim(),
          if (_entryStage == SourceEntryStage.finishPurchase)
            'purchase_rate': rate
          else
            'mill_rate': rate,
          'color_options': colorOpts,
          'final_colors': finalCols.isNotEmpty ? finalCols : colorOpts,
        },
        rawMediaIds: widget.existingSource?.rawMediaIds ?? const [],
        thumbUrl: widget.existingSource?.thumbUrl,
      );

      final savedSrc = await _srv.saveSource(draftSrc);
      if (!mounted) return;
      if (savedSrc == null) {
        setState(() {
          _isSaving = false;
          _errorMsg = 'Unable to save source.';
        });
        return;
      }

      if (convertToDesign) {
        final refreshedSources = await _srv.getSources();
        if (!mounted) return;
        setState(() {
          _availableSources = refreshedSources;
          _applySourceToDesign(savedSrc);
          _activeTab = 1;
          _isSaving = false;
        });
      } else {
        widget.onSaved();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMsg = e.toString();
      });
    }
  }

  Future<void> _saveDesign() async {
    if (_selectedParentItemId == null || _selectedParentItemId!.isEmpty) {
      setState(
        () => _errorMsg =
            'Select a Parent Commercial Item from sb_item before saving.',
      );
      return;
    }
    if (_desNoCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Enter a Design No (e.g. 001).');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      final draft = _buildDraftDesign();
      await _srv.saveDesign(draft);
      if (!mounted) return;
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final double scale = theme.scaling;
    final double pad = theme.density.baseContainerPadding * scale;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 880 * scale,
        maxHeight: 720 * scale,
      ),
      child: shad.OutlinedContainer(
        backgroundColor: colors.card,
        borderColor: colors.border,
        borderRadius: theme.borderRadiusLg,
        padding: EdgeInsets.all(pad * 1.25),
        child: _isLoadingInit
            ? const SizedBox(
                height: 240,
                child: Center(child: shad.CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(theme, colors, scale),
                  const shad.DensityGap(shad.gapMd),
                  _buildModeSwitcherRow(theme, colors, scale),
                  const shad.DensityGap(shad.gapMd),
                  if (_errorMsg != null) ...[
                    shad.Alert.destructive(
                      title: const Text('Validation Error'),
                      content: Text(_errorMsg!),
                    ),
                    const shad.DensityGap(shad.gapMd),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      child: _activeTab == 0
                          ? _buildSourceForm(theme, colors, scale)
                          : _buildDesignForm(theme, colors, scale),
                    ),
                  ),
                  const shad.DensityGap(shad.gapLg),
                  _buildFooter(theme, colors),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    return Row(
      children: [
        Icon(
          _activeTab == 0
              ? shad.LucideIcons.factory
              : shad.LucideIcons.palette,
          size: 19 * scale,
          color: colors.primary,
        ),
        const shad.DensityGap(shad.gapSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activeTab == 0
                    ? 'Vendor Source Repository (sb_sources)'
                    : 'Commercial Design SKU (sb_designs -> sb_item)',
                style: theme.typography.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              Text(
                _activeTab == 0
                    ? 'Capture Mill Program (Printed/Dyed) or Finish Purchase (Top-Dyed) metadata once & convert at any stage.'
                    : 'Bind to a Parent sb_item, carry forward batch active_specs, and tag customer preference attributes.',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        shad.IconButton.ghost(
          icon: const Icon(shad.LucideIcons.x, size: 16),
          onPressed: widget.onCancel,
        ),
      ],
    );
  }

  Widget _buildModeSwitcherRow(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    return Row(
      children: [
        _activeTab == 0
            ? shad.PrimaryButton(
                size: shad.ButtonSize.small,
                leading: const Icon(shad.LucideIcons.factory, size: 14),
                onPressed: () {},
                child: const Text('1. Vendor Source (sb_sources)'),
              )
            : shad.OutlineButton(
                size: shad.ButtonSize.small,
                leading: const Icon(shad.LucideIcons.factory, size: 14),
                onPressed: () => setState(() {
                  _errorMsg = null;
                  _activeTab = 0;
                }),
                child: const Text('1. Vendor Source (sb_sources)'),
              ),
        const shad.DensityGap(shad.gapSm),
        _activeTab == 1
            ? shad.PrimaryButton(
                size: shad.ButtonSize.small,
                leading: const Icon(shad.LucideIcons.palette, size: 14),
                onPressed: () {},
                child: const Text('2. Commercial Design (sb_designs)'),
              )
            : shad.OutlineButton(
                size: shad.ButtonSize.small,
                leading: const Icon(shad.LucideIcons.palette, size: 14),
                onPressed: () => setState(() {
                  _errorMsg = null;
                  _activeTab = 1;
                }),
                child: const Text('2. Commercial Design (sb_designs)'),
              ),
        const Spacer(),
        shad.SecondaryBadge(
          child: Text(
            _activeTab == 0
                ? 'Source Code: $_previewSourceCode'
                : 'Design Code: $_previewDesCode',
            style: const TextStyle(fontFamily: 'JetBrains Mono'),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceForm(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Entry Point & Saree Type
        Wrap(
          spacing: 12 * scale,
          runSpacing: 10 * scale,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(theme, colors, 'Entry Point'),
                const shad.DensityGap(shad.gapXs),
                Wrap(
                  spacing: 6 * scale,
                  children: SourceEntryStage.values.map((st) {
                    final sel = _entryStage == st;
                    return sel
                        ? shad.PrimaryButton(
                            size: shad.ButtonSize.small,
                            onPressed: () {},
                            child: Text(st.displayName),
                          )
                        : shad.OutlineButton(
                            size: shad.ButtonSize.small,
                            onPressed: () {
                              setState(() {
                                _entryStage = st;
                                if (st == SourceEntryStage.finishPurchase) {
                                  _srcSareeType = SareeType.topDyed;
                                } else if (_srcSareeType == SareeType.topDyed) {
                                  _srcSareeType = SareeType.printed;
                                }
                              });
                            },
                            child: Text(st.displayName),
                          );
                  }).toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(theme, colors, 'Saree Type'),
                const shad.DensityGap(shad.gapXs),
                Wrap(
                  spacing: 6 * scale,
                  children: SareeType.values.map((t) {
                    final sel = _srcSareeType == t;
                    return sel
                        ? shad.PrimaryButton(
                            size: shad.ButtonSize.small,
                            onPressed: () {},
                            child: Text(t.displayName),
                          )
                        : shad.OutlineButton(
                            size: shad.ButtonSize.small,
                            onPressed: () => setState(() => _srcSareeType = t),
                            child: Text(t.displayName),
                          );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

        // Vendor Name + 4-Char Code + source_des_no
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Mill / Weaver Vendor Name *'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _vendorNameCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('e.g. AAISWARYA DYEING MILLS'),
                    onChanged: (v) {
                      if (_vendorCodeCtrl.text.trim().length <= 4) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, '4-Alpha Code'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _vendorCodeCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('AAIS'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Vendor Design No *'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _srcDesNoCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('e.g. 402 or Z19'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

        // Origin Specs JSONB: Base Fabric + Rate
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Base Fabric / Yarn Spec'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _baseFabricCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('e.g. RENIAL, DANI SHARMILI, RAPIER ZARI'),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(
                    theme,
                    colors,
                    _entryStage == SourceEntryStage.finishPurchase
                        ? 'Finish Purchase Rate (₹)'
                        : 'Mill Process Rate (₹/mtr)',
                  ),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _srcRateCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('0.00'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

        // Colors
        _label(theme, colors, 'Color Options (Comma-Separated)'),
        const shad.DensityGap(shad.gapXs),
        shad.TextField(
          controller: _colorOptsCtrl,
          skipInputFeatureFocusTraversal: true,
          placeholder: const Text('Wine, Rani, Mustard, Navy, Bottle Green, Maroon'),
        ),
        const shad.DensityGap(shad.gapSm),
        _label(theme, colors, 'Final Confirmed Colors (Optional — Defaults to Options)'),
        const shad.DensityGap(shad.gapXs),
        shad.TextField(
          controller: _srcFinalColorsCtrl,
          skipInputFeatureFocusTraversal: true,
          placeholder: const Text('Confirmed colors matched for this run'),
        ),
      ],
    );
  }

  Widget _buildDesignForm(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
  ) {
    final draftEval = _buildDraftDesign().evaluateCompletion();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Completion Banner
        shad.OutlinedContainer(
          backgroundColor: colors.muted.withValues(alpha: 0.45),
          borderColor: colors.border,
          borderRadius: theme.borderRadiusMd,
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 8 * scale,
          ),
          child: Row(
            children: [
              shad.PrimaryBadge(
                child: Text('Readiness: ${draftEval.score}%'),
              ),
              const shad.DensityGap(shad.gapSm),
              Expanded(
                child: Text(
                  draftEval.pendingTasks.isEmpty
                      ? '100% Catalog Complete'
                      : '${draftEval.pendingTasks.length} auto-tasks queued: ${draftEval.pendingTasks.first['title']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
        const shad.DensityGap(shad.gapMd),

        // 2. Link Vendor Source (`sb_sources`)
        _label(theme, colors, 'Active Vendor Source (sb_sources)'),
        const shad.DensityGap(shad.gapXs),
        if (_availableSources.isEmpty)
          Text(
            'No sources created yet — create one in Tab 1 first.',
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
            ),
          )
        else
          Wrap(
            spacing: 6 * scale,
            runSpacing: 6 * scale,
            children: _availableSources.map((src) {
              final sel = _selectedSourceId == src.id;
              return sel
                  ? shad.PrimaryButton(
                      size: shad.ButtonSize.small,
                      onPressed: () {},
                      child: Text('${src.sourceCode} (${src.sareeType.dbValue})'),
                    )
                  : shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: () {
                        setState(() => _applySourceToDesign(src));
                      },
                      child: Text('${src.sourceCode} • ${src.baseFabric}'),
                    );
            }).toList(),
          ),
        const shad.DensityGap(shad.gapMd),

        // 3. Link Parent Commercial Item (`sb_item` ONLY) + des_no
        _label(theme, colors, 'Parent Commercial Item (sb_item ONLY) *'),
        const shad.DensityGap(shad.gapXs),
        if (_parentItems.isEmpty)
          shad.Alert.destructive(
            title: const Text('No Finished Saree Items in sb_item'),
            content: const Text(
              'Add at least one FINISHED_SAREE item in Items Master first.',
            ),
          )
        else
          Wrap(
            spacing: 6 * scale,
            runSpacing: 6 * scale,
            children: _parentItems.map((item) {
              final sel = _selectedParentItemId == item.id;
              return sel
                  ? shad.PrimaryButton(
                      size: shad.ButtonSize.small,
                      onPressed: () {},
                      child: Text('${item.name} (${item.itemCode})'),
                    )
                  : shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: () =>
                          setState(() => _selectedParentItemId = item.id),
                      child: Text('${item.name} (${item.itemCode})'),
                    );
            }).toList(),
          ),
        const shad.DensityGap(shad.gapMd),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Design No *'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _desNoCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('001'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Lifecycle Stage'),
                  const shad.DensityGap(shad.gapXs),
                  Wrap(
                    spacing: 5 * scale,
                    runSpacing: 5 * scale,
                    children: [
                      DesignStage.millStage,
                      DesignStage.cuttingStage,
                      DesignStage.jobStage,
                      DesignStage.inStock,
                    ].map((st) {
                      final sel = _lifecycleStage == st;
                      return sel
                          ? shad.PrimaryButton(
                              size: shad.ButtonSize.small,
                              onPressed: () {},
                              child: Text(st.displayName),
                            )
                          : shad.OutlineButton(
                              size: shad.ButtonSize.small,
                              onPressed: () =>
                                  setState(() => _lifecycleStage = st),
                              child: Text(st.displayName),
                            );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapMd),

        // 4. active_specs JSONB
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Final Cut (Mtr)'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _finalCutCtrl,
                    skipInputFeatureFocusTraversal: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Final Weight (gm)'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _finalWtCtrl,
                    skipInputFeatureFocusTraversal: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Pcs / Set'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _pcsPerSetCtrl,
                    skipInputFeatureFocusTraversal: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        const shad.DensityGap(shad.gapSm),
        _label(theme, colors, 'Final Active Colors (Comma-Separated)'),
        const shad.DensityGap(shad.gapXs),
        shad.TextField(
          controller: _dsnColorsCtrl,
          skipInputFeatureFocusTraversal: true,
          placeholder: const Text('Wine, Rani, Mustard, Navy'),
          onChanged: (_) => setState(() {}),
        ),
        const shad.DensityGap(shad.gapMd),

        // 5. design_attributes JSONB (Customer Preference Profiling)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Print / Pattern Family'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _printFamilyCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('FLORAL_JAAL, ZARI_WEAVE'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Border Style'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _borderStyleCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('SATIN_PATTA, LACE'),
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(theme, colors, 'Occasion Tag'),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _occasionCtrl,
                    skipInputFeatureFocusTraversal: true,
                    placeholder: const Text('FESTIVE, DAILY_WEAR'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(shad.ThemeData theme, shad.ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        shad.OutlineButton(
          onPressed: _isSaving ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        const shad.DensityGap(shad.gapSm),
        if (_activeTab == 0) ...[
          shad.SecondaryButton(
            onPressed:
                _isSaving ? null : () => _saveSource(convertToDesign: false),
            child: const Text('Save Source Only'),
          ),
          const shad.DensityGap(shad.gapSm),
          shad.PrimaryButton(
            onPressed:
                _isSaving ? null : () => _saveSource(convertToDesign: true),
            child: Text(_isSaving ? 'Saving...' : 'Save & Convert to Design'),
          ),
        ] else
          shad.PrimaryButton(
            onPressed: _isSaving ? null : _saveDesign,
            leading: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: shad.CircularProgressIndicator(),
                  )
                : const Icon(shad.LucideIcons.check, size: 15),
            child: Text(_isSaving ? 'Saving...' : 'Save Design ($_previewDesCode)'),
          ),
      ],
    );
  }

  Widget _label(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String text,
  ) {
    return Text(
      text,
      style: theme.typography.xSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.mutedForeground,
      ),
    );
  }
}
