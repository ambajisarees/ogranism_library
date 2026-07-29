import 'package:flutter/material.dart'
    hide Colors, Border; // Hide layout/paint conflicts
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';

// NEW ORGANISM DESIGN IMPORT
import 'screens/home.dart';
import 'config/supabase_config.dart';

final ValueNotifier<shad.ThemeMode> themeModeNotifier =
    ValueNotifier(shad.ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  // Desktop configuration (Full 1920x1200 native resolution)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    const targetSize = Size(1920, 1200);

    WindowOptions windowOptions = const WindowOptions(
      size: targetSize,
      minimumSize: Size(1280, 800),
      center: false,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Ambaji Sarees ERP',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPosition(const Offset(0, 0));
      await windowManager.setSize(targetSize);
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(true);
    });
  }

  runApp(const TextileERPMain());
}

class TextileERPMain extends StatelessWidget {
  const TextileERPMain({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<shad.ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return shad.ShadcnApp(
          title: 'Ambaji Sarees ERP',
          theme: shad.ThemeData(
            colorScheme: shad.ColorSchemes.lightSlate.teal,
            surfaceOpacity: 0.9,
            surfaceBlur: 4.0,
            typography: shad.Typography.geist(
              sans: GoogleFonts.inter(),
              mono: GoogleFonts.jetBrainsMono(),
              base: const TextStyle(fontSize: 16),
            ),
          ),
          darkTheme: shad.ThemeData(
            colorScheme: shad.ColorSchemes.darkStone.amber,
            surfaceOpacity: 0.9,
            surfaceBlur: 4.0,
            typography: shad.Typography.geist(
              sans: GoogleFonts.inter(),
              mono: GoogleFonts.jetBrainsMono(),
              base: const TextStyle(fontSize: 16),
            ),
          ),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}
