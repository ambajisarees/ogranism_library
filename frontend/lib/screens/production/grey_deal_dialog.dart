import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:textile_erp/organism_design/index.dart';
import '../../services/service_grey.dart';

class GreyDealAddCanvas extends StatefulWidget {
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const GreyDealAddCanvas({
    super.key,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<GreyDealAddCanvas> createState() => _GreyDealAddCanvasState();
}

class _GreyDealAddCanvasState extends State<GreyDealAddCanvas> {
  final GreyService _service = GreyService();

  // Loading states
  bool _isLoadingLookups = true;
  List<Map<String, String>> _weavers = [];
  List<Map<String, String>> _brokers = [];
  List<String> _qualities = [];

  // Form Field State
  DateTime _dealDate = DateTime.now();
  Map<String, String>? _selectedWeaver;
  Map<String, String>? _selectedBroker;
  String? _selectedQuality;
  List<String> _firmsUnderWeaver = [];
  bool _isLoadingFirms = false;
  String _unit = 'PCS'; // Default to PCS

  double? _pcs;
  double? _mts;
  double? _lots;
  double? _rate;
  double? _disc; // Dhara
  double? _graceDays;
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final weavers = await _service.getWeavers();
      final brokers = await _service.getBrokers();
      // Fetch unique qualities from the cutting service or Masters
      final qualities = await _service.getPurchaseBills(limit: 1000).then((res) {
        return res.data.map((b) => b.qual).toSet().toList();
      });

      if (mounted) {
        setState(() {
          _weavers = weavers;
          _brokers = brokers;
          _qualities = qualities..sort();
          _isLoadingLookups = false;
        });
      }
    } catch (e) {
      print('Error loading lookups for GreyDealAddCanvas: $e');
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_selectedWeaver == null) {
      PlasmaToastManager.instance.show(context, 'Please select a Weaver.', variant: CellBadgeVariant.warning);
      return;
    }
    if (_selectedQuality == null) {
      PlasmaToastManager.instance.show(context, 'Please select a Quality.', variant: CellBadgeVariant.warning);
      return;
    }
    if (_unit == 'PCS' && (_pcs == null || _pcs! <= 0)) {
      PlasmaToastManager.instance.show(context, 'Please enter a valid Pieces count.', variant: CellBadgeVariant.warning);
      return;
    }
    if (_unit == 'MTS' && (_mts == null || _mts! <= 0)) {
      PlasmaToastManager.instance.show(context, 'Please enter a valid Meters length.', variant: CellBadgeVariant.warning);
      return;
    }

    try {
      final payload = {
        'date': _dealDate.toIso8601String(),
        'gcode': _selectedWeaver!['code'],
        'bcode': _selectedBroker?['code'],
        'qual': _selectedQuality,
        'unit': _unit,
        'pcs': _unit == 'PCS' ? _pcs?.toInt() : null,
        'mts': _unit == 'MTS' ? _mts : null,
        'lots': _lots?.toInt(),
        'rate': _rate,
        'disc': _disc,
        'gracedays': _graceDays?.toInt(),
        'rmk': _remarksController.text.trim().isNotEmpty ? _remarksController.text.trim() : null,
      };

      PlasmaToastManager.instance.show(context, 'Creating Grey Deal...', variant: CellBadgeVariant.primary);

      final result = await _service.saveGreyOrder(payload);

      if (mounted) {
        if (result != null && result['success'] == true) {
          PlasmaToastManager.instance.show(
            context,
            'Grey Deal #${result['orderno']} created successfully!',
            variant: CellBadgeVariant.success,
          );
          widget.onSaved();
        } else {
          throw Exception('Backend did not return success.');
        }
      }
    } catch (e) {
      if (mounted) {
        PlasmaToastManager.instance.show(
          context,
          'Failed to save Grey Deal: ${e.toString()}',
          variant: CellBadgeVariant.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLookups) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return OrganAddCanvas(
      title: 'New Grey Deal',
      onClose: () async {
        final confirm = await PlasmaAlertDialog.show(
          context: context,
          title: 'Discard Deal?',
          message: 'You have unsaved changes in this deal form. Are you sure you want to discard them?',
          isDestructive: true,
          confirmText: 'Discard',
        );
        if (confirm == true) {
          widget.onCancel();
        }
      },
      trailingAction: CellButton(
        text: 'Save Deal (Ctrl+S)',
        icon: LucideIcons.check,
        variant: CellButtonVariant.primary,
        onPressed: _handleSave,
      ),
      subHeader: Padding(
        padding: const EdgeInsets.only(bottom: OrganismTheme.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CellLabel(text: 'WEAVER (ANCHOR)'),
                  CellGap.small,
                  CellAutocomplete<Map<String, String>>(
                    isCompact: false,
                    placeholder: 'Search Weaver...',
                    items: _weavers,
                    value: _selectedWeaver,
                    onChanged: (w) async {
                      setState(() {
                        _selectedWeaver = w;
                        _firmsUnderWeaver = [];
                      });
                      if (w != null) {
                        setState(() => _isLoadingFirms = true);
                        final list = await _service.getFirmsForWeaverGroup(w['code'] ?? '');
                        if (mounted) {
                          setState(() {
                            _firmsUnderWeaver = list;
                            _isLoadingFirms = false;
                          });
                        }
                      }
                    },
                    labelBuilder: (w) => w['name']!,
                  ),
                  if (_selectedWeaver != null) ...[
                    CellGap.small,
                    if (_isLoadingFirms)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_firmsUnderWeaver.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _firmsUnderWeaver.map((firm) => CellBadge(
                          text: firm,
                          variant: CellBadgeVariant.secondary,
                        )).toList(),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: OrganismTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CellLabel(text: 'BROKER'),
                  CellGap.small,
                  CellAutocomplete<Map<String, String>>(
                    isCompact: false,
                    placeholder: 'Search Broker...',
                    items: _brokers,
                    value: _selectedBroker,
                    onChanged: (b) => setState(() => _selectedBroker = b),
                    labelBuilder: (b) => b['name']!,
                  ),
                ],
              ),
            ),
            const SizedBox(width: OrganismTheme.spacingMd),
            Expanded(
              child: TissueDateField(
                label: 'DEAL DATE',
                value: _dealDate,
                onChanged: (d) => setState(() => _dealDate = d),
              ),
            ),
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(OrganismTheme.spacingLg),
          child: Focus(
            autofocus: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('FABRIC DETAILS', style: OrganismTheme.titleMedium(context)),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CellLabel(text: 'FABRIC QUALITY'),
                          CellGap.small,
                          CellAutocomplete<String>(
                            isCompact: false,
                            placeholder: 'Search Quality...',
                            items: _qualities,
                            value: _selectedQuality,
                            onChanged: (q) => setState(() => _selectedQuality = q),
                            labelBuilder: (q) => q,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CellLabel(text: 'ORDERING UNIT'),
                          CellGap.small,
                          CellToggleGroup<String>(
                            value: _unit,
                            items: const ['PCS', 'MTS'],
                            itemBuilder: (v) => Text(v),
                            onChanged: (v) {
                              setState(() {
                                _unit = v;
                                // Clear other field
                                if (_unit == 'PCS') _mts = null;
                                if (_unit == 'MTS') _pcs = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OrganismTheme.spacingLg),
                Row(
                  children: [
                    if (_unit == 'PCS')
                      Expanded(
                        child: TissueFormField(
                          label: 'ORDERED PIECES',
                          inputCell: CellInputNumber(
                            initialValue: _pcs,
                            decimals: 0,
                            placeholder: 'e.g. 500',
                            onChanged: (v) => setState(() => _pcs = v),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: TissueFormField(
                          label: 'ORDERED METERS',
                          inputCell: CellInputNumber(
                            initialValue: _mts,
                            decimals: 2,
                            placeholder: 'e.g. 2500.00',
                            onChanged: (v) => setState(() => _mts = v),
                          ),
                        ),
                      ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: TissueFormField(
                        label: 'NUMBER OF LOADS (LOTS)',
                        inputCell: CellInputNumber(
                          initialValue: _lots,
                          decimals: 0,
                          placeholder: 'e.g. 2',
                          onChanged: (v) => setState(() => _lots = v),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OrganismTheme.spacingLg),
                const CellDivider(),
                const SizedBox(height: OrganismTheme.spacingLg),
                Text('FINANCIAL TERMS', style: OrganismTheme.titleMedium(context)),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: TissueFormField(
                        label: 'DEAL RATE',
                        inputCell: CellInputNumber(
                          initialValue: _rate,
                          decimals: 2,
                          placeholder: '₹ e.g. 42.50',
                          onChanged: (v) => setState(() => _rate = v),
                        ),
                      ),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: TissueFormField(
                        label: 'DHARA (DISCOUNT %)',
                        inputCell: CellInputNumber(
                          initialValue: _disc,
                          decimals: 2,
                          placeholder: '% e.g. 2.00',
                          onChanged: (v) => setState(() => _disc = v),
                        ),
                      ),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    Expanded(
                      child: TissueFormField(
                        label: 'GRACE DAYS',
                        inputCell: CellInputNumber(
                          initialValue: _graceDays,
                          decimals: 0,
                          placeholder: 'Days e.g. 30',
                          onChanged: (v) => setState(() => _graceDays = v),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OrganismTheme.spacingLg),
                TissueFormField(
                  label: 'REMARKS / SPECIAL INSTR.',
                  inputCell: CellInput(
                    controller: _remarksController,
                    placeholder: 'Enter any remarks here...',
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
