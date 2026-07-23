import 'package:flutter/material.dart';
import '../theme.dart';

/// [CellSkeleton] — Structural shimmer loading atom.
///
/// Renders an animated linear gradient overlay representing a content block 
/// in an asynchronous loading state. Customizable via [width] and [height].

/// True structural Shimmer skeleton primitive with full shimmering animation.
class CellSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CellSkeleton({super.key, this.width, this.height, this.borderRadius});

  @override
  State<CellSkeleton> createState() => _CellSkeletonState();
}

class _CellSkeletonState extends State<CellSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                colors.skeletonHighlight.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-2.0, -0.3),
              end: const Alignment(2.0, 0.3),
              transform: _TranslateGradient(value: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.skeletonBase,
          borderRadius: widget.borderRadius ?? OrganismTheme.borderSm,
        ),
      ),
    );
  }
}

class _TranslateGradient extends GradientTransform {
  final double value;
  const _TranslateGradient({required this.value});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Translate the gradient from left to right smoothly across the block.
    final double translation = (value * 3.0) - 1.5; 
    return Matrix4.translationValues(bounds.width * translation, 0, 0);
  }
}
