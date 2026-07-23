import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';
import '../cells.dart';

/// [OrganThreePaneCanvas] — Full-screen 3-column creation overlay for the ERP.
///
/// Designed for high-density batch creation workflows where the user needs
/// simultaneous visibility of: a selection list (left), a spec form (center),
/// and live computed output (right).
///
/// Layout:
/// ```
/// ┌──────────────────────────────────────────────────────────────┐
/// │  [X] Title                           [Primary CTA Button]    │ ← sticky header
/// │  ──────────────────────────────────────────────────────────  │
/// │  [stepBar]                                                    │ ← context selector row
/// ├──────────────────┬───────────────────────┬───────────────────┤
/// │  LEFT PANE       │  CENTER PANE          │  RIGHT PANE       │
/// │  (scrollable)    │  (scrollable)         │  (scrollable)     │
/// └──────────────────┴───────────────────────┴───────────────────┘
/// ```
///
/// All domain state is managed by the calling screen.
/// This organ is a pure layout shell.
class OrganThreePaneCanvas extends StatelessWidget {
  /// Page title shown in sticky header.
  final String title;

  /// Dismiss callback. Should prompt confirmation before closing.
  final VoidCallback? onClose;

  /// Primary action button in header (e.g. "Confirm Batch · 8 rolls").
  final Widget? trailingAction;

  /// Optional second row below the title — for Quality/Mill/Date step selectors.
  final Widget? stepBar;

  /// Left pane content — typically the selectable list of source records.
  final Widget leftPane;

  /// Center pane content — the spec entry form.
  final Widget centerPane;

  /// Right pane content — the live performance / computed output panel.
  final Widget rightPane;

  /// Center pane fixed width. Defaults to 340.
  final double centerPaneWidth;

  /// Right pane fixed width. Defaults to 300.
  final double rightPaneWidth;

  const OrganThreePaneCanvas({
    super.key,
    required this.title,
    this.onClose,
    required this.leftPane,
    required this.centerPane,
    required this.rightPane,
    this.trailingAction,
    this.stepBar,
    this.centerPaneWidth = 340,
    this.rightPaneWidth = 300,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── STICKY HEADER ─────────────────────────────────────────
          _ThreePaneHeader(
            title: title,
            onClose: onClose,
            trailingAction: trailingAction,
            stepBar: stepBar,
            colors: colors,
          ),

          // ── THREE-COLUMN BODY ──────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT PANE — FIFO list (Expanded)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colors.border),
                      ),
                    ),
                    child: leftPane,
                  ),
                ),

                // CENTER PANE — Spec Form (Fixed width)
                SizedBox(
                  width: centerPaneWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colors.border),
                      ),
                    ),
                    child: centerPane,
                  ),
                ),

                // RIGHT PANE — Live Performance (Fixed width)
                SizedBox(
                  width: rightPaneWidth,
                  child: rightPane,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── PRIVATE STICKY HEADER ────────────────────────────────────────────────────

class _ThreePaneHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final Widget? trailingAction;
  final Widget? stepBar;
  final OrganismColors colors;

  const _ThreePaneHeader({
    required this.title,
    this.onClose,
    required this.colors,
    this.trailingAction,
    this.stepBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OrganismTheme.spacingMd,
        vertical: OrganismTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: OrganismTheme.titleLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingAction != null) ...[
                const SizedBox(width: OrganismTheme.spacingMd),
                trailingAction!,
              ],
            ],
          ),

          // Step bar row (Quality → Mill → Date)
          if (stepBar != null) ...[
            const SizedBox(height: OrganismTheme.spacingMd),
            const CellDivider(),
            const SizedBox(height: OrganismTheme.spacingMd),
            stepBar!,
          ],
        ],
      ),
    );
  }
}

// ── STEP BAR HELPER ──────────────────────────────────────────────────────────

/// [ThreePaneStepBar] — Renders a horizontal "step flow" bar for context selectors.
///
/// Displays named steps connected by arrows. Each step slot accepts a child widget
/// (typically a dropdown or autocomplete). Steps with a `isComplete: true` flag
/// show a green indicator label.
class ThreePaneStepBar extends StatelessWidget {
  final List<ThreePaneStep> steps;

  const ThreePaneStepBar({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final List<Widget> items = [];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];

      items.add(
        Expanded(
          child: _StepSlot(step: step, colors: colors),
        ),
      );

      if (i < steps.length - 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingSm),
            child: Icon(LucideIcons.arrowRight, size: 16, color: colors.textMuted),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: items,
    );
  }
}

class ThreePaneStep {
  final String label;
  final Widget child;
  final bool isComplete;

  const ThreePaneStep({
    required this.label,
    required this.child,
    this.isComplete = false,
  });
}

class _StepSlot extends StatelessWidget {
  final ThreePaneStep step;
  final OrganismColors colors;

  const _StepSlot({required this.step, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.isComplete ? colors.success : colors.border,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              step.label,
              style: OrganismTheme.labelSmall(context).copyWith(
                color: step.isComplete ? colors.success : colors.textMuted,
                fontWeight: step.isComplete ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: OrganismTheme.spacingXs),
        step.child,
      ],
    );
  }
}
