/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Native `shadcn_flutter` brand emblem (`DyDhaagaLogo`) and theme-adaptive
     wordmark (`DyDhaagaWordmark`) for **Dhaaga** ERP under
     `lib/dynamic_ai/micro/dy_dhaaga_logo.dart`.
   - Implements the `36x36` (`36 * theme.scaling`) burgundy rounded-`6px`
     (`theme.radiusMd`) Chakra yarn-weaving logo in both static and animated
     looping states, paired with the `Dhaaga ©` wordmark for Light & Dark modes.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `DyDhaagaLogo(animated: false)` renders the static 8-crossing over/under
     woven Chakra yarn mandala at balanced rest phase (`phase = 0.0`).
   - `DyDhaagaLogo(animated: true)` drives a smooth 6-second repeating
     `AnimationController` spinning through one exact 90-degree (`pi / 2`)
     symmetry period while oscillating loom warp/weft shed tension and gliding
     shuttle filament highlights along the interlaced yarn paths.
   - `DyDhaagaWordmark` automatically adapts typography ink colors to
     `shad.Theme.of(context).colorScheme` (`foreground` + `mutedForeground`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Uses `shad.OutlinedContainer` with `shad.OutlinedContainerTheme` (never
     deprecated `OutlinedContainer` color/radius constructor fields) and wraps
     animations in `RepaintBoundary` so 60fps frames isolate cleanly.
   - `DhaagaLogoPainter` normalizes geometry against `min(size.width, size.height) / 36.0`
     so the mark scales crisply at any pixel ratio while preserving `6px/36px` radius.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Matching vector SVG and raster PNG/GIF brand files live in
     `frontend/assets/logo/`.
================================================================================
*/

library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Native Burgundy & Warm Spun-Yarn design tokens for the Dhaaga Chakra emblem.
abstract final class DyDhaagaBrandTokens {
  static const Color burgundyLight = Color(0xFF8A1F37);
  static const Color burgundyMid = Color(0xFF74182D);
  static const Color burgundyDark = Color(0xFF520D1D);
  static const Color burgundyBorderLightMode = Color(0xFF5E1223);
  static const Color burgundyBorderDarkMode = Color(0xFFA82D47);
  static const Color burgundyWeaveMask = Color(0xFF580F20);

  static const Color warpIvory = Color(0xFFFDF6EC);
  static const Color weftGold = Color(0xFFE8C39E);
  static const Color shuttleHighlight = Color(0xFFFFFDF9);
}

/// Dhaaga `36x36` burgundy rounded-`6px` (`theme.radiusMd`) Chakra yarn-weaving
/// brand mark supporting both static (`animated: false`) and continuous weave
/// (`animated: true`) modes.
class DyDhaagaLogo extends StatefulWidget {
  final double size;
  final bool animated;
  final bool applyScaling;

  const DyDhaagaLogo({
    super.key,
    this.size = 36.0,
    this.animated = true,
    this.applyScaling = true,
  });

  @override
  State<DyDhaagaLogo> createState() => _DyDhaagaLogoState();
}

class _DyDhaagaLogoState extends State<DyDhaagaLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DyDhaagaLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated != oldWidget.animated) {
      if (widget.animated) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double resolvedSize =
        widget.applyScaling ? widget.size * theme.scaling : widget.size;
    final double cornerRadius =
        (resolvedSize / 36.0) * theme.radiusMd;
    final Color borderColor = isDark
        ? DyDhaagaBrandTokens.burgundyBorderDarkMode
        : DyDhaagaBrandTokens.burgundyBorderLightMode;

    return shad.OutlinedContainer(
      width: resolvedSize,
      height: resolvedSize,
      clipBehavior: Clip.antiAlias,
      theme: shad.OutlinedContainerTheme(
        backgroundColor: DyDhaagaBrandTokens.burgundyMid,
        borderColor: borderColor,
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(cornerRadius),
        padding: EdgeInsets.zero,
      ),
      child: RepaintBoundary(
        child: widget.animated
            ? AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size.square(resolvedSize),
                    painter: DhaagaLogoPainter(
                      progress: _controller.value,
                      animated: true,
                    ),
                  );
                },
              )
            : CustomPaint(
                size: Size.square(resolvedSize),
                painter: const DhaagaLogoPainter(
                  progress: 0.0,
                  animated: false,
                ),
              ),
      ),
    );
  }
}

/// Vector canvas painter for the Dhaaga Burgundy Chakra yarn-weaving emblem.
///
/// Exposed publicly so asset generators and standalone vector surfaces render the
/// exact same interlaced 8-crossing warp & weft Chakra geometry.
class DhaagaLogoPainter extends CustomPainter {
  /// Normalized loop progress in `[0.0, 1.0)`.
  final double progress;
  final bool animated;

  /// Optional corner radius ratio when painting standalone rounded-square icons
  /// outside [shad.OutlinedContainer] (e.g., PNG/GIF raster generation).
  final bool paintRoundedBackdrop;

  const DhaagaLogoPainter({
    this.progress = 0.0,
    this.animated = true,
    this.paintRoundedBackdrop = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double side = math.min(size.width, size.height);
    if (side <= 0) return;

    final double s = side / 36.0;
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final Rect fullRect = Offset.zero & size;

    if (paintRoundedBackdrop) {
      final RRect rrect = RRect.fromRectAndRadius(
        fullRect,
        Radius.circular(6.0 * s),
      );
      canvas.save();
      canvas.clipRRect(rrect);
    }

    // 1. Burgundy gradient cloth backdrop
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DyDhaagaBrandTokens.burgundyLight,
          DyDhaagaBrandTokens.burgundyMid,
          DyDhaagaBrandTokens.burgundyDark,
        ],
        stops: [0.0, 0.52, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, bgPaint);

    // Subtle warm radial loom glow behind the spindle center
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          DyDhaagaBrandTokens.weftGold.withValues(alpha: 0.16),
          DyDhaagaBrandTokens.burgundyMid.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 13.5 * s));
    canvas.drawCircle(center, 13.5 * s, glowPaint);

    // 2. Seamless animation parameters (period = 1.0):
    //    - 90-degree (pi/2) rotation skips 2 sectors so weave parity matches at wrap
    //    - 2 cycles of shed tension oscillation per loop
    final double rot = animated ? progress * (math.pi / 2.0) : 0.0;
    final double shedPulse =
        animated ? 0.55 * math.sin(progress * math.pi * 4.0) : 0.0;
    final double shuttlePhase = animated ? progress * math.pi * 4.0 : 0.0;

    // 3. Outer Chakra rim & 8 tension bobbin nodes
    final Paint rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75 * s
      ..color = DyDhaagaBrandTokens.weftGold.withValues(alpha: 0.30);
    canvas.drawCircle(center, 11.7 * s, rimPaint);

    final Paint bobbinPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DyDhaagaBrandTokens.weftGold.withValues(alpha: 0.55);
    final double rimRot = animated ? -progress * (math.pi / 4.0) : 0.0;
    for (int i = 0; i < 8; i++) {
      final double angle = rimRot + i * (math.pi / 4.0);
      final Offset node = Offset(
        center.dx + math.cos(angle) * (11.7 * s),
        center.dy + math.sin(angle) * (11.7 * s),
      );
      canvas.drawCircle(node, 0.72 * s, bobbinPaint);
    }

    // 4. Interlaced 8-crossing Warp (Ivory) & Weft (Spun Gold) Chakra yarn weave
    const double baseR = 7.75;
    final double warpAmp = 3.95 + shedPulse;
    final double weftAmp = 3.95 - shedPulse;

    final Paint maskPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.05 * s
      ..color = DyDhaagaBrandTokens.burgundyWeaveMask;

    final Paint warpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.50 * s
      ..color = DyDhaagaBrandTokens.warpIvory;

    final Paint weftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.42 * s
      ..color = DyDhaagaBrandTokens.weftGold;

    const int sectorCount = 8;
    const double sectorSpan = math.pi * 2.0 / sectorCount;

    for (int k = 0; k < sectorCount; k++) {
      final double startAngle = k * sectorSpan;
      final double endAngle = (k + 1) * sectorSpan;
      final double crossInset = sectorSpan * 0.16;

      final Path warpFull = _buildRoseSectorPath(
        center: center,
        scale: s,
        startAngle: startAngle,
        endAngle: endAngle,
        rotation: rot,
        baseRadius: baseR,
        amplitude: warpAmp,
        phaseShift: 0.0,
      );
      final Path weftFull = _buildRoseSectorPath(
        center: center,
        scale: s,
        startAngle: startAngle,
        endAngle: endAngle,
        rotation: rot,
        baseRadius: baseR,
        amplitude: weftAmp,
        phaseShift: math.pi,
      );

      if (k.isEven) {
        canvas.drawPath(warpFull, warpPaint);
        final Path weftMask = _buildRoseSectorPath(
          center: center,
          scale: s,
          startAngle: startAngle + crossInset,
          endAngle: endAngle - crossInset,
          rotation: rot,
          baseRadius: baseR,
          amplitude: weftAmp,
          phaseShift: math.pi,
        );
        canvas.drawPath(weftMask, maskPaint);
        canvas.drawPath(weftFull, weftPaint);
      } else {
        canvas.drawPath(weftFull, weftPaint);
        final Path warpMask = _buildRoseSectorPath(
          center: center,
          scale: s,
          startAngle: startAngle + crossInset,
          endAngle: endAngle - crossInset,
          rotation: rot,
          baseRadius: baseR,
          amplitude: warpAmp,
          phaseShift: 0.0,
        );
        canvas.drawPath(warpMask, maskPaint);
        canvas.drawPath(warpFull, warpPaint);
      }
    }

    // 5. Traveling Yarn Shuttle Glints (animated weave motion cue)
    if (animated) {
      final double glintFade = 0.75 + 0.25 * math.sin(progress * math.pi * 2.0);
      final Paint glintWarpPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.95 * s
        ..color =
            DyDhaagaBrandTokens.shuttleHighlight.withValues(alpha: 0.92 * glintFade);

      final Paint glintWeftPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.75 * s
        ..color = DyDhaagaBrandTokens.warpIvory.withValues(alpha: 0.85 * glintFade);

      for (int pulse = 0; pulse < 2; pulse++) {
        final double arcOffset = pulse * math.pi;
        final double aStart = shuttlePhase + arcOffset;
        final Path wGlint = _buildRoseSectorPath(
          center: center,
          scale: s,
          startAngle: aStart,
          endAngle: aStart + 0.58,
          rotation: rot,
          baseRadius: baseR,
          amplitude: warpAmp,
          phaseShift: 0.0,
        );
        canvas.drawPath(wGlint, glintWarpPaint);

        final double bStart = -shuttlePhase + arcOffset + 0.35;
        final Path fGlint = _buildRoseSectorPath(
          center: center,
          scale: s,
          startAngle: bStart,
          endAngle: bStart + 0.52,
          rotation: rot,
          baseRadius: baseR,
          amplitude: weftAmp,
          phaseShift: math.pi,
        );
        canvas.drawPath(fGlint, glintWeftPaint);
      }
    }

    // 6. Central Chakra Spindle Eyelet
    final Paint hubFill = Paint()
      ..style = PaintingStyle.fill
      ..color = DyDhaagaBrandTokens.burgundyDark;
    canvas.drawCircle(center, 2.35 * s, hubFill);

    final Paint hubRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15 * s
      ..color = DyDhaagaBrandTokens.warpIvory;
    canvas.drawCircle(center, 2.35 * s, hubRing);

    final Paint hubCore = Paint()
      ..style = PaintingStyle.fill
      ..color = DyDhaagaBrandTokens.weftGold;
    canvas.drawCircle(center, 0.95 * s, hubCore);

    if (paintRoundedBackdrop) {
      canvas.restore();
      final Paint edgeBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 * s
        ..color = DyDhaagaBrandTokens.burgundyBorderDarkMode
            .withValues(alpha: 0.72);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fullRect.deflate(0.5 * s), Radius.circular(6.0 * s)),
        edgeBorder,
      );
    }
  }

  Path _buildRoseSectorPath({
    required Offset center,
    required double scale,
    required double startAngle,
    required double endAngle,
    required double rotation,
    required double baseRadius,
    required double amplitude,
    required double phaseShift,
  }) {
    const int steps = 20;
    final Path path = Path();
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double theta = startAngle + (endAngle - startAngle) * t;
      final double r = (baseRadius + amplitude * math.cos(4.0 * theta + phaseShift)) *
          scale;
      final double a = theta + rotation;
      final double x = center.dx + math.cos(a) * r;
      final double y = center.dy + math.sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant DhaagaLogoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animated != animated ||
        oldDelegate.paintRoundedBackdrop != paintRoundedBackdrop;
  }
}

/// Theme-adaptive typographic wordmark for **Dhaaga** with superscript `©`.
///
/// Renders cleanly on both light and dark themes using `colors.foreground` and
/// `colors.mutedForeground` from [shad.Theme].
class DyDhaagaWordmark extends StatelessWidget {
  final double? fontSize;
  final bool showCopyright;

  const DyDhaagaWordmark({
    super.key,
    this.fontSize,
    this.showCopyright = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final double scale = theme.scaling;
    final double resolvedSize = (fontSize ?? 19.0) * scale;

    final TextStyle wordStyle = GoogleFonts.plusJakartaSans(
      fontSize: resolvedSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.55,
      height: 1.0,
      color: colors.foreground,
    );

    final TextStyle copyStyle = GoogleFonts.plusJakartaSans(
      fontSize: (resolvedSize * 0.48).clamp(8.5, 13.0),
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: colors.mutedForeground,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dhaaga', style: wordStyle),
        if (showCopyright)
          Padding(
            padding: EdgeInsets.only(
              left: 2.0 * scale,
              top: 1.0 * scale,
            ),
            child: Text('\u00A9', style: copyStyle),
          ),
      ],
    );
  }
}
