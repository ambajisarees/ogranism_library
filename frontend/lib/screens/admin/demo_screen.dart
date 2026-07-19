import 'package:flutter/material.dart' hide Card, Tab;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../ant_design/widgets/page_header.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(theme.density.baseContainerPadding * shad.padLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              icon: const Icon(shad.LucideIcons.scissors),
              title: 'Demo Workspace',
              subtitle: 'Manage your textile cutting patterns and workspace',
              actions: [
                shad.OutlineButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(shad.LucideIcons.download),
                      shad.DensityGap(shad.gapSm),
                      Text('Export'),
                    ],
                  ),
                ),
                shad.PrimaryButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(shad.LucideIcons.plus),
                      shad.DensityGap(shad.gapSm),
                      Text('Add'),
                    ],
                  ),
                ),
              ],
            ),
            const shad.DensityGap(shad.gapLg),
            shad.Tabs(
              index: _tabIndex,
              onChanged: (index) {
                setState(() => _tabIndex = index);
              },
              children: const [
                shad.TabItem(child: Text('Tab 1')),
                shad.TabItem(child: Text('Tab 2')),
                shad.TabItem(child: Text('Tab 3')),
              ],
            ),
            const shad.DensityGap(shad.gap2xl),
            const DynamicActionBar(),
          ],
        ),
      ),
    );
  }
}

class DynamicActionBar extends StatefulWidget {
  const DynamicActionBar({super.key});

  @override
  State<DynamicActionBar> createState() => _DynamicActionBarState();
}

class _DynamicActionBarState extends State<DynamicActionBar> {
  String? _category;
  String? _status;
  int _activeSortIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _sortOptions = ['Name', 'Date', 'Priority', 'Status'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return shad.Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.density.baseContainerPadding * shad.padXs,
          vertical: theme.density.baseContainerPadding * shad.padXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Input
            SizedBox(
              width: 320,
              child: shad.TextField(
                controller: _searchController,
                placeholder: const Text('Search workspace...'),
                features: [
                  shad.InputFeature.leading(
                    const Icon(shad.LucideIcons.search),
                  ),
                  shad.InputFeature.clear(
                    visibility: shad.InputFeatureVisibility.textNotEmpty,
                  ),
                ],
              ),
            ),
            const shad.DensityGap(shad.gapLg),
            // Category Filter
            shad.Select<String>(
              value: _category,
              placeholder: const Text('Category'),
              onChanged: (val) {
                setState(() => _category = val);
              },
              constraints: const BoxConstraints(minWidth: 160),
              popup: (context) => const shad.SelectPopup.noVirtualization(
                items: shad.SelectItemList(
                  children: [
                    shad.SelectItemButton(
                        value: 'All Categories', child: Text('All Categories')),
                    shad.SelectItemButton(
                        value: 'Design', child: Text('Design')),
                    shad.SelectItemButton(
                        value: 'Grey Warehouse', child: Text('Grey Warehouse')),
                    shad.SelectItemButton(
                        value: 'Production', child: Text('Production')),
                  ],
                ),
              ),
              itemBuilder: (context, item) => Text(item),
            ),
            const shad.DensityGap(shad.gapMd),
            // Status Filter
            shad.Select<String>(
              value: _status,
              placeholder: const Text('Status'),
              onChanged: (val) {
                setState(() => _status = val);
              },
              constraints: const BoxConstraints(minWidth: 160),
              popup: (context) => const shad.SelectPopup.noVirtualization(
                items: shad.SelectItemList(
                  children: [
                    shad.SelectItemButton(
                        value: 'All Statuses', child: Text('All Statuses')),
                    shad.SelectItemButton(
                        value: 'Active', child: Text('Active')),
                    shad.SelectItemButton(
                        value: 'Pending', child: Text('Pending')),
                    shad.SelectItemButton(
                        value: 'Completed', child: Text('Completed')),
                  ],
                ),
              ),
              itemBuilder: (context, item) => Text(item),
            ),
            const Spacer(),
            // Sort Chips
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sort by:',
                    style: theme.typography.textSmall.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    )),
                const shad.DensityGap(shad.gapMd),
                Wrap(
                  spacing: 8,
                  children: List.generate(_sortOptions.length, (index) {
                    final isSelected = _activeSortIndex == index;
                    return shad.Chip(
                      style: isSelected
                          ? const shad.ButtonStyle.primary()
                          : const shad.ButtonStyle.outline(),
                      onPressed: () {
                        setState(() => _activeSortIndex = index);
                      },
                      child: Text(_sortOptions[index]),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
