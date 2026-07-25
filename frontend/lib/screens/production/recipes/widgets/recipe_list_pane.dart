import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:intl/intl.dart';
import '../../../../models/production/model_recipe_mill.dart';

/// Left Pane listview in the 2-Pane layout displaying Mill & Fabric groups.
class MillRecipeListPane extends StatelessWidget {
  final List<MillRecipeGroupModel> groups;
  final MillRecipeGroupModel? selectedGroup;
  final ValueChanged<MillRecipeGroupModel> onSelectGroup;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddNew;
  final bool isLoading;

  const MillRecipeListPane({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onSelectGroup,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddNew,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    return shad.Card(
      child: Padding(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(shad.LucideIcons.building, size: 16, color: colors.primary),
                    const shad.DensityGap(shad.gapSm),
                    Text(
                      'Processing Mills',
                      style: theme.typography.textSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.foreground,
                      ),
                    ),
                  ],
                ),
                shad.OutlineButton(
                  onPressed: onAddNew,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shad.LucideIcons.plus, size: 14),
                      SizedBox(width: 4),
                      Text('New Rate'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search Bar
            shad.TextField(
              controller: searchController,
              placeholder: const Text('Search mill or fabric...'),
              onChanged: onSearchChanged,
              features: const [
                shad.InputFeature.leading(
                  Icon(shad.LucideIcons.search, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of Mill Groups
            Expanded(
              child: isLoading
                  ? const Center(child: shad.CircularProgressIndicator())
                  : groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(shad.LucideIcons.fileX,
                                  size: 32, color: colors.mutedForeground),
                              const SizedBox(height: 8),
                              Text(
                                'No mill recipes found',
                                style: theme.typography.xSmall
                                    .copyWith(color: colors.mutedForeground),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: groups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            final isSelected = selectedGroup?.millCode == group.millCode;

                            return shad.GhostButton(
                              onPressed: () => onSelectGroup(group),
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary.withAlpha(25)
                                      : colors.card,
                                  borderRadius: BorderRadius.circular(theme.radiusMd),
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.primary
                                        : colors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            group.millName,
                                            style: theme.typography.textSmall
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.foreground,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        isSelected
                                            ? shad.PrimaryBadge(
                                                child: Text(
                                                  '${group.activeRecipesCount} rates',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              )
                                            : shad.SecondaryBadge(
                                                child: Text(
                                                  '${group.activeRecipesCount} rates',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${group.fabricsCount} Fabrics',
                                          style: theme.typography.xSmall
                                              .copyWith(
                                            color: colors.mutedForeground,
                                          ),
                                        ),
                                        Text(
                                          'Avg: ₹${group.avgRate.toStringAsFixed(1)}/m',
                                          style: theme.typography.xSmall
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rev: ${dateFormat.format(group.latestRevisionDate)}',
                                      style: theme.typography.xSmall.copyWith(
                                        fontSize: 10,
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
