import 'package:flutter/material.dart';
import '../theme.dart';
import '../index.dart';
import 'sections/plasma_view.dart';
import 'sections/cells_view.dart';
import 'sections/tissues_view.dart';
import 'sections/organs_view.dart';

class OrganismLibraryScreen extends StatefulWidget {
  const OrganismLibraryScreen({super.key});

  @override
  State<OrganismLibraryScreen> createState() => _OrganismLibraryScreenState();
}

class _OrganismLibraryScreenState extends State<OrganismLibraryScreen> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  void _toggleTheme() {
    setState(() {
      if (_themeMode.value == ThemeMode.light) {
        _themeMode.value = ThemeMode.dark;
        OrganismTheme.setMode(ThemeMode.dark);
      } else {
        _themeMode.value = ThemeMode.light;
        OrganismTheme.setMode(ThemeMode.light);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeMode,
      builder: (context, _) {
        return Theme(
          data: OrganismTheme.materialTheme(_themeMode.value == ThemeMode.dark ? Brightness.dark : Brightness.light),
          child: Scaffold(
            backgroundColor: OrganismTheme.background,
            appBar: AppBar(
              title: Text('Organism Design Architecture', style: OrganismTheme.titleLarge),
              backgroundColor: OrganismTheme.surface,
              elevation: 0,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(_themeMode.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                  onPressed: _toggleTheme,
                  tooltip: 'Toggle Dark Mode',
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: OrganismTheme.border, height: 1),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(OrganismTheme.spacing2Xl),
                decoration: BoxDecoration(
                  color: OrganismTheme.surface,
                  borderRadius: OrganismTheme.borderLg,
                  border: Border.all(color: OrganismTheme.border),
                  boxShadow: OrganismTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    PlasmaView(),
                    SizedBox(height: 64.0),
                    CellsView(),
                    SizedBox(height: 64.0),
                    TissuesView(),
                    SizedBox(height: 64.0),
                    OrgansView(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
