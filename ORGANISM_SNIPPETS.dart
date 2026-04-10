// organism_snippets.dart
// HIGH-FIDELITY REFERENCE SNIPPETS FOR AI PAIR PROGRAMMING

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

/* 
  --------------------------------------------------------------------------
  1. PLASMA REFERENCE (Theme Structure)
  --------------------------------------------------------------------------
*/

class OrganismTheme {
  // Primary Bordeaux
  static const Color primary = Color(0xFF800020);
  static const Color primaryLight = Color(0xFF9E1B32);
  
  // Stone Scale (SaaS Grays)
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone900 = Color(0xFF1C1917);

  // Icon Sizing Tokens (Lucide Enforced)
  static const double iconSizeXs = 12.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 20.0;
  static const double iconSizeLg = 28.0;

  // Typography (Enforced Inter/Mono)
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: stone900,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    color: stone600,
  );
}

/* 
  --------------------------------------------------------------------------
  2. CELL PATTERN (Atomic: State-aware, Headless, Minimalist)
  --------------------------------------------------------------------------
*/

class ReferenceCellButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const ReferenceCellButton({super.key, required this.text, this.icon, this.onPressed});

  @override
  State<ReferenceCellButton> createState() => _ReferenceCellButtonState();
}

class _ReferenceCellButtonState extends State<ReferenceCellButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled ? OrganismTheme.stone200 : (_isHovered ? OrganismTheme.primaryLight : OrganismTheme.primary),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered && !isDisabled ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: OrganismTheme.iconSizeSm, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

/* 
  --------------------------------------------------------------------------
  3. TISSUE PATTERN (Molecular: Grouping Cells into Data Layouts)
  --------------------------------------------------------------------------
*/

class ReferenceTissueCard extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const ReferenceTissueCard({super.key, required this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OrganismTheme.stone200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: OrganismTheme.titleMedium),
                if (actions != null) Row(children: actions!),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/* 
  --------------------------------------------------------------------------
  4. ORGAN PATTERN (Structural: Large shells managing global state)
  --------------------------------------------------------------------------
*/

class ReferenceOrganShell extends StatefulWidget {
  final Widget child;
  const ReferenceOrganShell({super.key, required this.child});

  @override
  State<ReferenceOrganShell> createState() => _ReferenceOrganShellState();
}

class _ReferenceOrganShellState extends State<ReferenceOrganShell> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // The Kinetic Organ (NavBoat pattern)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _isCollapsed ? 84 : 240,
            color: OrganismTheme.stone50,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(_isCollapsed ? LucideIcons.chevronRight : LucideIcons.chevronLeft),
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
                const Spacer(),
                // Navigation items would go here
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // System Content (Pages)
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
