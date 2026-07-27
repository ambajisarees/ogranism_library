import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseNavigationUtility extends StatefulWidget {
  const ShowcaseNavigationUtility({super.key});

  @override
  State<ShowcaseNavigationUtility> createState() => _ShowcaseNavigationUtilityState();
}

class _ShowcaseNavigationUtilityState extends State<ShowcaseNavigationUtility> {
  int _tabIdx = 0;
  String _viewMode = 'table';

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text('Navigation Controls & Utilities', style: theme.typography.h2),
          Text(
            'Breadcrumbs, tab list bars, view switchers, desktop menubars, tree structures, and command palette previews.',
            style: theme.typography.textMuted,
          ),
          const shad.DensityGap(shad.gapLg),

          // 1. Breadcrumbs
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Breadcrumb Trail Navigation', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.Breadcrumb(
                  children: [
                    Text('Home', style: theme.typography.textSmall.copyWith(color: colors.primary)),
                    Text('Production Pipeline', style: theme.typography.textSmall.copyWith(color: colors.primary)),
                    Text('Cutting Batches', style: theme.typography.textSmall.copyWith(color: colors.primary)),
                    Text('Batch #C-2049', style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 2. Tab Lists & Segmented View Switchers
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab List Demo
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sub-Navigation Tab List', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Row(
                        children: [
                          _tabIdx == 0
                              ? shad.PrimaryButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => setState(() => _tabIdx = 0),
                                  child: const Text('Overview'),
                                )
                              : shad.GhostButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => setState(() => _tabIdx = 0),
                                  child: const Text('Overview'),
                                ),
                          const shad.DensityGap(shad.gapSm),
                          _tabIdx == 1
                              ? shad.PrimaryButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => setState(() => _tabIdx = 1),
                                  child: const Text('Line Items'),
                                )
                              : shad.GhostButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => setState(() => _tabIdx = 1),
                                  child: const Text('Line Items'),
                                ),
                          const shad.DensityGap(shad.gapSm),
                          _tabIdx == 2
                              ? shad.PrimaryButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => setState(() => _tabIdx = 2),
                                  child: const Text('Audit History'),
                                )
                              : shad.GhostButton(
                                  size: shad.ButtonSize.small,
                                  onPressed: () => setState(() => _tabIdx = 2),
                                  child: const Text('Audit History'),
                                ),
                        ],
                      ),
                      const shad.DensityGap(shad.gapMd),
                      Text('Active Sub-Tab: ${_tabIdx == 0 ? "Overview" : _tabIdx == 1 ? "Line Items" : "Audit History"}', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // View Switcher (Table / Grid / Board)
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Segmented View Switcher', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      Row(
                        children: [
                          _viewMode == 'table'
                              ? shad.IconButton.primary(
                                  size: shad.ButtonSize.small,
                                  icon: const Icon(shad.LucideIcons.table, size: 16),
                                  onPressed: () => setState(() => _viewMode = 'table'),
                                )
                              : shad.IconButton.outline(
                                  size: shad.ButtonSize.small,
                                  icon: const Icon(shad.LucideIcons.table, size: 16),
                                  onPressed: () => setState(() => _viewMode = 'table'),
                                ),
                          const SizedBox(width: 6),
                          _viewMode == 'grid'
                              ? shad.IconButton.primary(
                                  size: shad.ButtonSize.small,
                                  icon: const Icon(shad.LucideIcons.layoutGrid, size: 16),
                                  onPressed: () => setState(() => _viewMode = 'grid'),
                                )
                              : shad.IconButton.outline(
                                  size: shad.ButtonSize.small,
                                  icon: const Icon(shad.LucideIcons.layoutGrid, size: 16),
                                  onPressed: () => setState(() => _viewMode = 'grid'),
                                ),
                          const SizedBox(width: 6),
                          _viewMode == 'kanban'
                              ? shad.IconButton.primary(
                                  size: shad.ButtonSize.small,
                                  icon: const Icon(shad.LucideIcons.kanban, size: 16),
                                  onPressed: () => setState(() => _viewMode = 'kanban'),
                                )
                              : shad.IconButton.outline(
                                  size: shad.ButtonSize.small,
                                  icon: const Icon(shad.LucideIcons.kanban, size: 16),
                                  onPressed: () => setState(() => _viewMode = 'kanban'),
                                ),
                        ],
                      ),
                      const shad.DensityGap(shad.gapMd),
                      Text('Selected View Layout: ${_viewMode.toUpperCase()}', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // 3. Desktop Menubar Strip Preview
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Desktop Application Menubar Strip', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: colors.muted.withAlpha(100),
                    child: Row(
                      children: [
                        _buildMenubarTitle(context, 'File'),
                        _buildMenubarTitle(context, 'Edit'),
                        _buildMenubarTitle(context, 'View'),
                        _buildMenubarTitle(context, 'Masters'),
                        _buildMenubarTitle(context, 'Pipeline'),
                        _buildMenubarTitle(context, 'Help'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 4. Hierarchical Tree Navigation & Command Palette Container
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tree Navigation Preview
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category Folder Tree Navigation', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlinedContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTreeRow(context, 'Sarees Master', shad.LucideIcons.folderOpen, level: 0),
                              _buildTreeRow(context, 'Silk Sarees', shad.LucideIcons.folder, level: 1),
                              _buildTreeRow(context, 'Royal Silk D-4089', shad.LucideIcons.fileText, level: 2),
                              _buildTreeRow(context, 'Cotton Sarees', shad.LucideIcons.folder, level: 1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              // Command Palette Item Preview
              Expanded(
                child: shad.Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Command Palette Search Container', style: theme.typography.h3),
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlinedContainer(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Icon(shad.LucideIcons.search, size: 16, color: colors.mutedForeground),
                                  const SizedBox(width: 8),
                                  Text('Search actions or jump to module...', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                                ],
                              ),
                            ),
                            const shad.Divider(),
                            _buildCommandRow(context, 'Create New Purchase Order', 'Orders Module', shad.LucideIcons.plus),
                            _buildCommandRow(context, 'Airbyte Sync Diagnostics', 'System Diagnostics', shad.LucideIcons.activity),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenubarTitle(BuildContext context, String title) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(title, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTreeRow(BuildContext context, String label, IconData icon, {required int level}) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: level * 16.0, top: 4, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 8),
          Text(label, style: theme.typography.textSmall),
        ],
      ),
    );
  }

  Widget _buildCommandRow(BuildContext context, String title, String subtitle, IconData icon) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}
