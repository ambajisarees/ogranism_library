import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/production/model_recipe_mill.dart';
import '../../../../services/production/service_recipe_mill.dart';

/// Quick modal dialog for adding or editing a single Mill Printing Recipe record.
class MillRecipeEntryDialog extends StatefulWidget {
  final MillRecipeModel? initialRecipe;
  final List<Map<String, String>> mills;
  final List<Map<String, String>> fabrics;

  const MillRecipeEntryDialog({
    super.key,
    this.initialRecipe,
    required this.mills,
    required this.fabrics,
  });

  static Future<MillRecipeModel?> show(
    BuildContext context, {
    MillRecipeModel? initialRecipe,
    required List<Map<String, String>> mills,
    required List<Map<String, String>> fabrics,
  }) {
    return showDialog<MillRecipeModel>(
      context: context,
      builder: (context) => MillRecipeEntryDialog(
        initialRecipe: initialRecipe,
        mills: mills,
        fabrics: fabrics,
      ),
    );
  }

  @override
  State<MillRecipeEntryDialog> createState() => _MillRecipeEntryDialogState();
}

class _MillRecipeEntryDialogState extends State<MillRecipeEntryDialog> {
  late String _selectedMillCode;
  late String _selectedMillName;
  late String _selectedFabricCode;
  late String _selectedFabricName;
  late String _printType;
  late String _valueType;
  late TextEditingController _rateController;
  late TextEditingController _remarksController;
  late DateTime _effectiveDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecipe;
    _selectedMillCode = r?.millCode ?? (widget.mills.isNotEmpty ? widget.mills.first['code']! : 'M001');
    _selectedMillName = r?.millName ?? (widget.mills.isNotEmpty ? widget.mills.first['name']! : 'Ambaji Mill Prints');
    _selectedFabricCode = r?.fabricCode ?? (widget.fabrics.isNotEmpty ? widget.fabrics.first['code']! : 'Q001');
    _selectedFabricName = r?.fabricName ?? (widget.fabrics.isNotEmpty ? widget.fabrics.first['name']! : '60x60 Cotton Satin');
    _printType = r?.printType ?? RecipeMillService.standardPrintTypes.first;
    _valueType = r?.valueType ?? RecipeMillService.standardValueTypes.first;
    _rateController = TextEditingController(text: r != null ? r.rate.toString() : '');
    _remarksController = TextEditingController(text: r?.remarks ?? '');
    _effectiveDate = r?.effectiveDate ?? DateTime.now();
    _isActive = r?.isActive ?? true;
  }

  @override
  void dispose() {
    _rateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onSave() {
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    if (rate <= 0) {
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Please enter a valid positive rate.'),
          ),
        ),
      );
      return;
    }

    final recipe = MillRecipeModel(
      id: widget.initialRecipe?.id ?? '',
      millCode: _selectedMillCode,
      millName: _selectedMillName,
      fabricCode: _selectedFabricCode,
      fabricName: _selectedFabricName,
      printType: _printType,
      valueType: _valueType,
      rate: rate,
      effectiveDate: _effectiveDate,
      isActive: _isActive,
      remarks: _remarksController.text.isNotEmpty ? _remarksController.text : null,
    );

    Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Text(
        widget.initialRecipe == null ? 'New Mill Rate Revision' : 'Edit Rate Recipe',
        style: theme.typography.h3.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mill Selector
              Text('Processing Mill', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  border: Border.all(color: colors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMillCode,
                    isExpanded: true,
                    dropdownColor: colors.card,
                    items: widget.mills.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['code']!,
                        child: Text(m['name']!, style: theme.typography.textSmall),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = widget.mills.firstWhere((m) => m['code'] == val);
                        setState(() {
                          _selectedMillCode = found['code']!;
                          _selectedMillName = found['name']!;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Fabric Selector
              Text('Fabric / Quality', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  border: Border.all(color: colors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFabricCode,
                    isExpanded: true,
                    dropdownColor: colors.card,
                    items: widget.fabrics.map((f) {
                      return DropdownMenuItem<String>(
                        value: f['code']!,
                        child: Text(f['name']!, style: theme.typography.textSmall),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = widget.fabrics.firstWhere((f) => f['code'] == val);
                        setState(() {
                          _selectedFabricCode = found['code']!;
                          _selectedFabricName = found['name']!;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Print Type & Value Type Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Print Type', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                            border: Border.all(color: colors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _printType,
                              isExpanded: true,
                              dropdownColor: colors.card,
                              items: RecipeMillService.standardPrintTypes.map((t) {
                                return DropdownMenuItem<String>(
                                  value: t,
                                  child: Text(t, style: theme.typography.textSmall),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _printType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Value Type / Process', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                            border: Border.all(color: colors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _valueType,
                              isExpanded: true,
                              dropdownColor: colors.card,
                              items: RecipeMillService.standardValueTypes.map((v) {
                                return DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v, style: theme.typography.textSmall),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _valueType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rate & Effective Date Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rate (₹ per meter)', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        shad.TextField(
                          controller: _rateController,
                          placeholder: const Text('e.g. 45.50'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Effective Date', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        shad.OutlineButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _effectiveDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _effectiveDate = picked);
                            }
                          },
                          child: Text(
                            _effectiveDate.toIso8601String().split('T').first,
                            style: theme.typography.xSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Remarks
              Text('Remarks / Notes', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              shad.TextField(
                controller: _remarksController,
                placeholder: const Text('Optional notes or rate revision reference...'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        shad.GhostButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        shad.PrimaryButton(
          onPressed: _onSave,
          child: const Text('Save Recipe'),
        ),
      ],
    );
  }
}
