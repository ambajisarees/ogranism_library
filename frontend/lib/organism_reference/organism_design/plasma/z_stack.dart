import 'package:flutter/material.dart';

/// [TissueZStack] — Unified depth management system.
///
/// Provides a mathematical coordinate space enforcing semantic depth layering.
/// Wraps native [Stack] behavior with Biological ERP physics and constraints.
class TissueZStack extends StatelessWidget {
  final List<TissueZLayer> children;
  final AlignmentGeometry alignment;
  final StackFit fit;

  const TissueZStack({
    super.key,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
  });

  @override
  Widget build(BuildContext context) {
    // We ensure children are rendered in Z-order priority
    final sortedLayers = List<TissueZLayer>.from(children)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Stack(
      alignment: alignment,
      fit: fit,
      children: sortedLayers.cast<Widget>(),
    );
  }
}

/// An individual atomic layer within a TissueZStack.
/// Encapsulates positioning and depth governance.
class TissueZLayer extends StatelessWidget {
  final Widget child;
  final int zIndex;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  const TissueZLayer({
    super.key,
    required this.child,
    this.zIndex = 0,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }
}
