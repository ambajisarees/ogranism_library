import 'package:flutter/material.dart';
import '../cells/alert.dart'; // Direct import for CellAlert
import '../cells/badge.dart'; // Direct import for CellBadgeVariant

/// [TissueAlert] — Standardized Alert banner molecule.
///
/// A semantic wrapper for [CellAlert], providing a consistent molecule-level 
/// interface for system feedback banners across the ERP.


/// Standardized Alert banners for system feedback.
class TissueAlert extends StatelessWidget {
  final String title;
  final String? message;
  final CellBadgeVariant variant; 
  final IconData icon;

  const TissueAlert({
    super.key,
    required this.title,
    this.message,
    this.variant = CellBadgeVariant.secondary,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CellAlert(
      title: title,
      message: message,
      icon: icon,
      variant: variant,
    );
  }
}
