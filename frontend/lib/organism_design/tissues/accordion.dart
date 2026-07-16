import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells/spatial.dart'; // Direct import for CellPad

/// [TissueAccordion] — Expandable content container molecule.
///
/// A clean, 1px bordered accordion matching [Shadcn]'s Collapsible pattern.
/// Handles vertical expansion physics with integrated rotation icons.


/// A clean, 1px bordered accordion matching Shadcn's standard Collapsible component. 
class TissueAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  const TissueAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<TissueAccordion> createState() => _TissueAccordionState();
}

class _TissueAccordionState extends State<TissueAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)), // Shadcn standard accordion only borders bottom usually
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: CellPad(
              verticalMultiplier: 1.0,
              horizontalMultiplier: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: OrganismTheme.titleMedium(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  )),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: OrganismTheme.durationStandard,
                    curve: OrganismTheme.curveStandard,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: OrganismTheme.iconSizeSm,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: CellPad(
              multiplier: 0.0,
              verticalMultiplier: 1.5,
              child: widget.content, // Renders the interior tissue children
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: OrganismTheme.durationStandard,
            sizeCurve: OrganismTheme.curveStandard,
          )
        ],
      ),
    );
  }
}
