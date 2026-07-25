import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../dynamic_ai/components/page_level/page_header.dart';
import 'screen_mill_recipe_landing.dart';

/// Main Recipes Module Hub under `/recipes`.
/// Houses sub-tab navigation for Mill Printing, Dyeing, Embroidery, and Finishing.
class ScreenRecipesLanding extends StatefulWidget {
  const ScreenRecipesLanding({super.key});

  @override
  State<ScreenRecipesLanding> createState() => _ScreenRecipesLandingState();
}

class _ScreenRecipesLandingState extends State<ScreenRecipesLanding> {
  int _selectedTab = 0; // 0: Mill Printing, 1: Dyeing, 2: Embroidery, 3: Finishing

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Module Header with Sub-Navigation Tabs
          Container(
            color: colors.card,
            padding: EdgeInsets.symmetric(
              horizontal: theme.density.baseContainerPadding * theme.scaling,
              vertical: theme.density.baseContainerPadding * theme.scaling * 0.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                PageHeader(
                  title: 'Recipes & Job Work Rates',
                ),
                const SizedBox(height: 8),

                // Sub-tabs router
                Row(
                  children: [
                    _buildSubTab(
                      index: 0,
                      label: 'Mill Printing',
                      icon: shad.LucideIcons.printer,
                    ),
                    const SizedBox(width: 8),
                    _buildSubTab(
                      index: 1,
                      label: 'Dyeing & Processing',
                      icon: shad.LucideIcons.droplets,
                      isBeta: true,
                    ),
                    const SizedBox(width: 8),
                    _buildSubTab(
                      index: 2,
                      label: 'Embroidery & Stitching',
                      icon: shad.LucideIcons.scissors,
                      isBeta: true,
                    ),
                    const SizedBox(width: 8),
                    _buildSubTab(
                      index: 3,
                      label: 'Value Addition & Finishing',
                      icon: shad.LucideIcons.sparkles,
                      isBeta: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const shad.Divider(),

          // 2. Active Tab Content Workspace
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                const ScreenMillRecipeLanding(),
                _buildPlaceholderTab(
                  context,
                  title: 'Dyeing & Processing Recipes',
                  subtitle:
                      'Dyeing shade cards, liquor ratios, and chemical cost structures will be configured here.',
                  icon: shad.LucideIcons.droplets,
                ),
                _buildPlaceholderTab(
                  context,
                  title: 'Embroidery & Stitching Recipes',
                  subtitle:
                      'Stitch counts, thread consumption, and multi-head embroidery rates will be managed here.',
                  icon: shad.LucideIcons.scissors,
                ),
                _buildPlaceholderTab(
                  context,
                  title: 'Value Addition & Finishing Recipes',
                  subtitle:
                      'Handwork, stone work, washing, and finishing process rates will be managed here.',
                  icon: shad.LucideIcons.sparkles,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab({
    required int index,
    required String label,
    required IconData icon,
    bool isBeta = false,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = _selectedTab == index;

    return shad.GhostButton(
      onPressed: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? colors.primary : colors.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colors.primary : colors.foreground,
              ),
            ),
            if (isBeta) ...[
              const SizedBox(width: 6),
              const shad.SecondaryBadge(
                child: Text('SOON', style: TextStyle(fontSize: 8)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: shad.Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: colors.primary.withAlpha(150)),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.typography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 400,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.typography.xSmall
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
              const SizedBox(height: 16),
              const shad.OutlineBadge(
                child: Text('Module Planned for Next Sprint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
