/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Adaptive Dhaaga burgundy & spun-yarn looping textile warp-and-weft physics
     canvas used as the ambient backdrop for login and approval-pending views
     across Desktop, Web, and Samsung S26 Ultra mobile screens.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses a `Ticker` + `CustomPainter` harmonic drape simulation with damped
     Hooke-spring pointer/touch ripples so it runs natively at 60/120fps with
     zero external binary asset overhead.
   - Blends `shad.Theme.of(context)` foreground/muted tones with `DyDhaagaBrandTokens`
     burgundy & champagne-gold yarn intersection nodes so the weave remains crisp
     and legible on both Light (`Slate 50`) and Dark (`Stone 900`) surfaces.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Wrapped in `RepaintBoundary` so the foreground login card never invalidates
     or triggers redundant child rebuilds on every animation frame.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None currently.
================================================================================
*/

library;

import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../dynamic_ai/micro/dy_dhaaga_logo.dart';
import '../../../../dynamic_ai/specs/dy_color_system.dart';

/// [TextileWeaveBackground] — Full-bleed monotone looping saree-silk weave
/// animation with soft touch/cursor spring physics behind [child].
class TextileWeaveBackground extends StatefulWidget {
  final Widget child;

  const TextileWeaveBackground({
    super.key,
    required this.child,
  });

  @override
  State<TextileWeaveBackground> createState() => _TextileWeaveBackgroundState();
}

class _TextileWeaveBackgroundState extends State<TextileWeaveBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _phase = 0.0;
  Duration _lastTick = Duration.zero;

  // Interactive spring state for cursor hover / touch ripple
  Offset? _pointerPos;
  Offset _smoothedPointer = Offset.zero;
  double _rippleEnergy = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final double dt = _lastTick == Duration.zero
        ? 0.016
        : ((elapsed - _lastTick).inMicroseconds / 1000000.0).clamp(0.001, 0.05);
    _lastTick = elapsed;

    // Continuous seamless phase advance (approx. 14s calm loop cycle)
    _phase += dt * 0.48;

    // Damped spring interpolation toward pointer/touch
    if (_pointerPos != null) {
      _smoothedPointer =
          Offset.lerp(_smoothedPointer, _pointerPos!, (dt * 7.0).clamp(0.0, 1.0)) ??
              _pointerPos!;
      _rippleEnergy = (_rippleEnergy + dt * 2.5).clamp(0.0, 1.0);
    } else {
      _rippleEnergy = (_rippleEnergy - dt * 1.4).clamp(0.0, 1.0);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Level 0 root canvas token from DyColorSystem (Slate 50 light, Stone 900 dark)
    final Color canvasBg = DyColorSystem.resolveRootBackground(isDark);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerHover: (event) => _pointerPos = event.localPosition,
      onPointerDown: (event) {
        _pointerPos = event.localPosition;
        if (_smoothedPointer == Offset.zero) {
          _smoothedPointer = event.localPosition;
        }
      },
      onPointerMove: (event) => _pointerPos = event.localPosition,
      onPointerUp: (_) => _pointerPos = null,
      onPointerCancel: (_) => _pointerPos = null,
      child: DecoratedBox(
        decoration: BoxDecoration(color: canvasBg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: _TextileWeavePainter(
                  phase: _phase,
                  threadColor: colors.foreground,
                  accentThreadColor: colors.mutedForeground,
                  brandThreadColor: isDark
                      ? DyDhaagaBrandTokens.burgundyLight
                      : DyDhaagaBrandTokens.burgundyMid,
                  goldThreadColor: DyDhaagaBrandTokens.weftGold,
                  pointer: _smoothedPointer,
                  rippleEnergy: _rippleEnergy,
                  isDark: isDark,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _TextileWeavePainter extends CustomPainter {
  final double phase;
  final Color threadColor;
  final Color accentThreadColor;
  final Color brandThreadColor;
  final Color goldThreadColor;
  final Offset pointer;
  final double rippleEnergy;
  final bool isDark;

  const _TextileWeavePainter({
    required this.phase,
    required this.threadColor,
    required this.accentThreadColor,
    required this.brandThreadColor,
    required this.goldThreadColor,
    required this.pointer,
    required this.rippleEnergy,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final int weftCount = size.width < 600 ? 18 : 26;
    final int warpCount = size.width < 600 ? 10 : 18;
    final int segments = size.width < 600 ? 22 : 34;

    final double baseAlpha = isDark ? 0.14 : 0.18;
    final double secondaryAlpha = isDark ? 0.22 : 0.24;
    final double burgundyAlpha = isDark ? 0.42 : 0.34;
    final double warpAlpha = isDark ? 0.12 : 0.15;
    final double warpBurgundyAlpha = isDark ? 0.24 : 0.20;

    final Paint weftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint warpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint knotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = brandThreadColor.withValues(alpha: isDark ? 0.48 : 0.38);

    // 1. Flowing horizontal Weft threads (diagonal silk drape)
    final List<List<Offset>> burgundyWeftSamples = [];
    for (int i = 0; i < weftCount; i++) {
      final double normY = (i + 0.5) / weftCount;
      final double anchorY = size.height * (0.06 + normY * 0.88);
      final double amp = 14.0 + (i % 4) * 5.0;
      final double freq = 1.65 + (i % 3) * 0.35;
      final double threadShift = i * 0.24;

      final bool isBurgundyAccent = i % 4 == 0;
      final bool isSecondarySilk = !isBurgundyAccent && i % 4 == 2;
      if (isBurgundyAccent) {
        weftPaint
          ..color = brandThreadColor.withValues(alpha: burgundyAlpha)
          ..strokeWidth = 1.45;
      } else if (isSecondarySilk) {
        weftPaint
          ..color = threadColor.withValues(alpha: secondaryAlpha)
          ..strokeWidth = 1.20;
      } else {
        weftPaint
          ..color = accentThreadColor.withValues(alpha: baseAlpha)
          ..strokeWidth = 1.05;
      }

      final Path path = Path();
      final List<Offset>? accentPts = isBurgundyAccent ? <Offset>[] : null;
      for (int s = 0; s <= segments; s++) {
        final double t = s / segments;
        final double x = t * size.width;
        final double primaryWave =
            math.sin(t * math.pi * freq + phase + threadShift) * amp;
        final double secondarySilk =
            math.cos(t * math.pi * 2.8 - phase * 0.85 + threadShift * 0.5) *
                (amp * 0.42);

        // Diagonal silk drape slope + gentle breathing fold
        final double diagonalDrift = (t - 0.5) * size.height * 0.14;
        double y = anchorY + primaryWave + secondarySilk - diagonalDrift;

        // Interactive spring ripple near cursor / finger
        if (rippleEnergy > 0.01) {
          final double dx = x - pointer.dx;
          final double dy = y - pointer.dy;
          final double distSq = dx * dx + dy * dy;
          const double radiusSq = 220.0 * 220.0;
          if (distSq < radiusSq) {
            final double falloff = 1.0 - (distSq / radiusSq);
            final double ripple =
                math.sin(math.sqrt(distSq) * 0.045 - phase * 4.0) *
                    18.0 *
                    falloff *
                    rippleEnergy;
            y += ripple;
          }
        }

        accentPts?.add(Offset(x, y));
        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      if (accentPts != null) {
        burgundyWeftSamples.add(accentPts);
      }
      canvas.drawPath(path, weftPaint);
    }

    // 2. Interlocking vertical Warp filaments
    final List<List<Offset>> burgundyWarpSamples = [];
    for (int j = 0; j < warpCount; j++) {
      final double normX = (j + 0.5) / warpCount;
      final double anchorX = size.width * (0.04 + normX * 0.92);
      final bool isBurgundyWarp = j % 4 == 0;
      warpPaint
        ..color = isBurgundyWarp
            ? brandThreadColor.withValues(alpha: warpBurgundyAlpha)
            : accentThreadColor.withValues(alpha: warpAlpha)
        ..strokeWidth = isBurgundyWarp ? 1.15 : 0.95;

      final Path path = Path();
      final List<Offset>? warpPts = isBurgundyWarp ? <Offset>[] : null;
      const int vSegments = 20;
      for (int s = 0; s <= vSegments; s++) {
        final double t = s / vSegments;
        final double y = t * size.height;
        double x = anchorX +
            math.sin(t * math.pi * 2.1 + phase * 0.9 + j * 0.4) * 14.0 +
            math.cos(t * math.pi * 1.3 - phase * 0.6 + j * 0.2) * 6.0;

        if (rippleEnergy > 0.01) {
          final double dx = x - pointer.dx;
          final double dy = y - pointer.dy;
          final double distSq = dx * dx + dy * dy;
          const double radiusSq = 190.0 * 190.0;
          if (distSq < radiusSq) {
            final double falloff = 1.0 - (distSq / radiusSq);
            x += (dx >= 0 ? 1 : -1) * 12.0 * falloff * rippleEnergy;
          }
        }

        warpPts?.add(Offset(x, y));
        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      if (warpPts != null) {
        burgundyWarpSamples.add(warpPts);
      }
      canvas.drawPath(path, warpPaint);
    }

    // 3. Subtle woven intersection nodes where accent burgundy warp & weft cross
    final Paint knotHaloPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = goldThreadColor.withValues(alpha: isDark ? 0.22 : 0.34);
    for (final weftPts in burgundyWeftSamples) {
      for (final warpPts in burgundyWarpSamples) {
        final double approxWarpX = warpPts[warpPts.length ~/ 2].dx;
        Offset closestWeft = weftPts.first;
        double minDx = (closestWeft.dx - approxWarpX).abs();
        for (final pt in weftPts) {
          final double dx = (pt.dx - approxWarpX).abs();
          if (dx < minDx) {
            minDx = dx;
            closestWeft = pt;
          }
        }
        Offset closestWarp = warpPts.first;
        double minDy = (closestWarp.dy - closestWeft.dy).abs();
        for (final pt in warpPts) {
          final double dy = (pt.dy - closestWeft.dy).abs();
          if (dy < minDy) {
            minDy = dy;
            closestWarp = pt;
          }
        }
        final Offset node = Offset(
          (closestWeft.dx + closestWarp.dx) * 0.5,
          (closestWeft.dy + closestWarp.dy) * 0.5,
        );
        canvas.drawCircle(node, 3.0, knotHaloPaint);
        canvas.drawCircle(node, 1.65, knotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TextileWeavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.pointer != pointer ||
        oldDelegate.rippleEnergy != rippleEnergy ||
        oldDelegate.isDark != isDark ||
        oldDelegate.threadColor != threadColor ||
        oldDelegate.brandThreadColor != brandThreadColor;
  }
}

