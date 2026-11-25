/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Application entrypoint (`main`) and root theme shell (`TextileERPMain`) for the
     Dhaaga ERP Windows desktop, mobile & web client.
   - Initializes Supabase (`IMMBE2627`), configures `windowManager` desktop bounds,
     light/dark `shadcn_flutter` color schemes, Geist typography, and native
     `shadcn_flutter` `FocusOutline` rendering.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses native `shadcn_flutter` color schemes (`lightSlate.teal` / `darkStone.amber`)
     and built-in `shad.FocusOutline` so focus rings stay locally anchored to controls
     during animations, popovers, and soft-keyboard transitions.
   - Window positioning preserves `center: false` and explicit desktop sizing per
     `GEMINI.md` Rule 3.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Never mutate files inside `shadcn_flutter` pub cache; all focus and theme
     configurations live strictly inside this application layer.
   - `hide Colors, Border` prevents conflicts with `shadcn_flutter`'s tokens.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future density switcher (compact/normal/spacious) can hook into `ShadcnApp`.
================================================================================
*/

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide Colors, Border; // Hide layout/paint conflicts
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'config/supabase_config.dart';
import 'dynamic_ai/specs/dy_color_system.dart';
import 'dynamic_ai/specs/dy_grid_system.dart';
import 'screens/workspace/auth/scr_auth_gate.dart';

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
      title: 'Dhaaga',
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
    const shad.Density resolvedDensity = shad.Density.defaultDensity;
    final lightColorScheme = shad.ColorSchemes.lightSlate.teal.copyWith(
      input: () => shad.ColorSchemes.lightSlate.teal.background,
    );
    final darkColorScheme = shad.ColorSchemes.darkStone.amber.copyWith(
      input: () => shad.ColorSchemes.darkStone.amber.card,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 1920.0;
        final bool isCompactViewport = width < DyGridSystem.breakpointTablet;
        final shad.AdaptiveScaling resolvedScaling = isCompactViewport
            ? const shad.AdaptiveScaling.only(
                sizeScaling: 1.0,
                textScaling: 1.10,
                radiusScaling: 1.0,
              )
            : const shad.AdaptiveScaling(1.0);

        return ValueListenableBuilder<shad.ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, child) {
            return shad.ShadcnApp(
              title: 'Dhaaga',
              scaling: resolvedScaling,
              theme: shad.ThemeData(
                colorScheme: lightColorScheme,
                density: resolvedDensity,
                surfaceOpacity: 0.9,
                surfaceBlur: 8.0,
                typography: shad.Typography.geist(
                  sans: GoogleFonts.inter(),
                  mono: GoogleFonts.jetBrainsMono(),
                  base: const TextStyle(fontSize: 16),
                ),
              ),
              darkTheme: shad.ThemeData(
                colorScheme: darkColorScheme,
                density: resolvedDensity,
                surfaceOpacity: 0.9,
                surfaceBlur: 8.0,
                typography: shad.Typography.geist(
                  sans: GoogleFonts.inter(),
                  mono: GoogleFonts.jetBrainsMono(),
                  base: const TextStyle(fontSize: 16),
                ),
              ),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                final theme = shad.Theme.of(context);
                final colors = theme.colorScheme;
                final isDark = theme.brightness == Brightness.dark;
                final surfaceColor = DyColorSystem.resolveSurfaceCanvas(isDark);

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: shad.Colors.transparent,
                    statusBarIconBrightness:
                        isDark ? Brightness.light : Brightness.dark,
                    statusBarBrightness:
                        isDark ? Brightness.dark : Brightness.light,
                    systemNavigationBarColor: surfaceColor,
                    systemNavigationBarIconBrightness:
                        isDark ? Brightness.light : Brightness.dark,
                  ),
                  child: shad.ComponentTheme<shad.TooltipTheme>(
                    data: shad.TooltipTheme(
                      backgroundColor: colors.mutedForeground,
                    ),
                    child: shad.ComponentTheme<shad.CardTheme>(
                      data: shad.CardTheme(
                        borderRadius: theme.borderRadiusMd,
                      ),
                      child: shad.ComponentTheme<shad.TabPaneTheme>(
                        data: shad.TabPaneTheme(
                          borderRadius: theme.borderRadiusMd,
                          backgroundColor: surfaceColor,
                        ),
                        child: shad.ComponentTheme<shad.TabsTheme>(
                          data: shad.TabsTheme(
                            borderRadius: theme.borderRadiusMd,
                          ),
                          child: shad.ComponentTheme<shad.TextFieldTheme>(
                            data: shad.TextFieldTheme(
                              borderRadius: theme.borderRadiusMd,
                              border: shad.Border.all(
                                color: colors.border,
                                width: 1.0,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                              filled: false,
                            ),
                            child: shad.ComponentTheme<shad.OutlineButtonTheme>(
                              data: shad.OutlineButtonTheme(
                                decoration: (ctx, states, defaultDec) {
                                  final t = shad.Theme.of(ctx);
                                  final c = t.colorScheme;
                                  final Color fill;
                                  if (states
                                      .contains(shad.WidgetState.disabled)) {
                                    fill = c.muted;
                                  } else if (states
                                      .contains(shad.WidgetState.selected)) {
                                    fill = c.accent;
                                  } else if (states
                                      .contains(shad.WidgetState.hovered)) {
                                    fill = c.accent;
                                  } else {
                                    fill = c.background;
                                  }
                                  final border = shad.Border.all(
                                    color: c.border,
                                    width: 1.0,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  );
                                  if (defaultDec is BoxDecoration) {
                                    return defaultDec.copyWith(
                                      color: fill,
                                      borderRadius:
                                          BorderRadius.circular(t.radiusMd),
                                      border: border,
                                    );
                                  }
                                  return BoxDecoration(
                                    color: fill,
                                    borderRadius:
                                        BorderRadius.circular(t.radiusMd),
                                    border: border,
                                  );
                                },
                              ),
                              child: shad.DrawerOverlay(
                                child: child ?? const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              home: const ScrAuthGate(),
            );
          },
        );
      },
    );
  }
}
