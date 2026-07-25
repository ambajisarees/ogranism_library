import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/model_recipe_mill.dart';

/// Right Content Card in the 2-Pane layout showing Rate History & Interactive Editing.
/// Includes top-level toggle button switching between Display Mode and Edit Mode.
class MillRecipeContentCard extends StatefulWidget {
  final MillRecipeGroupModel? selectedGroup;
  final List<MillRecipeModel> recipes;
  final ValueChanged<List<MillRecipeModel>> onSaveRecipes;
  final ValueChanged<String> onDeleteRecipe;
  final bool isLoading;

  const MillRecipeContentCard({
    super.key,
    required this.selectedGroup,
    required this.recipes,
    required this.onSaveRecipes,
    required this.onDeleteRecipe,
    this.isLoading = false,
  });

  @override
  State<MillRecipeContentCard> createState() => _MillRecipeContentCardState();
}

class _MillRecipeContentCardState extends State<MillRecipeContentCard> {
  bool _isEditMode = false;
  late List<MillRecipeModel> _editableRecipes;
  String _selectedFabricFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initEditableRecipes();
  }

  @override
  void didUpdateWidget(covariant MillRecipeContentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipes != widget.recipes ||
        oldWidget.selectedGroup != widget.selectedGroup) {
      _initEditableRecipes();
    }
  }

  void _initEditableRecipes() {
    _editableRecipes = widget.recipes.map((r) => r.copyWith()).toList();
  }

  void _addNewRow() {
    if (widget.selectedGroup == null) return;
    setState(() {
      _editableRecipes.insert(
        0,
        MillRecipeModel(
          id: '',
          millCode: widget.selectedGroup!.millCode,
          millName: widget.selectedGroup!.millName,
          fabricCode: 'Q001',
          fabricName: '60x60 Cotton Satin',
          printType: 'Overprint',
          valueType: 'Ink',
          rate: 0.0,
          effectiveDate: DateTime.now(),
          isActive: true,
        ),
      );
    });
  }

  void _removeRow(int index) {
    final recipe = _editableRecipes[index];
    if (recipe.id.isNotEmpty) {
      widget.onDeleteRecipe(recipe.id);
    }
    setState(() {
      _editableRecipes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    if (widget.selectedGroup == null) {
      return shad.Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shad.LucideIcons.building,
                  size: 48, color: colors.mutedForeground.withAlpha(100)),
              const SizedBox(height: 12),
              Text(
                'Select a Mill to view or edit rate recipes',
                style: theme.typography.textSmall
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
      );
    }

    // Filter displayed recipes by fabric if applicable
    final displayList = _isEditMode ? _editableRecipes : widget.recipes;
    final filteredList = _selectedFabricFilter == 'All'
        ? displayList
        : displayList
            .where((r) => r.fabricName == _selectedFabricFilter)
            .toList();

    // Unique fabric options for filter
    final fabricOptions = ['All', ...displayList.map((r) => r.fabricName).toSet()];

    return shad.Card(
      child: Padding(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Workspace Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.selectedGroup!.millName,
                          style: theme.typography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        shad.OutlineBadge(
                          child: Text('Code: ${widget.selectedGroup!.millCode}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rate revision history & job work pricing table',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),

                // Action Controls: Mode Switcher & Save Button
                Row(
                  children: [
                    if (_isEditMode) ...[
                      shad.OutlineButton(
                        onPressed: _addNewRow,
                        child: const Row(
                          children: [
                            Icon(shad.LucideIcons.plus, size: 14),
                            SizedBox(width: 4),
                            Text('Add Rate Row'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      shad.PrimaryButton(
                        onPressed: () {
                          widget.onSaveRecipes(_editableRecipes);
                          setState(() => _isEditMode = false);
                        },
                        child: const Row(
                          children: [
                            Icon(shad.LucideIcons.check, size: 14),
                            SizedBox(width: 4),
                            Text('Save Changes'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Mode Switcher Toggle Button
                    shad.SecondaryButton(
                      onPressed: () {
                        setState(() {
                          _isEditMode = !_isEditMode;
                          if (_isEditMode) _initEditableRecipes();
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            _isEditMode
                                ? shad.LucideIcons.eye
                                : shad.LucideIcons.pencil,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(_isEditMode ? 'Display Mode' : 'Edit Mode'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const shad.Divider(),
            const SizedBox(height: 8),

            // Fabric Filter Chips & Mode Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter Fabric: ',
                      style: theme.typography.xSmall
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Wrap(
                      spacing: 6,
                      children: fabricOptions.map((fabric) {
                        final isSelected = _selectedFabricFilter == fabric;
                        return shad.GhostButton(
                          onPressed: () =>
                              setState(() => _selectedFabricFilter = fabric),
                          child: Text(
                            fabric,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? colors.primary
                                  : colors.mutedForeground,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                _isEditMode
                    ? const shad.DestructiveBadge(
                        child: Text(
                          'EDITING ACTIVE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const shad.SecondaryBadge(
                        child: Text(
                          'READ ONLY',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Table (Display Mode vs Edit Mode)
            Expanded(
              child: widget.isLoading
                  ? const Center(child: shad.CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? Center(
                          child: Text(
                            'No rate entries for this fabric filter.',
                            style: theme.typography.xSmall
                                .copyWith(color: colors.mutedForeground),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(110), // Date
                              1: FlexColumnWidth(1.2), // Fabric
                              2: FlexColumnWidth(1.0), // Print Type
                              3: FlexColumnWidth(1.0), // Value Type
                              4: FixedColumnWidth(100), // Rate (₹)
                              5: FixedColumnWidth(90),  // Status
                              6: FixedColumnWidth(60),  // Actions
                            },
                            border: TableBorder.all(
                              color: colors.border,
                              width: 1.0,
                              borderRadius: BorderRadius.circular(theme.radiusMd),
                            ),
                            children: [
                              // Table Header Row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: colors.muted.withAlpha(80),
                                ),
                                children: [
                                  _buildHeaderCell(context, 'Effective Date'),
                                  _buildHeaderCell(context, 'Fabric / Quality'),
                                  _buildHeaderCell(context, 'Print Type'),
                                  _buildHeaderCell(context, 'Value Type'),
                                  _buildHeaderCell(context, 'Rate (₹/m)'),
                                  _buildHeaderCell(context, 'Status'),
                                  _buildHeaderCell(context, 'Actions'),
                                ],
                              ),

                              // Table Data Rows
                              for (int i = 0; i < filteredList.length; i++)
                                _isEditMode
                                    ? _buildEditRow(context, i, filteredList[i])
                                    : _buildDisplayRow(context, filteredList[i], dateFormat),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Text(
        text,
        style: theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.foreground,
        ),
      ),
    );
  }

  TableRow _buildDisplayRow(
      BuildContext context, MillRecipeModel recipe, DateFormat dateFormat) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dateFormat.format(recipe.effectiveDate),
            style: theme.typography.xSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            recipe.fabricName,
            style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            recipe.printType,
            style: theme.typography.xSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            recipe.valueType,
            style: theme.typography.xSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '₹${recipe.rate.toStringAsFixed(2)}',
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: recipe.isActive
              ? const shad.PrimaryBadge(
                  child: Text('Active', style: TextStyle(fontSize: 10)),
                )
              : const shad.SecondaryBadge(
                  child: Text('Archived', style: TextStyle(fontSize: 10)),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.GhostButton(
            onPressed: () => widget.onDeleteRecipe(recipe.id),
            child: const Icon(shad.LucideIcons.trash2, size: 14, color: Colors.red),
          ),
        ),
      ],
    );
  }

  TableRow _buildEditRow(
      BuildContext context, int index, MillRecipeModel recipe) {
    return TableRow(
      children: [
        // Date Input
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.TextField(
            initialValue: recipe.effectiveDate.toIso8601String().split('T').first,
            onChanged: (val) {
              final d = DateTime.tryParse(val);
              if (d != null) {
                _editableRecipes[index] = recipe.copyWith(effectiveDate: d);
              }
            },
          ),
        ),
        // Fabric Input
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.TextField(
            initialValue: recipe.fabricName,
            onChanged: (val) {
              _editableRecipes[index] = recipe.copyWith(fabricName: val);
            },
          ),
        ),
        // Print Type Input
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.TextField(
            initialValue: recipe.printType,
            onChanged: (val) {
              _editableRecipes[index] = recipe.copyWith(printType: val);
            },
          ),
        ),
        // Value Type Input
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.TextField(
            initialValue: recipe.valueType,
            onChanged: (val) {
              _editableRecipes[index] = recipe.copyWith(valueType: val);
            },
          ),
        ),
        // Rate Input
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.TextField(
            initialValue: recipe.rate.toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final r = double.tryParse(val) ?? 0.0;
              _editableRecipes[index] = recipe.copyWith(rate: r);
            },
          ),
        ),
        // Status Checkbox
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: shad.Checkbox(
            state: recipe.isActive
                ? shad.CheckboxState.checked
                : shad.CheckboxState.unchecked,
            onChanged: (state) {
              setState(() {
                _editableRecipes[index] =
                    recipe.copyWith(isActive: state == shad.CheckboxState.checked);
              });
            },
          ),
        ),
        // Action Delete
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: shad.GhostButton(
            onPressed: () => _removeRow(index),
            child: const Icon(shad.LucideIcons.trash2, size: 14, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
