/// LLM NOTE: PageHeader
/// - Level: Page Top Bar Component
/// - Role: Modular top page header with 3 operational modes (`standard`, `adding`, `editing`), optional document ID badge, back button support, and trailing actions.
/// - Widget Composition: Row -> [Back MicroButton] + [Title Text + Doc ID Badge] + Spacer + [Trailing Action Buttons].
/// - Specifications:
///   - Surface: Clean flush top row
///   - Title Typography: `theme.typography.h2` (bold, letterSpacing: -0.5)
///   - Document ID: `shad.Badge` pill displaying active record ID (e.g. `#PO-2026-004`)
///   - 3 Modes: `standard` (view mode), `adding` (creation header with Discard/Save), `editing` (modification header)
///   - Action limit: At most 4 trailing action widgets (`actions.length <= 4`)

library;

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Operational mode for [PageHeader]
enum PageHeaderMode { standard, adding, editing }

/// [PageHeader] - Modular top page header with 3 operational modes
/// (`standard`, `adding`, `editing`), auto-configured action buttons, and back button support.
class PageHeader extends StatelessWidget {
  final String title;
  final PageHeaderMode mode;
  final String? moduleName;
  final String? docId;

  // Callbacks for adding/editing modes
  final VoidCallback? onBack;
  final VoidCallback? onDiscard;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onConfirm;
  final bool isSaving;

  // Optional Trailing Actions (overrides auto-generated buttons if provided)
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.mode = PageHeaderMode.standard,
    this.moduleName,
    this.docId,
    this.onBack,
    this.onDiscard,
    this.onSaveDraft,
    this.onConfirm,
    this.isSaving = false,
    this.actions = const [],
  }) : assert(actions.length <= 4, 'PageHeader can take at most 4 actions');

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);

    // Resolve Title
    String titleText = title;
    if (mode == PageHeaderMode.adding) {
      titleText = moduleName != null ? 'Add $moduleName' : 'Add $title';
    } else if (mode == PageHeaderMode.editing) {
      titleText = docId ?? title;
    }

    final bool showBackButton =
        mode == PageHeaderMode.adding || mode == PageHeaderMode.editing || onBack != null;

    // Resolve Trailing Action Buttons
    List<Widget> resolvedActions = List.from(actions);
    if (resolvedActions.isEmpty) {
      if (mode == PageHeaderMode.adding) {
        resolvedActions = [
          shad.OutlineButton(
            onPressed: onDiscard ?? onBack,
            child: const Text('Discard'),
          ),
          shad.OutlineButton(
            onPressed: onSaveDraft,
            child: const Text('Save Draft'),
          ),
          shad.PrimaryButton(
            onPressed: isSaving ? null : onConfirm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: shad.CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(shad.LucideIcons.check),
                const shad.DensityGap(shad.gapSm),
                Text(isSaving ? 'Saving...' : 'Confirm'),
              ],
            ),
          ),
        ];
      } else if (mode == PageHeaderMode.editing) {
        resolvedActions = [
          shad.OutlineButton(
            onPressed: onDiscard ?? onBack,
            child: const Text('Discard'),
          ),
          shad.PrimaryButton(
            onPressed: isSaving ? null : onConfirm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: shad.CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(shad.LucideIcons.check),
                const shad.DensityGap(shad.gapSm),
                Text(isSaving ? 'Saving...' : 'Confirm'),
              ],
            ),
          ),
        ];
      }
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Prepend Back Arrow for Adding / Editing modes or when onBack is provided
          if (showBackButton) ...[
            shad.IconButton.ghost(
              icon: const Icon(shad.LucideIcons.arrowLeft),
              onPressed: onBack ?? onDiscard,
            ),
            const shad.DensityGap(shad.gapSm),
          ],

          // Title Text
          Text(
            titleText,
            style: theme.typography.h2.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          // Optional Document ID Badge
          if (docId != null && mode == PageHeaderMode.standard) ...[
            const shad.DensityGap(shad.gapSm),
            shad.SecondaryBadge(
              child: Text(
                docId!,
                style: theme.typography.mono.copyWith(
                  fontSize: 12 * theme.scaling,
                ),
              ),
            ),
          ],

          // Spacer (Pushes trailing actions to far right)
          const Spacer(),

          // Trailing Actions Row
          if (resolvedActions.isNotEmpty) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: resolvedActions.map((act) {
                return Padding(
                  padding: EdgeInsets.only(left: 8 * theme.scaling),
                  child: act,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
