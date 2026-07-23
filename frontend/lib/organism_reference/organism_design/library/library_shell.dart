import 'package:flutter/material.dart';
import '../theme.dart';
import '../tissues.dart';
import 'sections/theme_view.dart';
import 'sections/plasma_view.dart';
import 'sections/cells_view.dart';
import 'sections/tissues_view.dart';
import 'sections/organs_view.dart';
import 'sections/domain_view.dart';

class OrganismLibraryScreen extends StatefulWidget {
  const OrganismLibraryScreen({super.key});

  @override
  State<OrganismLibraryScreen> createState() => _OrganismLibraryScreenState();
}

class _OrganismLibraryScreenState extends State<OrganismLibraryScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganismTheme.colorsOf(context).stone900,
      appBar: AppBar(
        title: Text('Organism Design Architecture — Dual Theme Comparison',
            style: OrganismTheme.titleLarge(context).copyWith(color: Colors.white)),
        backgroundColor: OrganismTheme.colorsOf(context).stone800,
        elevation: 0,
        centerTitle: false,
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: OrganismTheme.spacingLg),
                  child: Theme(
                    data: OrganismTheme.materialTheme(Brightness.dark),
                    child: Builder(
                      builder: (ctx) => TissueTabs(
                        tabs: const ['Theme', 'Plasma', 'Cells', 'Tissues', 'Organs', 'Domain'],
                        initialIndex: _selectedIndex,
                        variant: TissueTabsVariant.pill,
                        onChanged: (index) => setState(() => _selectedIndex = index),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: Row(
        children: [
          // LIGHT THEME PANE
          Expanded(
            child: Theme(
              data: OrganismTheme.materialTheme(Brightness.light),
              child: _ThemePane(
                brightness: Brightness.light,
                label: 'LIGHT MODE — FUSCHIA DENSITY',
                selectedIndex: _selectedIndex,
              ),
            ),
          ),

          // VERTICAL DIVIDER
          Container(width: 1, color: Colors.white10),

          // DARK THEME PANE
          Expanded(
            child: Theme(
              data: OrganismTheme.materialTheme(Brightness.dark),
              child: _ThemePane(
                brightness: Brightness.dark,
                label: 'DARK MODE — KINETIC SLATE',
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePane extends StatelessWidget {
  final Brightness brightness;
  final String label;
  final int selectedIndex;

  const _ThemePane({
    required this.brightness,
    required this.label,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we fetch colors from the NEAREST Theme provider (the one we just wrapped in build above)
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      color: colors.background, // Match pane background to theme
      child: Column(
        children: [
          // SUB-HEADER FOR THE PANE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: Text(
              label,
              style: OrganismTheme.labelLarge(context).copyWith(
                color: colors.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          // SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _LibraryContent(selectedIndex: selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  final int selectedIndex;
  
  const _LibraryContent({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedIndex == 0) const ThemeView(),
        if (selectedIndex == 1) const PlasmaView(),
        if (selectedIndex == 2) const CellsView(),
        if (selectedIndex == 3) const TissuesView(),
        if (selectedIndex == 4) const OrgansView(),
        if (selectedIndex == 5) const DomainView(),
        const SizedBox(height: OrganismMetrics.footerBuffer),
      ],
    );
  }
}
