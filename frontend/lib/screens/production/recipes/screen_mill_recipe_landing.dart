import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../models/production/model_recipe_mill.dart';
import '../../../services/production/service_recipe_mill.dart';
import 'widgets/recipe_metric_cards.dart';
import 'widgets/recipe_list_pane.dart';
import 'widgets/recipe_content_card.dart';
import 'widgets/recipe_matrix_view.dart';
import 'widgets/recipe_entry_dialog.dart';

/// Screen workspace for Mill Printing Job Work Recipes (`sb_recipe_mill`).
class ScreenMillRecipeLanding extends StatefulWidget {
  const ScreenMillRecipeLanding({super.key});

  @override
  State<ScreenMillRecipeLanding> createState() =>
      _ScreenMillRecipeLandingState();
}

class _ScreenMillRecipeLandingState extends State<ScreenMillRecipeLanding> {
  final RecipeMillService _service = RecipeMillService();
  final TextEditingController _searchController = TextEditingController();

  MillRecipeMetricsModel _metrics = const MillRecipeMetricsModel();
  List<MillRecipeGroupModel> _millGroups = [];
  MillRecipeGroupModel? _selectedGroup;
  List<MillRecipeModel> _selectedGroupRecipes = [];

  List<Map<String, String>> _millOptions = [];
  List<Map<String, String>> _fabricOptions = [];

  bool _isLoading = true;
  bool _isMatrixView = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    final metrics = await _service.getMetrics();
    final groups = await _service.getMillGroups(
      searchQuery: _searchController.text,
    );
    final mills = await _service.getMillOptions();
    final fabrics = await _service.getFabricOptions();

    if (!mounted) return;

    setState(() {
      _metrics = metrics;
      _millGroups = groups;
      _millOptions = mills;
      _fabricOptions = fabrics;

      if (_millGroups.isNotEmpty) {
        _selectedGroup = _selectedGroup != null
            ? _millGroups.firstWhere(
                (g) => g.millCode == _selectedGroup!.millCode,
                orElse: () => _millGroups.first,
              )
            : _millGroups.first;
        _selectedGroupRecipes = _selectedGroup?.recipes ?? [];
      } else {
        _selectedGroup = null;
        _selectedGroupRecipes = [];
      }
      _isLoading = false;
    });
  }

  void _onSelectGroup(MillRecipeGroupModel group) {
    setState(() {
      _selectedGroup = group;
      _selectedGroupRecipes = group.recipes;
    });
  }

  Future<void> _handleSaveRecipes(List<MillRecipeModel> recipes) async {
    final success = await _service.batchSaveRecipes(recipes);
    if (!mounted) return;

    if (success) {
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Mill printing rates saved successfully!'),
          ),
        ),
      );
      _loadAllData();
    }
  }

  Future<void> _handleDeleteRecipe(String recipeId) async {
    final success = await _service.deleteRecipe(recipeId);
    if (!mounted) return;

    if (success) {
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Rate recipe deleted.'),
          ),
        ),
      );
      _loadAllData();
    }
  }

  Future<void> _openNewRecipeDialog() async {
    final recipe = await MillRecipeEntryDialog.show(
      context,
      mills: _millOptions,
      fabrics: _fabricOptions,
    );

    if (recipe != null) {
      final success = await _service.saveRecipe(recipe);
      if (!mounted) return;

      if (success) {
        shad.showToast(
          context: context,
          builder: (context, show) => const shad.Card(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('New mill rate recipe saved!'),
            ),
          ),
        );
        _loadAllData();
      }
    }
  }

  Future<void> _handleSaveMatrix(Map<String, double> matrix) async {
    if (_selectedGroup == null) return;
    List<MillRecipeModel> newRecipes = [];

    matrix.forEach((key, rate) {
      if (rate > 0) {
        final parts = key.split('_');
        if (parts.length >= 2) {
          final fabricName = parts[0];
          final printType = parts[1];

          newRecipes.add(
            MillRecipeModel(
              id: '',
              millCode: _selectedGroup!.millCode,
              millName: _selectedGroup!.millName,
              fabricCode: 'Q001',
              fabricName: fabricName,
              printType: printType,
              valueType: 'Ink',
              rate: rate,
              effectiveDate: DateTime.now(),
              isActive: true,
            ),
          );
        }
      }
    });

    if (newRecipes.isNotEmpty) {
      await _handleSaveRecipes(newRecipes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Metric Row
          MillRecipeMetricCards(
            metrics: _metrics,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 12),

          // 2. View Switcher Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Rate Workspace Layout: ',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  shad.GhostButton(
                    onPressed: () => setState(() => _isMatrixView = false),
                    child: Row(
                      children: [
                        Icon(
                          shad.LucideIcons.layoutGrid,
                          size: 14,
                          color: !_isMatrixView ? colors.primary : colors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Split View (2-Pane)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: !_isMatrixView ? FontWeight.bold : FontWeight.normal,
                            color: !_isMatrixView ? colors.primary : colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  shad.GhostButton(
                    onPressed: () => setState(() => _isMatrixView = true),
                    child: Row(
                      children: [
                        Icon(
                          shad.LucideIcons.table,
                          size: 14,
                          color: _isMatrixView ? colors.primary : colors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bulk Matrix View',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _isMatrixView ? FontWeight.bold : FontWeight.normal,
                            color: _isMatrixView ? colors.primary : colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              shad.PrimaryButton(
                onPressed: _openNewRecipeDialog,
                child: const Row(
                  children: [
                    Icon(shad.LucideIcons.plus, size: 14),
                    SizedBox(width: 4),
                    Text('New Rate List Entry'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Main Content Workspace
          Expanded(
            child: _isMatrixView
                ? MillRecipeMatrixView(
                    millName: _selectedGroup?.millName ?? 'Ambaji Mill',
                    fabrics: _fabricOptions.map((f) => f['name']!).toList(),
                    printTypes: RecipeMillService.standardPrintTypes,
                    initialMatrix: const {},
                    onSaveMatrix: _handleSaveMatrix,
                  )
                : Row(
                    children: [
                      // Left Pane (List View)
                      Expanded(
                        flex: 2,
                        child: MillRecipeListPane(
                          groups: _millGroups,
                          selectedGroup: _selectedGroup,
                          onSelectGroup: _onSelectGroup,
                          searchController: _searchController,
                          onSearchChanged: (_) => _loadAllData(),
                          onAddNew: _openNewRecipeDialog,
                          isLoading: _isLoading,
                        ),
                      ),
                      const shad.DensityGap(shad.gapMd),

                      // Right Pane (Content Card)
                      Expanded(
                        flex: 3,
                        child: MillRecipeContentCard(
                          selectedGroup: _selectedGroup,
                          recipes: _selectedGroupRecipes,
                          onSaveRecipes: _handleSaveRecipes,
                          onDeleteRecipe: _handleDeleteRecipe,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
