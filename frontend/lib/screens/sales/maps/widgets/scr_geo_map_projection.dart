/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Pure Web Mercator (EPSG:3857) projection math, 3-tier screen-space
     clustering builder (`GeoMapSceneBuilder`), and `GeoSlippyOverlayPainter`
     for the `Sales -> Maps` interactive tile canvas (`DyGeoTerritoryMapCanvas`).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Shared deterministic scene computation (`GeoMapSceneBuilder.build`): produces
     zone polygons, Tier-1 National Zone Summary Bubbles, Surat corridor spokes,
     and Tier-2/Tier-3 clustered/individual `GeoMapNode` markers from the exact
     same coordinate pass used by both tap hit-testing and `CustomPainter`.
   - Zero-Overlap Label Engine: sorts priority (`selected` -> `hovered` -> Surat
     HQ -> highest party volume clusters/hubs) and culls colliding text pills
     via `Rect.overlaps` before painting.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `GeoZoneModel.centerLat` & `centerLng` are non-nullable `double` in
     `model_geo_locations.dart` (0.0 represents unset); `GeoLocationModel`
     coordinates are nullable and checked safely without `!` force-unwrapping.
   - `Size` does not define `.inflate()`; viewport rects are constructed via
     `Offset.zero & viewport`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Cluster radii (`42 px` -> `32 px` -> `22 px` -> `15 px` -> `0 px` at
     Z>=11.2) are tuned for desktop density and can be exposed via user zoom-LOD
     presets later if mobile breakpoints (Plan 10) require larger touch targets.
================================================================================
*/

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/sales/model_geo_locations.dart';

/// Pure Web Mercator (EPSG:3857) projection helper at continuous zoom `z`.
class MercatorProjection {
  static const double tileSize = 256.0;
  static const double minLat = 5.5;
  static const double maxLat = 37.5;
  static const double minLng = 65.5;
  static const double maxLng = 98.5;
  static const double minZoom = 4.0;
  static const double maxZoom = 14.0;

  static double worldSize(double zoom) => tileSize * math.pow(2.0, zoom);

  static double lngToWorldX(double lng, double zoom) {
    return ((lng + 180.0) / 360.0) * worldSize(zoom);
  }

  static double latToWorldY(double lat, double zoom) {
    final clamped = lat.clamp(-85.05112878, 85.05112878);
    final rad = clamped * math.pi / 180.0;
    final mercN = math.log(math.tan(math.pi / 4.0 + rad / 2.0));
    return (0.5 - mercN / (2.0 * math.pi)) * worldSize(zoom);
  }

  static double worldXToLng(double wx, double zoom) {
    return (wx / worldSize(zoom)) * 360.0 - 180.0;
  }

  static double worldYToLat(double wy, double zoom) {
    final n = math.pi - (2.0 * math.pi * wy) / worldSize(zoom);
    final latRad = 2.0 * math.atan(math.exp(n)) - math.pi / 2.0;
    return latRad * 180.0 / math.pi;
  }

  static Offset latLngToScreen(
    double lat,
    double lng,
    double centerLat,
    double centerLng,
    double zoom,
    Size viewport,
  ) {
    final cWx = lngToWorldX(centerLng, zoom);
    final cWy = latToWorldY(centerLat, zoom);
    final wx = lngToWorldX(lng, zoom);
    final wy = latToWorldY(lat, zoom);
    return Offset(
      wx - (cWx - viewport.width / 2.0),
      wy - (cWy - viewport.height / 2.0),
    );
  }

  static GeoCoord screenToLatLng(
    Offset pos,
    double centerLat,
    double centerLng,
    double zoom,
    Size viewport,
  ) {
    final topLeftWx = lngToWorldX(centerLng, zoom) - viewport.width / 2.0;
    final topLeftWy = latToWorldY(centerLat, zoom) - viewport.height / 2.0;
    return GeoCoord(
      lat: worldYToLat(topLeftWy + pos.dy, zoom),
      lng: worldXToLng(topLeftWx + pos.dx, zoom),
    );
  }
}

class GeoMapTileSpec {
  final String keyId;
  final String url;
  final double left;
  final double top;
  final double size;

  const GeoMapTileSpec({
    required this.keyId,
    required this.url,
    required this.left,
    required this.top,
    required this.size,
  });
}

class RenderedZonePolygon {
  final GeoZoneModel zone;
  final List<Offset> points;
  final Offset centroid;
  final Color color;
  final bool isHighlighted;

  const RenderedZonePolygon({
    required this.zone,
    required this.points,
    required this.centroid,
    required this.color,
    required this.isHighlighted,
  });
}

class RenderedZoneBubble {
  final GeoZoneModel zone;
  final Offset center;
  final Rect hitRect;
  final Color color;
  final String title;
  final String metricLabel;

  const RenderedZoneBubble({
    required this.zone,
    required this.center,
    required this.hitRect,
    required this.color,
    required this.title,
    required this.metricLabel,
  });
}

class RenderedSpoke {
  final Offset from;
  final Offset to;
  final Color color;
  final bool highlighted;

  const RenderedSpoke({
    required this.from,
    required this.to,
    required this.color,
    required this.highlighted,
  });
}

class GeoMapNode {
  final GeoLocationModel leadPin;
  final List<GeoLocationModel> members;
  final Offset center;
  final Color color;
  final double radius;
  final bool isSelected;
  final bool isHub;
  final bool isSuratHq;
  final bool isBranchPo;

  GeoMapNode({
    required this.leadPin,
    required this.members,
    required this.center,
    required this.color,
    required this.radius,
    required this.isSelected,
    required this.isHub,
    required this.isSuratHq,
    required this.isBranchPo,
  });

  bool get isCluster => members.length > 1;

  int get totalParties {
    var sum = 0;
    for (final m in members) {
      sum += m.totalErpParties;
    }
    return sum;
  }

  Rect get hitRect {
    final pad = isCluster ? 6.0 : 5.0;
    return Rect.fromCircle(center: center, radius: radius + pad);
  }
}

class GeoMapRenderScene {
  final List<RenderedZonePolygon> zonePolygons;
  final List<RenderedZoneBubble> zoneBubbles;
  final List<RenderedSpoke> spokes;
  final List<GeoMapNode> nodes;
  final bool isTier1Overview;

  const GeoMapRenderScene({
    required this.zonePolygons,
    required this.zoneBubbles,
    required this.spokes,
    required this.nodes,
    required this.isTier1Overview,
  });
}

class GeoMapHitTarget {
  final GeoMapNode? node;
  final RenderedZoneBubble? zoneBubble;

  const GeoMapHitTarget.node(this.node) : zoneBubble = null;
  const GeoMapHitTarget.zoneBubble(this.zoneBubble) : node = null;
}

class _NodeCandidate {
  final GeoLocationModel pin;
  final Offset pos;
  final bool isSelected;
  final bool isSurat;
  final int priority;

  const _NodeCandidate({
    required this.pin,
    required this.pos,
    required this.isSelected,
    required this.isSurat,
    required this.priority,
  });
}

/// Computes slippy raster tile coordinates and 3-tier clustered overlay scene.
class GeoMapSceneBuilder {
  static const GeoCoord suratHq = GeoCoord(lat: 21.1702, lng: 72.8311);

  static Color resolveZoneColor(String? token, shad.ColorScheme colors) {
    switch ((token ?? '').toLowerCase()) {
      case 'emerald':
        return DyColorSystem.emerald500;
      case 'cyan':
        return DyColorSystem.cyan500;
      case 'indigo':
        return DyColorSystem.indigo500;
      case 'orange':
        return DyColorSystem.orange500;
      case 'red':
        return DyColorSystem.red500;
      case 'pink':
        return DyColorSystem.pink500;
      default:
        return colors.primary;
    }
  }

  static List<GeoMapTileSpec> computeVisibleTiles({
    required Size viewport,
    required double centerLat,
    required double centerLng,
    required double zoom,
    required bool isDark,
  }) {
    final tileZ = zoom.floor().clamp(4, 14);
    final maxTileIdx = (1 << tileZ) - 1;
    final scaleDiff = math.pow(2.0, zoom - tileZ).toDouble();
    final tileScreenSize = MercatorProjection.tileSize * scaleDiff;

    final topLeftWx =
        MercatorProjection.lngToWorldX(centerLng, zoom) - viewport.width / 2.0;
    final topLeftWy =
        MercatorProjection.latToWorldY(centerLat, zoom) - viewport.height / 2.0;

    final minTx = ((topLeftWx / scaleDiff) / MercatorProjection.tileSize)
        .floor()
        .clamp(0, maxTileIdx);
    final maxTx = (((topLeftWx + viewport.width) / scaleDiff) /
            MercatorProjection.tileSize)
        .floor()
        .clamp(0, maxTileIdx);
    final minTy = ((topLeftWy / scaleDiff) / MercatorProjection.tileSize)
        .floor()
        .clamp(0, maxTileIdx);
    final maxTy = (((topLeftWy + viewport.height) / scaleDiff) /
            MercatorProjection.tileSize)
        .floor()
        .clamp(0, maxTileIdx);

    final specs = <GeoMapTileSpec>[];

    for (var tx = minTx; tx <= maxTx; tx++) {
      for (var ty = minTy; ty <= maxTy; ty++) {
        specs.add(GeoMapTileSpec(
          keyId: 'osm-$tileZ-$tx-$ty',
          url: 'https://tile.openstreetmap.org/$tileZ/$tx/$ty.png',
          left: tx * tileScreenSize - topLeftWx,
          top: ty * tileScreenSize - topLeftWy,
          size: tileScreenSize + 0.75,
        ));
      }
    }
    return specs;
  }

  static GeoMapRenderScene build({
    required Size viewport,
    required double centerLat,
    required double centerLng,
    required double zoom,
    required List<GeoZoneModel> zones,
    required List<GeoLocationModel> pins,
    required String selectedZoneCode,
    required GeoLocationModel? selectedLocation,
    required bool showZonesLayer,
    required bool showSpokesLayer,
    required shad.ColorScheme colors,
  }) {
    final zoneColorsByCode = <String, Color>{
      for (final z in zones) z.zoneCode: resolveZoneColor(z.colorToken, colors),
    };
    final isTier1Overview =
        zoom < 5.9 && selectedZoneCode.toUpperCase() == 'ALL';
    final viewportRect = Offset.zero & viewport;

    final zonePolygons = <RenderedZonePolygon>[];
    final zoneBubbles = <RenderedZoneBubble>[];
    final occupiedBubbles = <Rect>[];

    for (final z in zones) {
      final color = zoneColorsByCode[z.zoneCode] ?? colors.primary;
      final isHighlighted =
          selectedZoneCode == z.zoneCode || selectedZoneCode == 'ALL';
      final pts = <Offset>[
        for (final c in z.boundaryPoints)
          MercatorProjection.latLngToScreen(
            c.lat,
            c.lng,
            centerLat,
            centerLng,
            zoom,
            viewport,
          ),
      ];
      final centroid = (z.centerLat != 0.0 || z.centerLng != 0.0)
          ? MercatorProjection.latLngToScreen(
              z.centerLat,
              z.centerLng,
              centerLat,
              centerLng,
              zoom,
              viewport,
            )
          : (pts.isNotEmpty
              ? Offset(
                  pts.fold<double>(0.0, (a, b) => a + b.dx) / pts.length,
                  pts.fold<double>(0.0, (a, b) => a + b.dy) / pts.length,
                )
              : Offset.zero);

      if (showZonesLayer && pts.length >= 3) {
        zonePolygons.add(RenderedZonePolygon(
          zone: z,
          points: pts,
          centroid: centroid,
          color: color,
          isHighlighted: isHighlighted,
        ));
      }

      if (isTier1Overview &&
          centroid != Offset.zero &&
          viewportRect.inflate(40).contains(centroid)) {
        final shortTitle = z.zoneCode
            .replaceFirst('GJ-', '')
            .replaceFirst('MH-', '')
            .replaceFirst('EAST-', '')
            .replaceFirst('SOUTH-', '')
            .replaceFirst('NORTH-', '')
            .replaceFirst('CENTRAL-', '');
        final totalP = z.activeMastersCount + z.activeHasteCount;
        final metric = '$totalP P • ${z.activeLocationsCount}L';
        final bubbleW =
            math.max(92.0, math.max(shortTitle.length, metric.length) * 6.4 + 20);
        const bubbleH = 34.0;
        var rect = Rect.fromCenter(
          center: centroid,
          width: bubbleW,
          height: bubbleH,
        );
        if (occupiedBubbles.any((r) => r.overlaps(rect.inflate(4)))) {
          final nudged = Rect.fromCenter(
            center: centroid.translate(0, 38),
            width: bubbleW,
            height: bubbleH,
          );
          if (!occupiedBubbles.any((r) => r.overlaps(nudged.inflate(4)))) {
            rect = nudged;
          } else {
            continue;
          }
        }
        occupiedBubbles.add(rect);
        zoneBubbles.add(RenderedZoneBubble(
          zone: z,
          center: rect.center,
          hitRect: rect,
          color: color,
          title: shortTitle,
          metricLabel: metric,
        ));
      }
    }

    final selectedKey = selectedLocation?.locationKey;
    final viewBounds = viewportRect.inflate(70);
    final candidates = <_NodeCandidate>[];

    for (final p in pins) {
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) continue;
      final isSel = selectedKey != null && p.locationKey == selectedKey;
      final isSurat = p.placeName.toUpperCase() == 'SURAT';
      if (isTier1Overview && !isSel && !isSurat && p.totalErpParties < 35) {
        continue;
      }
      final pt = MercatorProjection.latLngToScreen(
        lat,
        lng,
        centerLat,
        centerLng,
        zoom,
        viewport,
      );
      if (!viewBounds.contains(pt)) continue;

      final priority = (isSel ? 1000000 : 0) +
          (isSurat ? 500000 : 0) +
          p.totalErpParties * 10 -
          (p.officeType == 'BO' ? 5 : 0);
      candidates.add(_NodeCandidate(
        pin: p,
        pos: pt,
        isSelected: isSel,
        isSurat: isSurat,
        priority: priority,
      ));
    }

    candidates.sort((a, b) => b.priority.compareTo(a.priority));

    final double clusterRadius;
    if (isTier1Overview) {
      clusterRadius = 38.0;
    } else if (zoom < 6.8) {
      clusterRadius = 42.0;
    } else if (zoom < 8.2) {
      clusterRadius = 32.0;
    } else if (zoom < 9.5) {
      clusterRadius = 22.0;
    } else if (zoom < 11.2) {
      clusterRadius = 15.0;
    } else {
      clusterRadius = 0.0;
    }

    final nodes = <GeoMapNode>[];
    final rSq = clusterRadius * clusterRadius;

    for (final c in candidates) {
      GeoMapNode? matched;
      if (clusterRadius > 0 && !c.isSelected && !c.isSurat) {
        var bestDistSq = rSq;
        for (final node in nodes) {
          if (node.isSelected || node.isSuratHq) continue;
          final dx = node.center.dx - c.pos.dx;
          final dy = node.center.dy - c.pos.dy;
          final d2 = dx * dx + dy * dy;
          if (d2 <= bestDistSq) {
            bestDistSq = d2;
            matched = node;
          }
        }
      }

      if (matched != null) {
        matched.members.add(c.pin);
      } else {
        final total = c.pin.totalErpParties;
        final isHub = total >= 15 || c.isSurat;
        final isBo = c.pin.officeType == 'BO';
        final color = zoneColorsByCode[c.pin.zoneCode ?? ''] ?? colors.primary;
        final baseR = c.isSelected
            ? 10.5
            : isBo
                ? 5.2
                : isHub
                    ? (7.0 + math.min(total / 24.0, 5.5))
                    : (4.8 + math.min(total / 16.0, 3.0));
        nodes.add(GeoMapNode(
          leadPin: c.pin,
          members: [c.pin],
          center: c.pos,
          color: color,
          radius: baseR,
          isSelected: c.isSelected,
          isHub: isHub,
          isSuratHq: c.isSurat,
          isBranchPo: isBo,
        ));
      }
    }

    final finalizedNodes = <GeoMapNode>[
      for (final n in nodes)
        GeoMapNode(
          leadPin: n.leadPin,
          members: n.members,
          center: n.center,
          color: n.color,
          radius: n.isCluster
              ? (13.0 + math.min(n.members.length * 0.45, 6.5))
              : n.radius,
          isSelected: n.isSelected,
          isHub: n.isHub,
          isSuratHq: n.isSuratHq,
          isBranchPo: n.isBranchPo,
        ),
    ];

    final spokes = <RenderedSpoke>[];
    if (showSpokesLayer) {
      final suratPt = MercatorProjection.latLngToScreen(
        suratHq.lat,
        suratHq.lng,
        centerLat,
        centerLng,
        zoom,
        viewport,
      );
      if (isTier1Overview) {
        for (final zp in zonePolygons) {
          if (zp.centroid == Offset.zero) continue;
          spokes.add(RenderedSpoke(
            from: suratPt,
            to: zp.centroid,
            color: zp.color,
            highlighted: false,
          ));
        }
      } else {
        for (final node in finalizedNodes.take(18)) {
          if (node.isSuratHq) continue;
          if (!node.isSelected && !node.isHub && !node.isCluster) continue;
          spokes.add(RenderedSpoke(
            from: suratPt,
            to: node.center,
            color: node.color,
            highlighted: node.isSelected,
          ));
        }
      }
    }

    return GeoMapRenderScene(
      zonePolygons: zonePolygons,
      zoneBubbles: zoneBubbles,
      spokes: spokes,
      nodes: finalizedNodes,
      isTier1Overview: isTier1Overview,
    );
  }

  static GeoMapHitTarget? hitTest(GeoMapRenderScene scene, Offset localPos) {
    for (final node in scene.nodes.reversed) {
      if (node.hitRect.contains(localPos)) {
        return GeoMapHitTarget.node(node);
      }
    }
    for (final b in scene.zoneBubbles.reversed) {
      if (b.hitRect.contains(localPos)) {
        return GeoMapHitTarget.zoneBubble(b);
      }
    }
    return null;
  }
}

class GeoSlippyOverlayPainter extends CustomPainter {
  final GeoMapRenderScene scene;
  final shad.ColorScheme colors;
  final bool isDark;
  final bool showLabelsLayer;
  final GeoMapNode? hoveredNode;
  final RenderedZoneBubble? hoveredBubble;

  const GeoSlippyOverlayPainter({
    required this.scene,
    required this.colors,
    required this.isDark,
    required this.showLabelsLayer,
    required this.hoveredNode,
    required this.hoveredBubble,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final zp in scene.zonePolygons) {
      final path = Path()..addPolygon(zp.points, true);
      final fillAlpha = zp.isHighlighted ? (isDark ? 0.14 : 0.10) : 0.03;
      final strokeAlpha = zp.isHighlighted ? 0.55 : 0.16;
      canvas.drawPath(
        path,
        Paint()
          ..color = zp.color.withValues(alpha: fillAlpha)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = zp.color.withValues(alpha: strokeAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = zp.isHighlighted ? 1.5 : 0.8,
      );
    }

    for (final s in scene.spokes) {
      final ctrl = Offset(
        (s.from.dx + s.to.dx) / 2.0,
        math.min(s.from.dy, s.to.dy) -
            math.min(60.0, (s.from - s.to).distance * 0.18),
      );
      final path = Path()
        ..moveTo(s.from.dx, s.from.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, s.to.dx, s.to.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color.withValues(alpha: s.highlighted ? 0.72 : 0.28)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = s.highlighted ? 2.1 : 1.1,
      );
    }

    final orderedNodes = <GeoMapNode>[
      ...scene.nodes.where((n) => !n.isSelected && n != hoveredNode),
      ...scene.nodes.where((n) => n.isSelected || n == hoveredNode),
    ];

    for (final node in orderedNodes) {
      final isHover = node == hoveredNode;
      if (node.isSelected || isHover || node.isSuratHq) {
        canvas.drawCircle(
          node.center,
          node.radius + (isHover ? 6.5 : 5.0),
          Paint()..color = node.color.withValues(alpha: 0.22),
        );
      }

      if (node.isCluster) {
        canvas.drawCircle(
          node.center,
          node.radius,
          Paint()..color = node.color,
        );
        canvas.drawCircle(
          node.center,
          node.radius,
          Paint()
            ..color = colors.card
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
        _drawCenteredText(
          canvas,
          '+${node.members.length - 1}',
          node.center,
          TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: node.members.length > 99 ? 9.0 : 10.0,
            fontWeight: FontWeight.w700,
          ),
        );
      } else {
        final fillColor = node.isSuratHq
            ? colors.primary
            : node.isBranchPo
                ? DyColorSystem.orange500
                : node.color;
        canvas.drawCircle(
          node.center,
          node.radius,
          Paint()..color = fillColor,
        );
        canvas.drawCircle(
          node.center,
          node.radius,
          Paint()
            ..color = node.isSelected ? colors.foreground : colors.card
            ..style = PaintingStyle.stroke
            ..strokeWidth = node.isSelected ? 2.4 : 1.5,
        );
      }
    }

    for (final b in scene.zoneBubbles) {
      final isHover = b == hoveredBubble;
      final rrect = RRect.fromRectAndRadius(
        b.hitRect,
        const Radius.circular(8.0),
      );
      canvas.drawRRect(
        rrect,
        Paint()..color = colors.card.withValues(alpha: isHover ? 0.98 : 0.91),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = b.color.withValues(alpha: isHover ? 1.0 : 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHover ? 2.0 : 1.3,
      );
      _drawCenteredText(
        canvas,
        b.title,
        b.center.translate(0, -6.5),
        TextStyle(
          color: colors.foreground,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      );
      _drawCenteredText(
        canvas,
        b.metricLabel,
        b.center.translate(0, 6.5),
        TextStyle(
          color: b.color,
          fontSize: 9.0,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (!showLabelsLayer) return;
    final occupied = <Rect>[
      for (final b in scene.zoneBubbles) b.hitRect.inflate(4),
    ];

    final labelOrdered = <GeoMapNode>[
      ...scene.nodes.where((n) => n.isSelected || n == hoveredNode),
      ...scene.nodes.where((n) => n.isSuratHq && !n.isSelected),
      ...scene.nodes.where(
        (n) => !n.isSelected && !n.isSuratHq && n != hoveredNode,
      ),
    ];

    for (final node in labelOrdered) {
      if (scene.isTier1Overview &&
          !node.isSelected &&
          !node.isSuratHq &&
          node != hoveredNode) {
        continue;
      }

      final text = node.isCluster
          ? '${node.leadPin.placeName} (${node.totalParties}P)'
          : (node.isHub || node.isSelected || node == hoveredNode)
              ? '${node.leadPin.placeName} (${node.leadPin.totalErpParties}P)'
              : node.leadPin.placeName;

      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: colors.foreground,
            fontSize: node.isSelected || node == hoveredNode ? 11.0 : 10.0,
            fontWeight:
                node.isSelected || node.isHub ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 165.0);

      final pillW = tp.width + 10.0;
      final pillH = tp.height + 4.0;
      final pillRect = Rect.fromLTWH(
        node.center.dx - pillW / 2.0,
        node.center.dy - node.radius - pillH - 4.0,
        pillW,
        pillH,
      );

      final forceDraw = node.isSelected || node == hoveredNode;
      if (!forceDraw) {
        if (pillRect.left < 4 ||
            pillRect.right > size.width - 4 ||
            pillRect.top < 4 ||
            pillRect.bottom > size.height - 40) {
          continue;
        }
        if (occupied.any((r) => r.overlaps(pillRect.inflate(2.5)))) {
          continue;
        }
      }

      occupied.add(pillRect);
      final bgRRect = RRect.fromRectAndRadius(
        pillRect,
        const Radius.circular(5.0),
      );
      canvas.drawRRect(
        bgRRect,
        Paint()
          ..color = colors.card.withValues(alpha: forceDraw ? 0.97 : 0.88),
      );
      canvas.drawRRect(
        bgRRect,
        Paint()
          ..color =
              forceDraw ? node.color : colors.border.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = forceDraw ? 1.4 : 0.8,
      );
      tp.paint(canvas, Offset(pillRect.left + 5.0, pillRect.top + 2.0));
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2.0, center.dy - tp.height / 2.0),
    );
  }

  @override
  bool shouldRepaint(covariant GeoSlippyOverlayPainter oldDelegate) => true;
}
