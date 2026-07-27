import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'showcase_buttons_controls.dart';
import 'showcase_inputs_forms.dart';
import 'showcase_overlays_dialogs.dart';
import 'showcase_cards_containers.dart';
import 'showcase_data_tables.dart';
import 'showcase_feedback_status.dart';
import 'showcase_navigation_utility.dart';

class ScreenComponentLibrary extends StatefulWidget {
  const ScreenComponentLibrary({super.key});

  @override
  State<ScreenComponentLibrary> createState() => _ScreenComponentLibraryState();
}

class _ScreenComponentLibraryState extends State<ScreenComponentLibrary> {
  int _selectedCategoryIndex = 0;
  String _searchFilter = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All Categories (70+)',
    'Buttons & Controls',
    'Inputs & Forms',
    'Overlays & Dialogs',
    'Cards & Containers',
    'Tables & Display',
    'Feedback & Status',
    'Navigation & Utility',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.background,
      child: Column(
        children: [
          // 1. Header Toolbar & Design System Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(shad.LucideIcons.bookOpen, color: colors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ambaji ERP • Component Showcase Library',
                          style: theme.typography.h3.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '70+ native shadcn_flutter UI controls, ERP density tokens, radius variables, and state matrices.',
                          style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Search Bar (Width: 260px)
                    SizedBox(
                      width: 260,
                      child: shad.TextField(
                        controller: _searchController,
                        placeholder: const Text('Search component or state...'),
                        onChanged: (val) => setState(() => _searchFilter = val.toLowerCase()),
                        features: [
                          shad.InputFeature.leading(
                            Icon(shad.LucideIcons.search, size: 16, color: colors.mutedForeground),
                          ),
                          if (_searchFilter.isNotEmpty)
                            shad.InputFeature.trailing(
                              shad.IconButton.ghost(
                                density: shad.ButtonDensity.iconDense,
                                size: shad.ButtonSize.small,
                                icon: const Icon(shad.LucideIcons.x, size: 14),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchFilter = '');
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapMd),

                // 2. Category Tab Strip
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_categories.length, (index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: isSelected
                            ? shad.PrimaryButton(
                                size: shad.ButtonSize.small,
                                onPressed: () => setState(() => _selectedCategoryIndex = index),
                                child: Text(_categories[index]),
                              )
                            : shad.GhostButton(
                                size: shad.ButtonSize.small,
                                onPressed: () => setState(() => _selectedCategoryIndex = index),
                                child: Text(_categories[index]),
                              ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // 3. Scrollable Component Showcase Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildShowcaseBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseBody() {
    if (_searchFilter.isNotEmpty) {
      return ListView(
        children: [
          if ('buttons & controls primary secondary outline ghost destructive microbutton icon switch checkbox radio slider rating counter'
              .contains(_searchFilter))
            const ShowcaseButtonsControls(),
          if ('inputs & forms textfield validation gstin search date time otp phone select autocomplete multiline chip color'
              .contains(_searchFilter))
            const ShowcaseInputsForms(),
          if ('overlays popovers hovercard dialog alert drawer sheet tooltip context menu window'
              .contains(_searchFilter))
            const ShowcaseOverlaysDialogs(),
          if ('cards containers kpi stat accordion collapsible code snippet carousel image card'
              .contains(_searchFilter))
            const ShowcaseCardsContainers(),
          if ('tables data display selection expandable row actions tracker pagination avatar chat bubble'
              .contains(_searchFilter))
            const ShowcaseDataTables(),
          if ('feedback badges banner status progress loader skeleton toast notification timeline'
              .contains(_searchFilter))
            const ShowcaseFeedbackStatus(),
          if ('navigation utility breadcrumbs tab list segmented switcher menubar folder tree command palette'
              .contains(_searchFilter))
            const ShowcaseNavigationUtility(),
        ],
      );
    }

    switch (_selectedCategoryIndex) {
      case 1:
        return const ShowcaseButtonsControls();
      case 2:
        return const ShowcaseInputsForms();
      case 3:
        return const ShowcaseOverlaysDialogs();
      case 4:
        return const ShowcaseCardsContainers();
      case 5:
        return const ShowcaseDataTables();
      case 6:
        return const ShowcaseFeedbackStatus();
      case 7:
        return const ShowcaseNavigationUtility();
      case 0:
      default:
        return ListView(
          children: [
            const ShowcaseButtonsControls(),
            shad.DensityGap(shad.gapXl),
            shad.Divider(),
            shad.DensityGap(shad.gapXl),
            ShowcaseInputsForms(),
            shad.DensityGap(shad.gapXl),
            shad.Divider(),
            shad.DensityGap(shad.gapXl),
            ShowcaseOverlaysDialogs(),
            shad.DensityGap(shad.gapXl),
            shad.Divider(),
            shad.DensityGap(shad.gapXl),
            ShowcaseCardsContainers(),
            shad.DensityGap(shad.gapXl),
            shad.Divider(),
            shad.DensityGap(shad.gapXl),
            ShowcaseDataTables(),
            shad.DensityGap(shad.gapXl),
            shad.Divider(),
            shad.DensityGap(shad.gapXl),
            ShowcaseFeedbackStatus(),
            shad.DensityGap(shad.gapXl),
            shad.Divider(),
            shad.DensityGap(shad.gapXl),
            ShowcaseNavigationUtility(),
          ],
        );
    }
  }
}
