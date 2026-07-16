import 'package:flutter/material.dart';
import '../theme.dart';

/// [PlasmaPhysics] — Global animation curves and timing constants.
///
/// Centralizes physics tokens for Z-Axis transitions (Fades, Slides, Scales).
/// Strictly maps to [OrganismTheme] duration and curve tokens.
class PlasmaPhysics {
  static const Duration fast = OrganismTheme.durationFast;
  static const Duration standard = OrganismTheme.durationStandard;
  static const Duration slow = OrganismTheme.durationSlow;
  
  static const Curve curve = OrganismTheme.curveOut;

  static Widget fade({required Widget child, required Animation<double> animation}) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget slideUp({required Widget child, required Animation<double> animation}) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: child,
      ),
    );
  }

  static Widget scaleIn({required Widget child, required Animation<double> animation}) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: child,
      ),
    );
  }
}
