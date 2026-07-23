import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells.dart';
import 'physics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PlasmaDrawer {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? subtitle,
    double width = 450,
  }) {
    final capturedTheme = Theme.of(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PlasmaDrawer',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: PlasmaPhysics.fast,
      pageBuilder: (context, anim1, anim2) {
        final colors = capturedTheme.extension<OrganismColors>() ?? OrganismColors.light();
        return Theme(
          data: capturedTheme,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(color: colors.overlay.withValues(alpha: 0.1), blurRadius: 24, offset: Offset(-8, 0)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: OrganismTheme.titleMedium(context)),
                                if (subtitle != null) ...[
                                  const CellGap(0.25),
                                  Text(subtitle, style: OrganismTheme.bodySmall(context).copyWith(color: colors.textSecondary)),
                                ]
                              ],
                            ),
                          ),
                          CellButton(
                            icon: LucideIcons.x,
                            variant: CellButtonVariant.ghost,
                            isCompact: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                        child: content,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuint)),
          child: child,
        );
      },
    );
  }
}
