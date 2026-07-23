import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/divider.dart'; // Direct import for CellDivider
import '../cells/button.dart';  // Direct import for CellButton
import '../cells/spatial.dart'; // Direct import for CellGap/CellPad
import 'physics.dart';

/// [PlasmaDialog] — Modal overlay system for focused interactions.
///
/// Implements high-fidelity modal windows with standardized headers, 
/// content scrolling, and action rows. Bypasses Material dialog defaults.

/// A standard Modal Dialog mapping to the Shadcn anatomy.
/// Uses showGeneralDialog to bypass standard Material themes.
class PlasmaDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required Widget content,
    List<Widget>? actions,
  }) {
    final capturedTheme = Theme.of(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PlasmaDialog',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: PlasmaPhysics.fast,
      pageBuilder: (context, anim1, anim2) {
        final colors = capturedTheme.extension<OrganismColors>() ?? OrganismColors.light();
        return Theme(
          data: capturedTheme,
          child: Center(
            child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              constraints: const BoxConstraints(maxHeight: 800),
              margin: const EdgeInsets.all(OrganismTheme.spacing2Xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: OrganismTheme.borderLg,
                border: Border.all(color: colors.border),
                boxShadow: OrganismTheme.shadowLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  CellPad(
                    multiplier: 2.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: OrganismTheme.titleLarge(context)),
                        if (description != null) ...[
                          CellGap.small,
                          Text(description, style: OrganismTheme.bodyMedium(context)),
                        ],
                      ],
                    ),
                  ),
                  const CellDivider(),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: CellPad(
                        multiplier: 2.0,
                        child: content,
                      ),
                    ),
                  ),
                  if (actions != null) ...[
                    const CellDivider(),
                    CellPad(
                      multiplier: 1.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) CellGap.standard,
                            actions[i],
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
      transitionBuilder: (context, anim1, anim2, child) {
        return PlasmaPhysics.scaleIn(child: child, animation: anim1);
      },
    );
  }
}

/// A semantic Destructive/Warning modal.
class PlasmaAlertDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return PlasmaDialog.show<bool>(
      context: context,
      title: title,
      description: message,
      content: const SizedBox.shrink(),
      actions: [
        CellButton(
          text: cancelText,
          variant: CellButtonVariant.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        CellButton(
          text: confirmText,
          variant: isDestructive ? CellButtonVariant.destructive : CellButtonVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
