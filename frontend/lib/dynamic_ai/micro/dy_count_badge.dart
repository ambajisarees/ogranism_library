/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC COUNT BADGE (dy_count_badge.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Pure passive, non-focusable count pill badge (`DyCountBadge`) used for
     notification/task counters on `DynamicHeaderTabs` & `DynamicMobileShell`
     and inline filter counters inside `MicroButton`.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Built strictly on `IgnorePointer` + `Focus` nullifier +
     `shad.OutlinedContainer` (zero `shad.Button` or `shad.Clickable` inside)
     so it never registers a `FocusNode` or inherits a duplicate focus ring
     when placed inside a parent button.
   - Uses `theme.radiusMd` and unscaled `theme.typography.xSmall` (`AdaptiveScaling`
     handles font scaling; paddings scale via `theme.scaling`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Pure stateless micro display widget with no state or network calls.
   - Overlay mode (`isOverlay: true`) clamps counts > 99 to `'99+'`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - None at this stage.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Pure non-focusable count pill built on [shad.OutlinedContainer].
class DyCountBadge extends StatelessWidget {
  final int count;
  final String? labelOverride;
  final bool isPrimary;
  final bool isOverlay;

  const DyCountBadge({
    super.key,
    required this.count,
    this.labelOverride,
    this.isPrimary = true,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = labelOverride ?? (isOverlay && count > 99 ? '99+' : '$count');
    if (displayText.isEmpty) return const SizedBox.shrink();

    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final scaling = theme.scaling;

    final Color bgColor = isPrimary ? colors.primary : colors.muted;
    final Color borderColor = isPrimary ? colors.primary : colors.border;
    final Color textColor =
        isPrimary ? colors.primaryForeground : colors.mutedForeground;

    final EdgeInsetsGeometry padding = isOverlay
        ? EdgeInsets.symmetric(
            horizontal: 4.5 * scaling,
            vertical: 1.5 * scaling,
          )
        : EdgeInsets.symmetric(
            horizontal: 6.0 * scaling,
            vertical: 2.0 * scaling,
          );

    return IgnorePointer(
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: false,
        child: shad.OutlinedContainer(
          theme: shad.OutlinedContainerTheme(
            backgroundColor: bgColor,
            borderColor: borderColor,
            borderWidth: isPrimary ? 0.0 : 1.0,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            padding: padding,
          ),
          child: Text(
            displayText,
            maxLines: 1,
            style: theme.typography.xSmall.copyWith(
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              height: 1.0,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
