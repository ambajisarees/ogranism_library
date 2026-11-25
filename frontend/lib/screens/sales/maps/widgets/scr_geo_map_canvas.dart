/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Option A Web Mercator (EPSG:3857) interactive Slippy Tile Map Canvas widget
     (`DyGeoTerritoryMapCanvas`) for `Sales -> Maps` (`ScrGeoZoneMap`).
   - Streams live Carto Voyager / Dark Matter `@2x` raster tiles with native
     `Image.network` + `gaplessPlayback`, pointer-anchored wheel zoom, drag/pinch
     panning, animated camera bounds fitting (`flyToZoneCode`), and HUD overlay.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Delegates coordinate math, 3-tier screen-space clustering, and custom vector
     overlay rendering to `scr_geo_map_projection.dart` (`GeoMapSceneBuilder` +
     `GeoSlippyOverlayPainter`) to stay lean and strictly under 1,000 lines.
   - Public `DyGeoTerritoryMapCanvasState` controller methods:
     * `flyToZoneCode(String zoneCode)`: smooth eased flight to Zone bounds or
       All-India reset when `'ALL'`.
     * `flyToLocation(GeoLocationModel loc, {double zoomScale})`: flies to pin
       at regional or village road level (supports legacy `zoomScale < 5` inputs).
     * `resetView()`: returns smoothly to national overview (`z ~ 4.65`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - First mount may receive `flyToZoneCode` before `LayoutBuilder` reports a
     non-empty viewport; deferred via `_pendingZoneFit` + post-frame callback.
   - Zero Material `Colors.*` or `Container` wrappers around `shadcn_flutter`
     controls; all floating HUD overlays use native `shad.OutlinedContainer` &
     `shad.*Button` tokens.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None active for canvas interaction; India Post `B.O` fan-out activates at
     `Z >= 9.5` and unclusters completely at `Z >= 11.2`.
================================================================================
*/

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/sales/model_geo_locations.dart';
import 'scr_geo_map_projection.dart';

/// Interactive Web Mercator Slippy Map Canvas for Sales Zones & Villages.
class DyGeoTerritoryMapCanvas extends StatefulWidget {
  final List<GeoZoneModel> zones;
  final List<GeoLocationModel> pins;
  final String selectedZoneCode;
  final GeoLocationModel? selectedLocation;
  final bool showZonesLayer;
  final bool showSpokesLayer;
  final bool showLabelsLayer;
  final ValueChanged<String> onSelectZoneCode;
  final ValueChanged<GeoLocationModel> onSelectLocation;
  final VoidCallback onToggleZonesLayer;
  final VoidCallback onToggleSpokesLayer;
  final VoidCallback onToggleLabelsLayer;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const DyGeoTerritoryMapCanvas({
    super.key,
    required this.zones,
    required this.pins,
    required this.selectedZoneCode,
    required this.selectedLocation,
    required this.showZonesLayer,
    required this.showSpokesLayer,
    required this.showLabelsLayer,
    required this.onSelectZoneCode,
    required this.onSelectLocation,
    required this.onToggleZonesLayer,
    required this.onToggleSpokesLayer,
    required this.onToggleLabelsLayer,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  State<DyGeoTerritoryMapCanvas> createState() =>
      DyGeoTerritoryMapCanvasState();
}

class DyGeoTerritoryMapCanvasState extends State<DyGeoTerritoryMapCanvas>
    with SingleTickerProviderStateMixin {
  static const double _defaultLat = 21.6;
  static const double _defaultLng = 79.0;
  static const double _defaultZoom = 4.65;
  static const Map<String, String> _osmHeaders = {
    'User-Agent': 'AmbajiSareesERP/1.0 (Windows Desktop GIS)',
  };
  static const ColorFilter _darkModeTileFilter = ColorFilter.matrix(<double>[
    0.4886, -1.2158, -0.1227, 0.0, 244.75,
    -0.3614, -0.3658, -0.1227, 0.0, 244.75,
    -0.3614, -1.2158, 0.7273, 0.0, 244.75,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ]);

  late final AnimationController _flightController;
  double _centerLat = _defaultLat;
  double _centerLng = _defaultLng;
  double _zoom = _defaultZoom;

  double _animStartLat = _defaultLat;
  double _animStartLng = _defaultLng;
  double _animStartZoom = _defaultZoom;
  double _animTargetLat = _defaultLat;
  double _animTargetLng = _defaultLng;
  double _animTargetZoom = _defaultZoom;

  Size _viewportSize = Size.zero;
  double _scaleStartZoom = _defaultZoom;
  Offset _lastFocalPoint = Offset.zero;
  Offset? _hoverPos;
  String? _pendingZoneFit;

  @override
  void initState() {
    super.initState();
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..addListener(_onFlightTick);
  }

  @override
  void dispose() {
    _flightController.removeListener(_onFlightTick);
    _flightController.dispose();
    super.dispose();
  }

  void _onFlightTick() {
    final t = Curves.easeOutCubic.transform(_flightController.value);
    if (!mounted) return;
    setState(() {
      _centerLat = (_animStartLat + (_animTargetLat - _animStartLat) * t)
          .clamp(MercatorProjection.minLat, MercatorProjection.maxLat);
      _centerLng = (_animStartLng + (_animTargetLng - _animStartLng) * t)
          .clamp(MercatorProjection.minLng, MercatorProjection.maxLng);
      _zoom = (_animStartZoom + (_animTargetZoom - _animStartZoom) * t)
          .clamp(MercatorProjection.minZoom, MercatorProjection.maxZoom);
    });
  }

  void _animateCameraTo(double lat, double lng, double zoom) {
    _animStartLat = _centerLat;
    _animStartLng = _centerLng;
    _animStartZoom = _zoom;
    _animTargetLat = lat.clamp(
      MercatorProjection.minLat,
      MercatorProjection.maxLat,
    );
    _animTargetLng = lng.clamp(
      MercatorProjection.minLng,
      MercatorProjection.maxLng,
    );
    _animTargetZoom = zoom.clamp(
      MercatorProjection.minZoom,
      MercatorProjection.maxZoom,
    );
    _flightController.forward(from: 0.0);
  }

  /// Fits camera bounds smoothly onto [zoneCode] (or resets to All-India).
  void flyToZoneCode(String zoneCode) {
    final code = zoneCode.trim().toUpperCase();
    if (code.isEmpty || code == 'ALL') {
      resetView();
      return;
    }
    if (_viewportSize.isEmpty) {
      _pendingZoneFit = code;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pending = _pendingZoneFit;
        _pendingZoneFit = null;
        if (mounted && pending != null) {
          flyToZoneCode(pending);
        }
      });
      return;
    }

    GeoZoneModel? targetZone;
    for (final z in widget.zones) {
      if (z.zoneCode.toUpperCase() == code) {
        targetZone = z;
        break;
      }
    }

    final pts = <GeoCoord>[
      if (targetZone != null) ...targetZone.boundaryPoints,
    ];
    for (final p in widget.pins) {
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat != null &&
          lng != null &&
          (p.zoneCode ?? '').toUpperCase() == code) {
        pts.add(GeoCoord(lat: lat, lng: lng));
      }
    }

    if (pts.isEmpty) {
      if (targetZone != null &&
          (targetZone.centerLat != 0.0 || targetZone.centerLng != 0.0)) {
        _animateCameraTo(targetZone.centerLat, targetZone.centerLng, 7.4);
      }
      return;
    }

    _fitBounds(pts, minFitZoom: 6.1, maxFitZoom: 9.2);
  }

  void _fitBounds(
    List<GeoCoord> pts, {
    double minFitZoom = 4.6,
    double maxFitZoom = 11.4,
  }) {
    if (pts.isEmpty) return;
    var minLat = pts.first.lat;
    var maxLat = pts.first.lat;
    var minLng = pts.first.lng;
    var maxLng = pts.first.lng;
    for (final c in pts) {
      if (c.lat < minLat) minLat = c.lat;
      if (c.lat > maxLat) maxLat = c.lat;
      if (c.lng < minLng) minLng = c.lng;
      if (c.lng > maxLng) maxLng = c.lng;
    }

    final midLat = (minLat + maxLat) / 2.0;
    final midLng = (minLng + maxLng) / 2.0;
    if (_viewportSize.isEmpty ||
        ((maxLat - minLat).abs() < 0.04 && (maxLng - minLng).abs() < 0.04)) {
      _animateCameraTo(midLat, midLng, math.min(9.5, maxFitZoom));
      return;
    }

    final usableW = math.max(120.0, _viewportSize.width * 0.72);
    final usableH = math.max(120.0, _viewportSize.height * 0.72);

    var bestZoom = maxFitZoom;
    for (var z = maxFitZoom; z >= minFitZoom; z -= 0.15) {
      final dx = (MercatorProjection.lngToWorldX(maxLng, z) -
              MercatorProjection.lngToWorldX(minLng, z))
          .abs();
      final dy = (MercatorProjection.latToWorldY(minLat, z) -
              MercatorProjection.latToWorldY(maxLat, z))
          .abs();
      if (dx <= usableW && dy <= usableH) {
        bestZoom = z;
        break;
      }
      bestZoom = z;
    }
    _animateCameraTo(midLat, midLng, bestZoom.clamp(minFitZoom, maxFitZoom));
  }

  /// Animates camera to center on a town or village post office.
  void flyToLocation(GeoLocationModel loc, {double zoomScale = 10.2}) {
    final lat = loc.latitude;
    final lng = loc.longitude;
    if (lat == null || lng == null) return;
    final targetZoom = zoomScale < 5.0
        ? (loc.officeType == 'BO' ? 11.4 : 10.2)
        : zoomScale.clamp(6.0, MercatorProjection.maxZoom);
    _animateCameraTo(lat, lng, math.max(_zoom, targetZoom));
  }

  /// Resets the camera back to All-India overview.
  void resetView() {
    if (_viewportSize.isEmpty) {
      _animateCameraTo(_defaultLat, _defaultLng, _defaultZoom);
      return;
    }
    final hFit = _viewportSize.height < 420 ? 4.35 : _defaultZoom;
    _animateCameraTo(_defaultLat, _defaultLng, hFit);
  }

  void _zoomAroundPoint(Offset focal, double targetZoom) {
    if (_viewportSize.isEmpty) return;
    _flightController.stop();
    final clampedZoom = targetZoom.clamp(
      MercatorProjection.minZoom,
      MercatorProjection.maxZoom,
    );
    final anchor = MercatorProjection.screenToLatLng(
      focal,
      _centerLat,
      _centerLng,
      _zoom,
      _viewportSize,
    );
    final anchorWx = MercatorProjection.lngToWorldX(anchor.lng, clampedZoom);
    final anchorWy = MercatorProjection.latToWorldY(anchor.lat, clampedZoom);
    final newCenterWx = anchorWx - focal.dx + _viewportSize.width / 2.0;
    final newCenterWy = anchorWy - focal.dy + _viewportSize.height / 2.0;
    setState(() {
      _zoom = clampedZoom;
      _centerLat = MercatorProjection.worldYToLat(newCenterWy, clampedZoom)
          .clamp(MercatorProjection.minLat, MercatorProjection.maxLat);
      _centerLng = MercatorProjection.worldXToLng(newCenterWx, clampedZoom)
          .clamp(MercatorProjection.minLng, MercatorProjection.maxLng);
    });
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _viewportSize.width > 0) {
      final step = event.scrollDelta.dy < 0 ? 0.55 : -0.55;
      _zoomAroundPoint(event.localPosition, _zoom + step);
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _flightController.stop();
    _scaleStartZoom = _zoom;
    _lastFocalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_viewportSize.isEmpty) return;
    final delta = details.localFocalPoint - _lastFocalPoint;
    _lastFocalPoint = details.localFocalPoint;

    var nextZoom = _zoom;
    var nextLat = _centerLat;
    var nextLng = _centerLng;

    if ((details.scale - 1.0).abs() > 0.002) {
      final candidateZoom =
          (_scaleStartZoom + math.log(details.scale) / math.ln2).clamp(
        MercatorProjection.minZoom,
        MercatorProjection.maxZoom,
      );
      final anchor = MercatorProjection.screenToLatLng(
        details.localFocalPoint,
        nextLat,
        nextLng,
        nextZoom,
        _viewportSize,
      );
      nextZoom = candidateZoom;
      final anchorWx = MercatorProjection.lngToWorldX(anchor.lng, nextZoom);
      final anchorWy = MercatorProjection.latToWorldY(anchor.lat, nextZoom);
      nextLng = MercatorProjection.worldXToLng(
        anchorWx - details.localFocalPoint.dx + _viewportSize.width / 2.0,
        nextZoom,
      );
      nextLat = MercatorProjection.worldYToLat(
        anchorWy - details.localFocalPoint.dy + _viewportSize.height / 2.0,
        nextZoom,
      );
    }

    if (delta.distanceSquared > 0.0) {
      final cWx = MercatorProjection.lngToWorldX(nextLng, nextZoom) - delta.dx;
      final cWy = MercatorProjection.latToWorldY(nextLat, nextZoom) - delta.dy;
      nextLng = MercatorProjection.worldXToLng(cWx, nextZoom);
      nextLat = MercatorProjection.worldYToLat(cWy, nextZoom);
    }

    setState(() {
      _zoom = nextZoom;
      _centerLat = nextLat.clamp(
        MercatorProjection.minLat,
        MercatorProjection.maxLat,
      );
      _centerLng = nextLng.clamp(
        MercatorProjection.minLng,
        MercatorProjection.maxLng,
      );
    });
  }

  void _handleTap(GeoMapRenderScene scene, Offset localPos) {
    final hit = GeoMapSceneBuilder.hitTest(scene, localPos);
    if (hit == null) return;
    final node = hit.node;
    if (node != null) {
      if (node.isCluster) {
        final memberCoords = <GeoCoord>[
          for (final m in node.members)
            if (m.latitude != null && m.longitude != null)
              GeoCoord(lat: m.latitude ?? 0.0, lng: m.longitude ?? 0.0),
        ];
        final nextZ = math.min(_zoom + 2.2, 11.8);
        if (memberCoords.length >= 2) {
          _fitBounds(
            memberCoords,
            minFitZoom: math.min(nextZ, 10.6),
            maxFitZoom: 12.2,
          );
        } else {
          _animateCameraTo(
            node.leadPin.latitude ?? _centerLat,
            node.leadPin.longitude ?? _centerLng,
            nextZ,
          );
        }
      } else {
        widget.onSelectLocation(node.leadPin);
      }
      return;
    }
    final bubble = hit.zoneBubble;
    if (bubble != null) {
      widget.onSelectZoneCode(bubble.zone.zoneCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final typography = theme.typography;
    final density = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;
    final tileBg = DyColorSystem.resolveRootBackground(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopHeaderBar(theme, colors, typography, density),
        Expanded(
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewport = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                _viewportSize = viewport;
                final tiles = GeoMapSceneBuilder.computeVisibleTiles(
                  viewport: viewport,
                  centerLat: _centerLat,
                  centerLng: _centerLng,
                  zoom: _zoom,
                  isDark: isDark,
                );
                final scene = GeoMapSceneBuilder.build(
                  viewport: viewport,
                  centerLat: _centerLat,
                  centerLng: _centerLng,
                  zoom: _zoom,
                  zones: widget.zones,
                  pins: widget.pins,
                  selectedZoneCode: widget.selectedZoneCode,
                  selectedLocation: widget.selectedLocation,
                  showZonesLayer: widget.showZonesLayer,
                  showSpokesLayer: widget.showSpokesLayer,
                  colors: colors,
                );
                final pos = _hoverPos;
                final hoverHit = pos != null
                    ? GeoMapSceneBuilder.hitTest(scene, pos)
                    : null;
                final activeClusters =
                    scene.nodes.where((n) => n.isCluster).length;

                final Widget tileLayer = Stack(
                  fit: StackFit.expand,
                  children: [
                    for (final tile in tiles)
                      Positioned(
                        key: ValueKey(tile.keyId),
                        left: tile.left,
                        top: tile.top,
                        width: tile.size,
                        height: tile.size,
                        child: Image.network(
                          tile.url,
                          headers: _osmHeaders,
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                  ],
                );

                return ColoredBox(
                  color: tileBg,
                  child: Listener(
                    onPointerSignal: _onPointerSignal,
                    child: MouseRegion(
                      cursor: hoverHit != null
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.grab,
                      onHover: (e) {
                        if (_hoverPos != e.localPosition) {
                          setState(() => _hoverPos = e.localPosition);
                        }
                      },
                      onExit: (_) {
                        if (_hoverPos != null) {
                          setState(() => _hoverPos = null);
                        }
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onTapUp: (d) => _handleTap(scene, d.localPosition),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned.fill(
                              child: isDark
                                  ? ColorFiltered(
                                      colorFilter: _darkModeTileFilter,
                                      child: tileLayer,
                                    )
                                  : tileLayer,
                            ),
                            RepaintBoundary(
                              child: CustomPaint(
                                size: viewport,
                                painter: GeoSlippyOverlayPainter(
                                  scene: scene,
                                  colors: colors,
                                  isDark: isDark,
                                  showLabelsLayer: widget.showLabelsLayer,
                                  hoveredNode: hoverHit?.node,
                                  hoveredBubble: hoverHit?.zoneBubble,
                                ),
                              ),
                            ),
                            Positioned(
                              top: density * 0.7,
                              right: density * 0.7,
                              child: _buildCameraControls(
                                theme,
                                colors,
                                typography,
                                density,
                                activeClusters,
                                scene.nodes.length,
                              ),
                            ),
                            if (hoverHit != null)
                              Positioned(
                                top: density * 0.7,
                                left: density * 0.7,
                                child: _buildHoverPill(
                                  theme,
                                  colors,
                                  typography,
                                  density,
                                  hoverHit,
                                ),
                              ),
                            Positioned(
                              left: density * 0.7,
                              right: density * 0.7,
                              bottom: density * 0.55,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: _buildZoneLegendRibbon(
                                      theme,
                                      colors,
                                      typography,
                                      density,
                                    ),
                                  ),
                                  const shad.DensityGap(0.5),
                                  _buildAttributionPill(
                                    theme,
                                    colors,
                                    typography,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeaderBar(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
    double density,
  ) {
    final lodLabel = _zoom < 5.9 && widget.selectedZoneCode == 'ALL'
        ? 'National Overview'
        : _zoom >= 11.2
            ? 'Street & Village B.O'
            : 'Regional Clusters';
    return shad.OutlinedContainer(
      backgroundColor: colors.card,
      borderColor: colors.border,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.symmetric(
        horizontal: density * 0.9,
        vertical: density * 0.5,
      ),
      child: Row(
        children: [
          Icon(shad.LucideIcons.compass, size: 15, color: colors.primary),
          const shad.DensityGap(0.45),
          Expanded(
            child: Row(
              children: [
                Text(
                  'All-India Sales Zones & Village Corridor Map',
                  style: typography.textSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const shad.DensityGap(0.6),
                Flexible(
                  child: Text(
                    '${widget.pins.length} markets • Z${_zoom.toStringAsFixed(1)} ($lodLabel)',
                    style: typography.xSmall.copyWith(
                      color: colors.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _buildLayerToggleChip(
            label: 'Zones',
            active: widget.showZonesLayer,
            onPressed: widget.onToggleZonesLayer,
          ),
          const shad.DensityGap(0.35),
          _buildLayerToggleChip(
            label: 'Spokes',
            active: widget.showSpokesLayer,
            onPressed: widget.onToggleSpokesLayer,
          ),
          const shad.DensityGap(0.35),
          _buildLayerToggleChip(
            label: 'Labels',
            active: widget.showLabelsLayer,
            onPressed: widget.onToggleLabelsLayer,
          ),
          const shad.DensityGap(0.45),
          shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: widget.onToggleZoom,
            child: Text(widget.isZoomed ? 'Restore' : 'Expand'),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerToggleChip({
    required String label,
    required bool active,
    required VoidCallback onPressed,
  }) {
    if (active) {
      return shad.PrimaryButton(
        size: shad.ButtonSize.small,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return shad.OutlineButton(
      size: shad.ButtonSize.small,
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildCameraControls(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
    double density,
    int activeClusters,
    int visibleNodes,
  ) {
    final centerPt = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    return shad.OutlinedContainer(
      backgroundColor: colors.card.withValues(alpha: 0.92),
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.all(density * 0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: () => _zoomAroundPoint(centerPt, _zoom + 0.9),
            child: const Icon(shad.LucideIcons.plus, size: 13),
          ),
          const shad.DensityGap(0.25),
          shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: () => _zoomAroundPoint(centerPt, _zoom - 0.9),
            child: const Text('−'),
          ),
          const shad.DensityGap(0.25),
          shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: () {
              if (widget.selectedZoneCode != 'ALL') {
                flyToZoneCode(widget.selectedZoneCode);
              } else {
                resetView();
              }
            },
            child: Text(
              widget.selectedZoneCode != 'ALL' ? 'Fit Zone' : 'India',
            ),
          ),
          const shad.DensityGap(0.25),
          Text(
            'Z${_zoom.toStringAsFixed(1)} • $visibleNodes'
            '${activeClusters > 0 ? ' ($activeClusters grp)' : ''}',
            style: typography.mono.copyWith(
              fontSize: 10,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoverPill(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
    double density,
    GeoMapHitTarget hit,
  ) {
    final String title;
    final String detail;
    final node = hit.node;
    final bubble = hit.zoneBubble;
    if (node != null) {
      if (node.isCluster) {
        title = '${node.leadPin.placeName} Cluster (+${node.members.length - 1} places)';
        detail = '${node.totalParties} ERP parties • Click to zoom & unpack';
      } else {
        title = '${node.leadPin.placeName} (${node.leadPin.pincode})';
        detail =
            '${node.leadPin.masterPartyCount}M / ${node.leadPin.hastePartyCount}H • '
            '${node.leadPin.district ?? node.leadPin.stateName}';
      }
    } else if (bubble != null) {
      final z = bubble.zone;
      title = z.zoneCode;
      detail =
          '${z.activeMastersCount} Masters • ${z.activeHasteCount} Haste • Click to zoom zone';
    } else {
      return const SizedBox.shrink();
    }

    return shad.OutlinedContainer(
      backgroundColor: colors.card.withValues(alpha: 0.94),
      borderColor: colors.primary.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: EdgeInsets.symmetric(
        horizontal: density * 0.65,
        vertical: density * 0.4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: typography.textSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
          Text(
            detail,
            style: typography.xSmall.copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneLegendRibbon(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
    double density,
  ) {
    return shad.OutlinedContainer(
      backgroundColor: colors.card.withValues(alpha: 0.90),
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      padding: EdgeInsets.symmetric(
        horizontal: density * 0.55,
        vertical: density * 0.35,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _zoneChip(
              label: 'All India',
              dotColor: colors.primary,
              isSelected: widget.selectedZoneCode == 'ALL',
              onTap: () => widget.onSelectZoneCode('ALL'),
            ),
            for (final z in widget.zones) ...[
              const shad.DensityGap(0.35),
              _zoneChip(
                label: '${z.zoneCode} (${z.activeLocationsCount})',
                dotColor: GeoMapSceneBuilder.resolveZoneColor(
                  z.colorToken,
                  colors,
                ),
                isSelected: widget.selectedZoneCode == z.zoneCode,
                onTap: () => widget.onSelectZoneCode(z.zoneCode),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _zoneChip({
    required String label,
    required Color dotColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final childRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          descendantsAreFocusable: false,
          child: SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
        ),
        const shad.DensityGap(0.35),
        Text(label),
      ],
    );
    if (isSelected) {
      return shad.PrimaryButton(
        size: shad.ButtonSize.small,
        onPressed: onTap,
        child: childRow,
      );
    }
    return shad.GhostButton(
      size: shad.ButtonSize.small,
      onPressed: onTap,
      child: childRow,
    );
  }

  Widget _buildAttributionPill(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    shad.Typography typography,
  ) {
    return shad.OutlinedContainer(
      backgroundColor: colors.card.withValues(alpha: 0.85),
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusSm),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Text(
        '© OpenStreetMap contributors',
        style: typography.xSmall.copyWith(
          fontSize: 10,
          color: colors.mutedForeground,
        ),
      ),
    );
  }
}
