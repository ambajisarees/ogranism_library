import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

// NEW ORGANISM DESIGN IMPORT
import 'organism_design/index.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vdprvitkijzxruhcgsin.supabase.co',
    anonKey: 'sb_publishable_0Vw9s7AKQxuh8io60rMPOQ_-XBNElsd',
  );

  // Desktop configuration
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1440, 900),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Ambaji Sarees ERP',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const TextileERPMain());
}

class TextileERPMain extends StatelessWidget {
  const TextileERPMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambaji Sarees ERP',
      theme: OrganismTheme.materialTheme,
      debugShowCheckedModeBanner: false,
      home: const AppBootstrapSelector(),
    );
  }
}

/// A simple entry selector to switch between the Design Library and the Actual App.
class AppBootstrapSelector extends StatelessWidget {
  const AppBootstrapSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganismTheme.surface,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(OrganismTheme.spacing2Xl),
          decoration: BoxDecoration(
            color: OrganismTheme.surface,
            border: Border.all(color: OrganismTheme.border),
            borderRadius: OrganismTheme.borderMd,
            boxShadow: OrganismTheme.shadowMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ambaji Sarees ERP', style: OrganismTheme.titleLarge),
              const SizedBox(height: OrganismTheme.spacingLg),
              Text(
                'Select entry point',
                style: OrganismTheme.bodyMedium.copyWith(color: OrganismTheme.textSecondary),
              ),
              const SizedBox(height: OrganismTheme.spacing2Xl),
              CellButton(
                text: 'Launch Design Library',
                icon: Icons.auto_awesome_mosaic,
                variant: CellButtonVariant.primary,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrganismLibraryScreen()),
                  );
                },
              ),
              const SizedBox(height: OrganismTheme.spacingMd),
              CellButton(
                text: 'Launch ERP Application',
                icon: Icons.business_center,
                variant: CellButtonVariant.outline,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
