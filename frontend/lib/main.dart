import 'package:flutter/material.dart'
    hide Colors, Border; // Hide layout/paint conflicts
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

// NEW ORGANISM DESIGN IMPORT
import 'screens/auth/auth_gate.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  // Desktop configuration
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 1200),
      minimumSize: Size(1920, 1200),
      maximumSize: Size(1920, 1200),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Ambaji Sarees ERP',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setResizable(false);
    });
  }

  runApp(const TextileERPMain());
}

class TextileERPMain extends StatelessWidget {
  const TextileERPMain({super.key});

  @override
  Widget build(BuildContext context) {
    // Commented out MaterialApp block:
    // return MaterialApp(
    //   title: 'Ambaji Sarees ERP',
    //   theme: OrganismTheme.materialTheme(Brightness.light),
    //   darkTheme: OrganismTheme.materialTheme(Brightness.dark),
    //   themeMode: ThemeMode.light,
    //   debugShowCheckedModeBanner: false,
    //   home: const AuthGate(),
    // );

    return shad.ShadcnApp(
      title: 'Ambaji Sarees ERP',
      theme: shad.ThemeData(
        colorScheme: shad.ColorSchemes.lightSlate.teal,
        surfaceOpacity: 0.9,
        surfaceBlur: 4.0,
      ),
      themeMode: shad.ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
