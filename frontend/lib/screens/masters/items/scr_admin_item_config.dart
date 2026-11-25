/*
================================================================================
LLM CONTEXT & QUERY SPACE — ADMIN ITEM BARREL & SCHEMA CONFIG (scr_admin_item_config.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Admin-only Governance Screen (`screens/admin/item_config/`) for configuring
     `IMMBE2627.sb_item_group_config`.
   - Allows Admins to create/edit Item Barrels (`item_group`), lock default
     transaction capability switches (`can_be_purchased`, `is_internal`,
     `can_be_sold`, `is_stock_tracked`), define `allowed_series` and
     `allowed_uoms`, and customize the dynamic `spec_schema` fields & completion
     ratio weights (`score_pts`) for each item group.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Normal users on the Items page cannot alter barrel definitions or schema
     rules; they consume the blueprints configured here.
   - Uses pure native `shadcn_flutter` components (`shad.OutlinedContainer`,
     `shad.Button`, `shad.TextField`, `shad.Checkbox`, `shad.PrimaryBadge`,
     `shad.SecondaryBadge`, `shad.DensityGap`) and theme tokens.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Persists directly to `IMMBE2627.sb_item_group_config`.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/masters/items/mdl_sb_item.dart';
import '../../../services/masters/items/srv_sb_item.dart';

/// Opens the [ScrAdminItemConfig] inside a native `shad.showOverlay` modal.
Future<void> showAdminItemConfigModal(BuildContext context) async {
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(
      barrierDismissible: true,
    ),
    builder: (overlayCtx) {
      return Center(
        child: SizedBox(
          width: 1080,
          height: 760,
          child: ScrAdminItemConfig(
            onClose: () => shad.closeOverlay(overlayCtx),
          ),
        ),
      );
    },
  );
  await completer.future;
}

/// [ScrAdminItemConfig] — Admin Barrel & Domain Spec Blueprint Editor.
class ScrAdminItemConfig extends StatefulWidget {
  final VoidCallback? onClose;

  const ScrAdminItemConfig({
    super.key,
    this.onClose,
  });

  @override
  State<ScrAdminItemConfig> createState() => _ScrAdminItemConfigState();
}

class _ScrAdminItemConfigState extends State<ScrAdminItemConfig> {
  final SrvSbItem _srv = SrvSbItem();

  List<SbItemGroupConfig> _configs = [];
  SbItemGroupConfig? _selected;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _statusMsg;
  bool _isError = false;

  // Controllers for selected barrel
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _seriesCtrl = TextEditingController();
  final TextEditingController _uomsCtrl = TextEditingController();
  final TextEditingController _hsnCtrl = TextEditingController();
  final TextEditingController _gstCtrl = TextEditingController();

  // Controllers for adding a new dynamic spec field to spec_schema
  final TextEditingController _newFieldKeyCtrl = TextEditingController();
  final TextEditingController _newFieldLabelCtrl = TextEditingController();
  final TextEditingController _newFieldOptsCtrl = TextEditingController();
  final TextEditingController _newFieldPtsCtrl = TextEditingController(text: '5');
  final String _newFieldType = 'text';
  final bool _newFieldReq = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _seriesCtrl.dispose();
    _uomsCtrl.dispose();
    _hsnCtrl.dispose();
    _gstCtrl.dispose();
    _newFieldKeyCtrl.dispose();
    _newFieldLabelCtrl.dispose();
    _newFieldOptsCtrl.dispose();
    _newFieldPtsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
    });
    final list = await _srv.getGroupConfigs(activeOnly: false);
    if (!mounted) return;
    setState(() {
      _configs = list;
      _isLoading = false;
      if (list.isNotEmpty) {
        _selectConfig(_selected != null
            ? list.firstWhere(
                (c) => c.groupCode == _selected!.groupCode,
                orElse: () => list.first,
              )
            : list.first);
      }
    });
  }

  void _selectConfig(SbItemGroupConfig cfg) {
    setState(() {
      _selected = cfg;
      _statusMsg = null;
    });
    _codeCtrl.text = cfg.groupCode;
    _nameCtrl.text = cfg.displayName;
    _descCtrl.text = cfg.description;
    _seriesCtrl.text = cfg.allowedSeries.join(', ');
    _uomsCtrl.text = cfg.allowedUoms.join(', ');
    _hsnCtrl.text = cfg.defaultHsn;
    _gstCtrl.text = cfg.defaultGstRate.toStringAsFixed(1);
  }

  void _startNewBarrel() {
    const draft = SbItemGroupConfig(
      groupCode: 'NEW_BARREL',
      displayName: 'New Item Barrel',
      description: 'Custom admin-defined item group',
      defaultNature: 'GOODS',
      allowedSeries: ['P4'],
      allowedUoms: ['PCS', 'MTS', 'KG'],
      defaultHsn: '5407',
      defaultGstRate: 5.0,
    );
    _selectConfig(draft);
  }

  void _addSpecField() {
    if (_selected == null) return;
    final key = _newFieldKeyCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
    final label = _newFieldLabelCtrl.text.trim();
    if (key.isEmpty || label.isEmpty) return;

    final List<String> opts = _newFieldOptsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final int pts = int.tryParse(_newFieldPtsCtrl.text.trim()) ?? 5;

    final newField = SbSpecFieldDef(
      key: key,
      label: label,
      type: opts.isNotEmpty ? 'select' : _newFieldType,
      options: opts,
      required: _newFieldReq,
      scorePts: pts,
    );

    setState(() {
      _selected = _selected!.copyWith(
        specSchema: [..._selected!.specSchema, newField],
      );
      _newFieldKeyCtrl.clear();
      _newFieldLabelCtrl.clear();
      _newFieldOptsCtrl.clear();
      _newFieldPtsCtrl.text = '5';
    });
  }

  void _removeSpecFieldAt(int idx) {
    if (_selected == null) return;
    final updated = List<SbSpecFieldDef>.from(_selected!.specSchema)
      ..removeAt(idx);
    setState(() {
      _selected = _selected!.copyWith(specSchema: updated);
    });
  }

  Future<void> _saveCurrentBarrel() async {
    if (_selected == null) return;
    final String code =
        _codeCtrl.text.trim().toUpperCase().replaceAll(' ', '_');
    final String name = _nameCtrl.text.trim();
    if (code.isEmpty || name.isEmpty) {
      setState(() {
        _isError = true;
        _statusMsg = 'Group Code and Display Name cannot be empty.';
      });
      return;
    }

    final List<String> series = _seriesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final List<String> uoms = _uomsCtrl.text
        .split(',')
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();
    final double gst = double.tryParse(_gstCtrl.text.trim()) ?? 5.0;

    final updated = _selected!.copyWith(
      groupCode: code,
      displayName: name,
      description: _descCtrl.text.trim(),
      allowedSeries: series,
      allowedUoms: uoms.isEmpty ? const ['PCS'] : uoms,
      defaultHsn: _hsnCtrl.text.trim(),
      defaultGstRate: gst,
    );

    setState(() {
      _isSaving = true;
      _statusMsg = null;
    });

    final res = await _srv.upsertGroupConfig(updated);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isError = !res.success;
      _statusMsg = res.success
          ? 'Saved Barrel Blueprint "$code" to IMMBE2627.sb_item_group_config!'
          : (res.error ?? 'Failed to save config.');
    });

    if (res.success) {
      await _loadConfigs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    return shad.OutlinedContainer(
      backgroundColor: colors.background,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusLg,
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TOP BAR
          Row(
            children: [
              Icon(
                shad.LucideIcons.shieldCheck,
                size: 20 * theme.scaling,
                color: colors.primary,
              ),
              const shad.DensityGap(0.6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Governance: Item Barrels & Domain Specs Schema',
                      style: theme.typography.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),
                    Text(
                      'Configure item_group barrels, default transaction switches, allowed billing series, and required domain_specs for completion scoring.',
                      style: theme.typography.xSmall.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              shad.OutlineButton(
                size: shad.ButtonSize.small,
                leading: const Icon(shad.LucideIcons.plus, size: 14),
                onPressed: _startNewBarrel,
                child: const Text('New Barrel Group'),
              ),
              if (widget.onClose != null) ...[
                const shad.DensityGap(0.5),
                shad.GhostButton(
                  density: shad.ButtonDensity.icon,
                  onPressed: widget.onClose,
                  child: const Icon(shad.LucideIcons.x, size: 16),
                ),
              ],
            ],
          ),
          const shad.DensityGap(0.75),
          const shad.Divider(),
          const shad.DensityGap(0.75),

          // MAIN SPLIT BODY
          Expanded(
            child: _isLoading
                ? const Center(child: shad.CircularProgressIndicator())
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT SIDEBAR: List of Barrels
                      SizedBox(
                        width: 270 * theme.scaling,
                        child: shad.OutlinedContainer(
                          padding: EdgeInsets.all(pad * 0.6),
                          backgroundColor: colors.card,
                          borderColor: colors.border,
                          borderRadius: theme.borderRadiusMd,
                          child: ListView.separated(
                            itemCount: _configs.length,
                            separatorBuilder: (ctx, idx) =>
                                const shad.DensityGap(0.35),
                            itemBuilder: (ctx, i) {
                              final c = _configs[i];
                              final bool isSel =
                                  _selected?.groupCode == c.groupCode;
                              return isSel
                                  ? shad.PrimaryButton(
                                      alignment: Alignment.centerLeft,
                                      leading: Icon(c.icon, size: 15),
                                      onPressed: () => _selectConfig(c),
                                      child: Expanded(
                                        child: Text(
                                          c.displayName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  : shad.OutlineButton(
                                      alignment: Alignment.centerLeft,
                                      leading: Icon(c.icon, size: 15),
                                      onPressed: () => _selectConfig(c),
                                      child: Expanded(
                                        child: Text(
                                          c.displayName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
                      const shad.DensityGap(0.75),

                      // RIGHT EDITOR PANE
                      Expanded(
                        child: _selected == null
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildBarrelCoreEditor(theme, colors, pad),
                                    const shad.DensityGap(0.75),
                                    _buildSpecSchemaEditor(theme, colors, pad),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
          ),

          const shad.DensityGap(0.75),

          // BOTTOM FOOTER
          Row(
            children: [
              if (_statusMsg != null)
                Expanded(
                  child: Text(
                    _statusMsg!,
                    style: theme.typography.small.copyWith(
                      color: _isError ? colors.destructive : colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (widget.onClose != null) ...[
                shad.OutlineButton(
                  onPressed: widget.onClose,
                  child: const Text('Close'),
                ),
                const shad.DensityGap(0.5),
              ],
              shad.PrimaryButton(
                onPressed: _isSaving ? null : _saveCurrentBarrel,
                leading: const Icon(shad.LucideIcons.save, size: 15),
                child: const Text('Save Barrel Blueprint'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarrelCoreEditor(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) {
    final s = _selected!;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad * 0.75),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Barrel Governance & Default Capability Locks',
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
                child: _buildField(
                  theme,
                  colors,
                  'Barrel Code (group_code)',
                  shad.TextField(controller: _codeCtrl),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 6,
                child: _buildField(
                  theme,
                  colors,
                  'Display Name',
                  shad.TextField(controller: _nameCtrl),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 4,
                child: _buildField(
                  theme,
                  colors,
                  'Item Nature',
                  Wrap(
                    spacing: 4 * theme.scaling,
                    children: ['GOODS', 'CONSUMABLE', 'SERVICE'].map((nat) {
                      final bool isSel = s.defaultNature == nat;
                      return isSel
                          ? shad.PrimaryButton(
                              size: shad.ButtonSize.small,
                              onPressed: () {},
                              child: Text(nat),
                            )
                          : shad.OutlineButton(
                              size: shad.ButtonSize.small,
                              onPressed: () => setState(
                                () => _selected =
                                    s.copyWith(defaultNature: nat),
                              ),
                              child: Text(nat),
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
              Expanded(
                flex: 5,
                child: _buildField(
                  theme,
                  colors,
                  'Allowed Billing Series (comma-separated)',
                  shad.TextField(
                    controller: _seriesCtrl,
                    placeholder: const Text('e.g. P4, O15, S3'),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 4,
                child: _buildField(
                  theme,
                  colors,
                  'Allowed UOMs',
                  shad.TextField(
                    controller: _uomsCtrl,
                    placeholder: const Text('e.g. PCS, MTS, KG'),
                  ),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 3,
                child: _buildField(
                  theme,
                  colors,
                  'Default HSN',
                  shad.TextField(controller: _hsnCtrl),
                ),
              ),
              const shad.DensityGap(0.5),
              Expanded(
                flex: 2,
                child: _buildField(
                  theme,
                  colors,
                  'Default GST %',
                  shad.TextField(controller: _gstCtrl),
                ),
              ),
            ],
          ),
          const shad.DensityGap(0.6),
          Wrap(
            spacing: 12 * theme.scaling,
            runSpacing: 6 * theme.scaling,
            children: [
              shad.Checkbox(
                state: s.canBePurchased
                    ? shad.CheckboxState.checked
                    : shad.CheckboxState.unchecked,
                onChanged: (st) => setState(
                  () => _selected = s.copyWith(
                    canBePurchased: st == shad.CheckboxState.checked,
                  ),
                ),
                trailing: const Text('Default: Can Be Purchased'),
              ),
              shad.Checkbox(
                state: s.isInternal
                    ? shad.CheckboxState.checked
                    : shad.CheckboxState.unchecked,
                onChanged: (st) => setState(
                  () => _selected = s.copyWith(
                    isInternal: st == shad.CheckboxState.checked,
                  ),
                ),
                trailing: const Text('Default: Internal WIP'),
              ),
              shad.Checkbox(
                state: s.canBeSold
                    ? shad.CheckboxState.checked
                    : shad.CheckboxState.unchecked,
                onChanged: (st) => setState(
                  () => _selected = s.copyWith(
                    canBeSold: st == shad.CheckboxState.checked,
                  ),
                ),
                trailing: const Text('Default: Can Be Sold'),
              ),
              shad.Checkbox(
                state: s.isStockTracked
                    ? shad.CheckboxState.checked
                    : shad.CheckboxState.unchecked,
                onChanged: (st) => setState(
                  () => _selected = s.copyWith(
                    isStockTracked: st == shad.CheckboxState.checked,
                  ),
                ),
                trailing: const Text('Default: Track Stock Ledger'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecSchemaEditor(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double pad,
  ) {
    final s = _selected!;
    return shad.OutlinedContainer(
      padding: EdgeInsets.all(pad * 0.75),
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dynamic Domain Specs Schema (spec_schema JSONB for ${s.groupCode})',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
              ),
              shad.SecondaryBadge(
                child: Text('${s.specSchema.length} Spec Fields Configured'),
              ),
            ],
          ),
          const shad.DensityGap(0.5),
          // Add New Spec Field Bar
          Row(
            children: [
              Expanded(
                flex: 3,
                child: shad.TextField(
                  controller: _newFieldKeyCtrl,
                  placeholder: const Text('JSON key (e.g. cut_mtr)'),
                ),
              ),
              const shad.DensityGap(0.35),
              Expanded(
                flex: 4,
                child: shad.TextField(
                  controller: _newFieldLabelCtrl,
                  placeholder: const Text('UI Label (e.g. Standard Cut Mtr)'),
                ),
              ),
              const shad.DensityGap(0.35),
              Expanded(
                flex: 5,
                child: shad.TextField(
                  controller: _newFieldOptsCtrl,
                  placeholder: const Text(
                    'Dropdown Options (comma-sep, optional)',
                  ),
                ),
              ),
              const shad.DensityGap(0.35),
              SizedBox(
                width: 65 * theme.scaling,
                child: shad.TextField(
                  controller: _newFieldPtsCtrl,
                  placeholder: const Text('Pts'),
                ),
              ),
              const shad.DensityGap(0.35),
              shad.PrimaryButton(
                size: shad.ButtonSize.small,
                onPressed: _addSpecField,
                leading: const Icon(shad.LucideIcons.plus, size: 14),
                child: const Text('Add Field'),
              ),
            ],
          ),
          const shad.DensityGap(0.6),
          ...s.specSchema.asMap().entries.map((entry) {
            final idx = entry.key;
            final f = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 6 * theme.scaling),
              child: shad.OutlinedContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * theme.scaling,
                  vertical: 6 * theme.scaling,
                ),
                backgroundColor: colors.background,
                borderColor: colors.border,
                borderRadius: theme.borderRadiusSm,
                child: Row(
                  children: [
                    shad.PrimaryBadge(
                      child: Text(
                        f.key,
                        style: theme.typography.xSmall.copyWith(
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ),
                    const shad.DensityGap(0.5),
                    Expanded(
                      child: Text(
                        '${f.label} (${f.type}${f.options.isNotEmpty ? ": ${f.options.join("/")}" : ""})',
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    shad.SecondaryBadge(
                      child: Text(
                        f.required
                            ? 'Required • ${f.scorePts} pts'
                            : 'Optional • ${f.scorePts} pts',
                      ),
                    ),
                    const shad.DensityGap(0.5),
                    shad.GhostButton(
                      density: shad.ButtonDensity.icon,
                      onPressed: () => _removeSpecFieldAt(idx),
                      child: const Icon(shad.LucideIcons.trash2, size: 14),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildField(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    String label,
    Widget child,
  ) {
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
}

