import 'package:flutter/material.dart';
import '../types.dart';
import '../../cells.dart';

/// [DomainStageBadge] — High-fidelity production status indicator.
///
/// Automatically maps EMPIRE codes (O3-O45) to readable stage names
/// and applies semantic sequencing colors (Blue for work, Green for done).
class DomainStageBadge extends StatelessWidget {
  final DomainProductionStage stage;
  final bool isCompleted;
  final bool isCompact;

  const DomainStageBadge({
    super.key,
    required this.stage,
    this.isCompleted = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Stage-specific glyph/color logic (The Vision)
    // Convert enum name to readable title (e.g. dispatchStitching -> Dispatch Stitching)
    final label = stage.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim();

    return CellBadge(
      text: isCompact ? stage.code : '${stage.code} — ${label.toUpperCase()}',
      variant: isCompleted ? CellBadgeVariant.success : CellBadgeVariant.primary,
    );
  }
}
