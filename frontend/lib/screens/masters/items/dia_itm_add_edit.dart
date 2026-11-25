/*
================================================================================
LLM CONTEXT & QUERY SPACE — ADD / UPGRADE ITEM MODAL (dia_itm_add_edit.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Interactive "Clean-As-You-Go" Add / Upgrade Item Modal for `IMMBE2627.sb_item`.
   - Allows operators to search a legacy item from `sq_QUAL`, auto-populate its
     baseline fields, auto-discover historical purchase rates & variations from
     `sq_BILLDET` / `sq_PINVTRN`, enrich Admin-defined `domain_specs` and
     `variations`, and verify the live 0-100% Completion Ratio (`comp_score`)
     before saving.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Driven dynamically by `SbItemGroupConfig` loaded from
     `IMMBE2627.sb_item_group_config`.
   - Supports Option-B JSONB `variations` (each variation carries its own code,
     name, dynamic variation specs, cost price, and reorder level).
   - Writes immutable revision history to `IMMBE2627.sb_item_audit_log`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Strictly uses native `shadcn_flutter` components (`shad.OutlinedContainer`,
     `shad.Button`, `shad.TextField`, `shad.Checkbox`, `shad.PrimaryBadge`,
     `shad.SecondaryBadge`, `shad.DensityGap`) and theme tokens.
================================================================================
*/

library;

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/core/sq/sq_qual.dart';
import '../../../models/masters/items/mdl_sb_item.dart';
import '../../../services/masters/items/srv_sb_item.dart';
import 'widgets/itm_completion_meter.dart';
import 'widgets/itm_variations_audit_section.dart';

/// Opens the [DiaItmAddEdit] modal using native `shad.showOverlay`.
Future<MdlSbItem?> showItmAddEditDialog(
  BuildContext context, {
  SqQualModel? initialLegacyQual,
  MdlSbItem? existingSbItem,
}) async {
  MdlSbItem? savedResult;
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(
      barrierDismissible: true,
    ),
    builder: (overlayCtx) {
      return Center(
        child: DiaItmAddEdit(
          initialLegacyQual: initialLegacyQual,
          existingSbItem: existingSbItem,
          onSaved: (item) {
            savedResult = item;
            shad.closeOverlay(overlayCtx);
          },
          onCancel: () {
            shad.closeOverlay(overlayCtx);
          },
        ),
      );
    },
  );
  await completer.future;
  return savedResult;
}

/// [DiaItmAddEdit] — Main Stateful Modal for Creating / Upgrading an `sb_item`.
class DiaItmAddEdit extends StatefulWidget {
  final SqQualModel? initialLegacyQual;
  final MdlSbItem? existingSbItem;
  final ValueChanged<MdlSbItem> onSaved;
  final VoidCallback onCancel;

  const DiaItmAddEdit({
    super.key,
    this.initialLegacyQual,
    this.existingSbItem,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<DiaItmAddEdit> createState() => _DiaItmAddEditState();
}

class _DiaItmAddEditState extends State<DiaItmAddEdit> {
  final SrvSbItem _srv = SrvSbItem();

  // Admin Group Configs
  List<SbItemGroupConfig> _groupConfigs = [];
  bool _isLoadingInit = true;
  bool _isSaving = false;
  String? _errorMsg;

  // Legacy Search State
  final TextEditingController _legacySearchCtrl = TextEditingController();
  Timer? _searchDebounce;
  List<SqQualModel> _legacySearchResults = [];
  bool _isSearchingLegacy = false;
  SqQualModel? _selectedLegacyQual;
  LegacyBillDiscovery? _billDiscovery;
  bool _isLoadingDiscovery = false;

  // Form Controllers
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _hsnCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _lastPurCtrl = TextEditingController();
  final TextEditingController _sell1Ctrl = TextEditingController();
  final TextEditingController _sell2Ctrl = TextEditingController();
  final TextEditingController _sell3Ctrl = TextEditingController();
  final TextEditingController _reorderCtrl = TextEditingController();
  final TextEditingController _vendorCodeCtrl = TextEditingController();
  final TextEditingController _vendorNameCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();

  // Inline New Variation Controllers
  final TextEditingController _newVarNameCtrl = TextEditingController();
  final TextEditingController _newVarSpecCtrl = TextEditingController();
  final TextEditingController _newVarCostCtrl = TextEditingController();
  final TextEditingController _newVarReorderCtrl = TextEditingController();

  // Active Item State
  late MdlSbItem _draft;
  List<MdlSbItemAuditLog> _auditHistory = [];

  @override
  void initState() {
    super.initState();
    _draft = widget.existingSbItem ??
        const MdlSbItem(
          itemCode: '',
          name: '',
          itemGroup: 'FINISHED_SAREE',
        );
    _initModalData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _legacySearchCtrl.dispose();
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _hsnCtrl.dispose();
    _costCtrl.dispose();
    _lastPurCtrl.dispose();
    _sell1Ctrl.dispose();
    _sell2Ctrl.dispose();
    _sell3Ctrl.dispose();
    _reorderCtrl.dispose();
    _vendorCodeCtrl.dispose();
    _vendorNameCtrl.dispose();
    _reasonCtrl.dispose();
    _newVarNameCtrl.dispose();
    _newVarSpecCtrl.dispose();
    _newVarCostCtrl.dispose();
    _newVarReorderCtrl.dispose();
    super.dispose();
  }

  Future<void> _initModalData() async {
    final configs = await _srv.getGroupConfigs(activeOnly: true);
    if (!mounted) return;

    setState(() {
      _groupConfigs = configs;
      _isLoadingInit = false;
    });

    if (widget.existingSbItem != null) {
      _syncControllersFromDraft(widget.existingSbItem!);
      if (widget.existingSbItem!.id != null) {
        final logs = await _srv.getItemAuditLogs(widget.existingSbItem!.id!);
        if (mounted) {
          setState(() {
            _auditHistory = logs;
          });
        }
      }
    } else if (widget.initialLegacyQual != null) {
      await _applyLegacyQualSelection(widget.initialLegacyQual!);
    } else {
      // Load initial 12 legacy items for quick browsing
      _performLegacySearch('');
    }
  }

  SbItemGroupConfig? get _activeGroupConfig {
    for (final c in _groupConfigs) {
      if (c.groupCode == _draft.itemGroup) return c;
    }
    return _groupConfigs.isNotEmpty ? _groupConfigs.first : null;
  }

  void _syncControllersFromDraft(MdlSbItem d) {
    _codeCtrl.text = d.itemCode;
    _nameCtrl.text = d.name;
    _descCtrl.text = d.description;
    _hsnCtrl.text = d.hsnCode;
    _costCtrl.text = d.costPrice > 0 ? d.costPrice.toStringAsFixed(2) : '';
    _lastPurCtrl.text =
        d.lastPurRate > 0 ? d.lastPurRate.toStringAsFixed(2) : '';
    _sell1Ctrl.text = d.sellPrice1 > 0 ? d.sellPrice1.toStringAsFixed(2) : '';
    _sell2Ctrl.text = d.sellPrice2 > 0 ? d.sellPrice2.toStringAsFixed(2) : '';
    _sell3Ctrl.text = d.sellPrice3 > 0 ? d.sellPrice3.toStringAsFixed(2) : '';
    _reorderCtrl.text = d.reorderLevel > 0 ? d.reorderLevel.toString() : '';
    if (d.prefVendor.isNotEmpty) {
      _vendorCodeCtrl.text = d.prefVendor.first.code;
      _vendorNameCtrl.text = d.prefVendor.first.name;
    } else {
      _vendorCodeCtrl.clear();
      _vendorNameCtrl.clear();
    }
  }

  void _onSearchQueryChanged(String val) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      _performLegacySearch(val);
    });
  }

  Future<void> _performLegacySearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isSearchingLegacy = true;
    });
    final results = await _srv.searchLegacyQual(query, limit: 15);
    if (!mounted) return;
    setState(() {
      _legacySearchResults = results;
      _isSearchingLegacy = false;
    });
  }

  Future<void> _applyLegacyQualSelection(SqQualModel qual) async {
    setState(() {
      _selectedLegacyQual = qual;
      _isLoadingDiscovery = true;
      _legacySearchResults = [];
      _legacySearchCtrl.text = '${qual.name} (${qual.qcode})';
    });

    final discovery = await _srv.discoverLegacyBillInsights(qual.qcode);
    if (!mounted) return;

    final autoDraft = MdlSbItem.fromLegacyQual(
      qual,
      discoveredVariations: discovery.discoveredVariations,
      historicalPurRate: discovery.avgPurchaseRate,
    );

    // Match groupConfig defaults if available
    SbItemGroupConfig? matchedCfg;
    for (final c in _groupConfigs) {
      if (c.groupCode == autoDraft.itemGroup) {
        matchedCfg = c;
        break;
      }
    }

    final enrichedDraft = autoDraft.copyWith(
      allowedSeries: matchedCfg?.allowedSeries ?? autoDraft.allowedSeries,
      hsnCode: autoDraft.hsnCode.isNotEmpty
          ? autoDraft.hsnCode
          : (discovery.topHsnFromBills ?? matchedCfg?.defaultHsn ?? ''),
      reorderLevel: matchedCfg?.isStockTracked == true ? 100 : 0,
    );

    setState(() {
      _draft = enrichedDraft;
      _billDiscovery = discovery;
      _isLoadingDiscovery = false;
      _reasonCtrl.text =
          'Upgraded from legacy sq_QUAL (${qual.qcode}) with verified specs';
    });
    _syncControllersFromDraft(enrichedDraft);
  }

  void _onGroupChanged(SbItemGroupConfig cfg) {
    final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(
      _draft.domainSpecs,
    );
    for (final f in cfg.specSchema) {
      if (!updatedSpecs.containsKey(f.key) && f.defaultValue != null) {
        updatedSpecs[f.key] = f.defaultValue;
      }
    }

    setState(() {
      _draft = _draft.copyWith(
        itemGroup: cfg.groupCode,
        itemNature: cfg.defaultNature,
        canBePurchased: cfg.canBePurchased,
        isInternal: cfg.isInternal,
        canBeSold: cfg.canBeSold,
        isStockTracked: cfg.isStockTracked,
        allowedSeries: cfg.allowedSeries,
        hsnCode: _draft.hsnCode.isEmpty ? cfg.defaultHsn : _draft.hsnCode,
        gstRate: cfg.defaultGstRate,
        hasChildDesigns: cfg.supportsDesigns,
        domainSpecs: updatedSpecs,
      );
      if (_hsnCtrl.text.isEmpty && cfg.defaultHsn.isNotEmpty) {
        _hsnCtrl.text = cfg.defaultHsn;
      }
    });
  }

  void _syncNumericFieldsToDraft() {
    final double cost = double.tryParse(_costCtrl.text.trim()) ?? 0.0;
    final double lastPur = double.tryParse(_lastPurCtrl.text.trim()) ?? 0.0;
    final double s1 = double.tryParse(_sell1Ctrl.text.trim()) ?? 0.0;
    final double s2 = double.tryParse(_sell2Ctrl.text.trim()) ?? 0.0;
    final double s3 = double.tryParse(_sell3Ctrl.text.trim()) ?? 0.0;
    final int reorder = int.tryParse(_reorderCtrl.text.trim()) ?? 0;

    final List<SbPrefVendor> vendors = [];
    if (_vendorCodeCtrl.text.trim().isNotEmpty ||
        _vendorNameCtrl.text.trim().isNotEmpty) {
      vendors.add(SbPrefVendor(
        code: _vendorCodeCtrl.text.trim().isEmpty
            ? 'V-01'
            : _vendorCodeCtrl.text.trim(),
        name: _vendorNameCtrl.text.trim().isEmpty
            ? _vendorCodeCtrl.text.trim()
            : _vendorNameCtrl.text.trim(),
      ));
    }

    setState(() {
      _draft = _draft.copyWith(
        itemCode: _codeCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        hsnCode: _hsnCtrl.text.trim(),
        costPrice: cost,
        lastPurRate: lastPur,
        sellPrice1: s1,
        sellPrice2: s2,
        sellPrice3: s3,
        reorderLevel: reorder,
        prefVendor: vendors,
      );
    });
  }

  void _addInlineVariation() {
    final String vName = _newVarNameCtrl.text.trim();
    if (vName.isEmpty) return;

    final String vSpec = _newVarSpecCtrl.text.trim();
    final double vCost =
        double.tryParse(_newVarCostCtrl.text.trim()) ?? _draft.costPrice;
    final int vReorder = int.tryParse(_newVarReorderCtrl.text.trim()) ?? 50;

    final int nextIdx = _draft.variations.length + 1;
    final String prefix =
        _draft.itemCode.isNotEmpty ? _draft.itemCode : 'VAR';

    final newVar = SbItemVariation(
      code: '$prefix-V$nextIdx',
      name: vName,
      specs: vSpec.isNotEmpty ? {'spec': vSpec} : const {},
      costPrice: vCost,
      lastPurRate: vCost,
      reorderLevel: vReorder,
    );

    setState(() {
      _draft = _draft.copyWith(
        variations: [..._draft.variations, newVar],
      );
      _newVarNameCtrl.clear();
      _newVarSpecCtrl.clear();
      _newVarCostCtrl.clear();
      _newVarReorderCtrl.clear();
    });
  }

  void _removeVariationAt(int index) {
    final updated = List<SbItemVariation>.from(_draft.variations)
      ..removeAt(index);
    setState(() {
      _draft = _draft.copyWith(variations: updated);
    });
  }

  Future<void> _handleSave({bool forceDraft = false}) async {
    _syncNumericFieldsToDraft();

    if (_draft.itemCode.isEmpty || _draft.name.isEmpty) {
      setState(() {
        _errorMsg = 'Item Code and Commercial Name are required.';
      });
      return;
    }

    final breakdown = _draft.evaluateCompletion(
      groupConfig: _activeGroupConfig,
      legacySource: _selectedLegacyQual,
    );

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    final itemToSave = _draft.copyWith(
      status: forceDraft ? 'DRAFT' : 'ACTIVE',
      compScore: breakdown.totalScore,
    );

    final res = await _srv.saveSbItem(
      item: itemToSave,
      calculatedCompScore: breakdown.totalScore,
      reasonComment: _reasonCtrl.text.trim(),
      previousItem: widget.existingSbItem,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (res.success && res.savedItem != null) {
      widget.onSaved(res.savedItem!);
    } else {
      setState(() {
        _errorMsg = res.error ?? 'Failed to save item to sb_item.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    final breakdown = _draft.evaluateCompletion(
      groupConfig: _activeGroupConfig,
      legacySource: _selectedLegacyQual,
    );

    return SizedBox(
      width: 1120 * theme.scaling,
      height: 820 * theme.scaling,
      child: shad.OutlinedContainer(
        backgroundColor: colors.background,
        borderColor: colors.border,
        borderRadius: theme.borderRadiusLg,
        padding: EdgeInsets.all(pad),
        child: _isLoadingInit
            ? const Center(child: shad.CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. TOP MODAL HEADER
                  _buildModalHeader(theme, colors),
                  const shad.DensityGap(0.75),
                  const shad.Divider(),
                  const shad.DensityGap(0.75),

                  // 2. LEGACY sq_QUAL SEARCH & AUTO-POPULATE BAR
                  if (widget.existingSbItem == null) ...[
                    _buildLegacySearchSection(theme, colors),
                    const shad.DensityGap(0.75),
                  ],

                  // 3. MAIN 2-COLUMN SCROLLABLE FORM BODY
                  Expanded(
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN: Identity, Barrel, Compliance, Costing & Warehouse
                          Expanded(
                            flex: 11,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildIdentityAndBarrelCard(theme, colors),
                                const shad.DensityGap(0.75),
                                _buildComplianceAndUomCard(theme, colors),
                                const shad.DensityGap(0.75),
                                _buildCostingAndWarehouseCard(theme, colors),
                              ],
                            ),
                          ),
                          const shad.DensityGap(0.75),

                          // RIGHT COLUMN: Dynamic Domain Specs, Variations & Audit Trail
                          Expanded(
                            flex: 10,
                            child: ItmVariationsAuditSection(
                              draft: _draft,
                              activeGroupConfig: _activeGroupConfig,
                              newVarNameCtrl: _newVarNameCtrl,
                              newVarSpecCtrl: _newVarSpecCtrl,
                              newVarCostCtrl: _newVarCostCtrl,
                              reasonCtrl: _reasonCtrl,
                              auditHistory: _auditHistory,
                              onDomainSpecsChanged: (updatedSpecs) {
                                setState(() {
                                  _draft = _draft.copyWith(
                                    domainSpecs: updatedSpecs,
                                  );
                                });
                              },
                              onAddInlineVariation: _addInlineVariation,
                              onRemoveVariationAt: _removeVariationAt,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const shad.DensityGap(0.75),

                  // 4. LIVE COMPLETION RATIO METER
                  ItmCompletionMeter(
                    breakdown: breakdown,
                    legacyQcode: _draft.legacyQcode,
                  ),

                  if (_errorMsg != null) ...[
                    const shad.DensityGap(0.5),
                    Text(
                      _errorMsg!,
                      style: theme.typography.small.copyWith(
                        color: colors.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const shad.DensityGap(0.75),

                  // 5. FOOTER ACTION BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      shad.OutlineButton(
                        onPressed: _isSaving ? null : widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                      const shad.DensityGap(0.5),
                      shad.SecondaryButton(
                        onPressed: _isSaving
                            ? null
                            : () => _handleSave(forceDraft: true),
                        child: const Text('Save as Draft'),
                      ),
                      const shad.DensityGap(0.5),
                      shad.PrimaryButton(
                        onPressed: _isSaving
                            ? null
                            : () => _handleSave(forceDraft: false),
                        leading: _isSaving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: shad.CircularProgressIndicator(),
                              )
                            : const Icon(shad.LucideIcons.check, size: 15),
                        child: Text(
                          widget.existingSbItem != null
                              ? 'Update Verified Item (${breakdown.totalScore}%)'
                              : 'Finalize & Save to sb_item (${breakdown.totalScore}%)',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildModalHeader(shad.ThemeData theme, shad.ColorScheme colors) {
    final bool isEditing = widget.existingSbItem != null;
    return Row(
      children: [
        Icon(
          isEditing ? shad.LucideIcons.filePen : shad.LucideIcons.sparkles,
          size: 20 * theme.scaling,
          color: colors.primary,
        ),
        const shad.DensityGap(0.6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing
                    ? 'Edit Verified Item Master (${_draft.itemCode})'
                    : 'Add / Upgrade Item to Modern Registry (sb_item)',
                style: theme.typography.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              Text(
                'Search any legacy sq_QUAL item to auto-populate, enrich missing HSN/costing/variations, and verify completion ratio.',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        if (_draft.legacyQcode != null && _draft.legacyQcode!.isNotEmpty)
          shad.PrimaryBadge(
            child: Text('Linked Legacy: ${_draft.legacyQcode}'),
          ),
        const shad.DensityGap(0.5),
        shad.GhostButton(
          density: shad.ButtonDensity.icon,
          onPressed: widget.onCancel,
          child: const Icon(shad.LucideIcons.x, size: 16),
        ),
      ],
    );
  }

  Widget _buildLegacySearchSection(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.65;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                shad.LucideIcons.search,
                size: 15 * theme.scaling,
                color: colors.primary,
              ),
              const shad.DensityGap(0.5),
              Text(
                'Step 1: Search Legacy Item (sq_QUAL) to Auto-Populate',
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              const Spacer(),
              if (_isLoadingDiscovery)
                Text(
                  'Scanning historical bills...',
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                )
              else if (_billDiscovery != null &&
                  _billDiscovery!.totalHistoricalBills > 0)
                shad.SecondaryBadge(
                  child: Text(
                    'Historical Audit: ${_billDiscovery!.totalHistoricalBills} Bill Lines • Avg Rate: ₹${_billDiscovery!.avgPurchaseRate.toStringAsFixed(2)} • ${_billDiscovery!.discoveredVariations.length} Variations Imported',
                    style: theme.typography.xSmall.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const shad.DensityGap(0.5),
          Row(
            children: [
              Expanded(
                child: shad.TextField(
                  controller: _legacySearchCtrl,
                  placeholder: const Text(
                    'Search legacy sq_QUAL by name or code (e.g. CARTOON, CHAIN BAG, FOAM, DANI, PARUL)...',
                  ),
                  onChanged: _onSearchQueryChanged,
                ),
              ),
              const shad.DensityGap(0.5),
              shad.OutlineButton(
                onPressed: () {
                  _performLegacySearch(_legacySearchCtrl.text);
                },
                leading: const Icon(shad.LucideIcons.refreshCw, size: 14),
                child: const Text('Browse Legacy'),
              ),
            ],
          ),
          if (_isSearchingLegacy) ...[
            const shad.DensityGap(0.5),
            const shad.LinearProgressIndicator(),
          ] else if (_legacySearchResults.isNotEmpty) ...[
            const shad.DensityGap(0.5),
            SizedBox(
              height: 115 * theme.scaling,
              child: ListView.separated(
                itemCount: _legacySearchResults.length,
                separatorBuilder: (ctx, idx) => const shad.DensityGap(0.25),
                itemBuilder: (ctx, idx) {
                  final q = _legacySearchResults[idx];
                  return shad.OutlineButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () => _applyLegacyQualSelection(q),
                    child: Row(
                      children: [
                        shad.SecondaryBadge(
                          child: Text(
                            q.qcode,
                            style: theme.typography.xSmall.copyWith(
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ),
                        const shad.DensityGap(0.5),
                        Expanded(
                          child: Text(
                            q.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.small.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Cloth: ${q.clothType} • UOM: ${q.unit} • HSN: ${q.hsnCode.isEmpty ? "MISSING" : q.hsnCode} • Sell1: ₹${q.sell1.toStringAsFixed(0)}',
                          style: theme.typography.xSmall.copyWith(
                            color: colors.mutedForeground,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdentityAndBarrelCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. Identity & Barrel Routing (item_group)',
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
          const shad.DensityGap(0.6),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Item Code (item_code) *',
                  child: shad.TextField(
                    controller: _codeCtrl,
                    placeholder: const Text('e.g. PKG-CARTOON'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 7,
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Commercial / Billing Name *',
                  child: shad.TextField(
                    controller: _nameCtrl,
                    placeholder: const Text('e.g. CARTOON (MASTER BOX)'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.5),
          _buildLabeledField(
            theme,
            colors,
            label: 'Description / Invoice Print Sub-Text',
            child: shad.TextField(
              controller: _descCtrl,
              placeholder: const Text('Optional specification notes...'),
              onChanged: (_) => _syncNumericFieldsToDraft(),
            ),
          ),
          const shad.DensityGap(0.6),
          Text(
            'Select Item Group (Barrel — Configured in Admin):',
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const shad.DensityGap(0.4),
          Wrap(
            spacing: 6 * theme.scaling,
            runSpacing: 6 * theme.scaling,
            children: _groupConfigs.map((cfg) {
              final bool isSel = _draft.itemGroup == cfg.groupCode;
              return isSel
                  ? shad.PrimaryButton(
                      size: shad.ButtonSize.small,
                      leading: Icon(cfg.icon, size: 14),
                      onPressed: () => _onGroupChanged(cfg),
                      child: Text(cfg.displayName),
                    )
                  : shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      leading: Icon(cfg.icon, size: 14),
                      onPressed: () => _onGroupChanged(cfg),
                      child: Text(cfg.displayName),
                    );
            }).toList(),
          ),
          const shad.DensityGap(0.6),
          // 4 Transaction Capability Switches
          Wrap(
            spacing: 8 * theme.scaling,
            runSpacing: 6 * theme.scaling,
            children: [
              _buildSwitchChip(
                theme,
                label: 'Can Be Purchased',
                value: _draft.canBePurchased,
                onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(canBePurchased: v),
                ),
              ),
              _buildSwitchChip(
                theme,
                label: 'Internal WIP Rotation',
                value: _draft.isInternal,
                onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(isInternal: v),
                ),
              ),
              _buildSwitchChip(
                theme,
                label: 'Can Be Sold',
                value: _draft.canBeSold,
                onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(canBeSold: v),
                ),
              ),
              _buildSwitchChip(
                theme,
                label: 'Track Stock Ledger',
                value: _draft.isStockTracked,
                onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(isStockTracked: v),
                ),
              ),
            ],
          ),
          if (_draft.allowedSeries.isNotEmpty) ...[
            const shad.DensityGap(0.5),
            Text(
              'Allowed Billing Series: ${_draft.allowedSeries.join(", ")}',
              style: theme.typography.xSmall.copyWith(
                fontFamily: 'JetBrains Mono',
                color: colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplianceAndUomCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;
    final uomChoices = _activeGroupConfig?.allowedUoms.isNotEmpty == true
        ? _activeGroupConfig!.allowedUoms
        : const ['PCS', 'MTS', 'KG', 'ROLL', 'BOX', 'NOS'];

    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2. Statutory Compliance & UOM',
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
          const shad.DensityGap(0.6),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'HSN / SAC Code *',
                  child: shad.TextField(
                    controller: _hsnCtrl,
                    placeholder: const Text('e.g. 540754 / 39239090'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 6,
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'GST Rate (%)',
                  child: Wrap(
                    spacing: 4 * theme.scaling,
                    children: [0.0, 5.0, 12.0, 18.0].map((rate) {
                      final bool isSel = _draft.gstRate == rate;
                      return isSel
                          ? shad.PrimaryButton(
                              size: shad.ButtonSize.small,
                              onPressed: () {},
                              child: Text('${rate.toStringAsFixed(0)}%'),
                            )
                          : shad.OutlineButton(
                              size: shad.ButtonSize.small,
                              onPressed: () => setState(
                                () => _draft = _draft.copyWith(gstRate: rate),
                              ),
                              child: Text('${rate.toStringAsFixed(0)}%'),
                            );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.5),
          Row(
            children: [
              _buildSwitchChip(
                theme,
                label: 'Lock HSN on Bills',
                value: _draft.isHsnLocked,
                onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(isHsnLocked: v),
                ),
              ),
              const shad.DensityGap(0.5),
              _buildSwitchChip(
                theme,
                label: 'Reverse Charge (RCM)',
                value: _draft.isReverseCharge,
                onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(isReverseCharge: v),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.6),
          Text(
            'Primary Unit of Measurement (primary_uom):',
            style: theme.typography.xSmall.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const shad.DensityGap(0.35),
          Wrap(
            spacing: 6 * theme.scaling,
            children: uomChoices.map((u) {
              final bool isSel = _draft.primaryUom == u;
              return isSel
                  ? shad.PrimaryButton(
                      size: shad.ButtonSize.small,
                      onPressed: () {},
                      child: Text(u),
                    )
                  : shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: () => setState(
                        () => _draft = _draft.copyWith(primaryUom: u),
                      ),
                      child: Text(u),
                    );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCostingAndWarehouseCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    final pad = theme.density.baseContainerPadding * theme.scaling * 0.75;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3. Costing, Selling Tiers & Warehouse Reorder',
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
          const shad.DensityGap(0.6),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Standard Cost (₹) *',
                  child: shad.TextField(
                    controller: _costCtrl,
                    placeholder: const Text('0.00'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Last Pur. Rate (₹)',
                  child: shad.TextField(
                    controller: _lastPurCtrl,
                    placeholder: const Text('0.00'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Reorder Level (${_draft.primaryUom})',
                  child: shad.TextField(
                    controller: _reorderCtrl,
                    placeholder: const Text('e.g. 250'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.5),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Sell Price 1 (Catalog ₹)',
                  child: shad.TextField(
                    controller: _sell1Ctrl,
                    placeholder: const Text('0.00'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Sell Price 2 (Wholesale ₹)',
                  child: shad.TextField(
                    controller: _sell2Ctrl,
                    placeholder: const Text('0.00'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Sell Price 3 (Agent ₹)',
                  child: shad.TextField(
                    controller: _sell3Ctrl,
                    placeholder: const Text('0.00'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.5),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Pref. Vendor Code',
                  child: shad.TextField(
                    controller: _vendorCodeCtrl,
                    placeholder: const Text('e.g. V-PACK01'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 7,
                child: _buildLabeledField(
                  theme,
                  colors,
                  label: 'Preferred Supplier Name',
                  child: shad.TextField(
                    controller: _vendorNameCtrl,
                    placeholder: const Text('e.g. Shree Ganesh Packaging'),
                    onChanged: (_) => _syncNumericFieldsToDraft(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
    shad.ThemeData theme,
    shad.ColorScheme colors, {
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.typography.xSmall.copyWith(
            color: colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const shad.DensityGap(0.25),
        child,
      ],
    );
  }

  Widget _buildSwitchChip(
    shad.ThemeData theme, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return shad.Checkbox(
      state: value ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
      onChanged: (st) => onChanged(st == shad.CheckboxState.checked),
      trailing: Text(
        label,
        style: theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

