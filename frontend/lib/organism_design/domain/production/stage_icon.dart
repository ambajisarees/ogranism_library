import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../types.dart';
import '../../theme.dart';

/// [DomainStageIcon] — Stage-specific visual identifier.
///
/// Maps EMPIRE stages to Lucide glyphs for consistent icon-driven navigation.
class DomainStageIcon extends StatelessWidget {
  final DomainProductionStage stage;
  final double? size;
  final Color? color;

  const DomainStageIcon({
    super.key,
    required this.stage,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    
    switch (stage) {
      case DomainProductionStage.multiCutting:
        icon = LucideIcons.scissors;
        break;
      case DomainProductionStage.workInHouse:
        icon = LucideIcons.home;
        break;
      case DomainProductionStage.dispatchStitching:
        icon = LucideIcons.externalLink;
        break;
      case DomainProductionStage.receiveStitching:
        icon = LucideIcons.download;
        break;
      case DomainProductionStage.dispatchDiamond:
        icon = LucideIcons.gem;
        break;
      case DomainProductionStage.receiveDiamond:
        icon = LucideIcons.archive;
        break;
      case DomainProductionStage.dispatchEmb:
        icon = LucideIcons.palette;
        break;
      case DomainProductionStage.receiveEmb:
        icon = LucideIcons.checkCircle;
        break;
      case DomainProductionStage.dispatchCharak:
        icon = LucideIcons.wind;
        break;
      case DomainProductionStage.receiveCharak:
        icon = LucideIcons.packageCheck;
        break;
      case DomainProductionStage.readyProduct:
        icon = LucideIcons.shoppingBag;
        break;
    }

    return Icon(
      icon,
      size: size ?? OrganismTheme.iconSizeMd,
      color: color ?? OrganismTheme.colorsOf(context).primary,
    );
  }
}
