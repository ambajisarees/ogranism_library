/// LLM NOTE: PageFormCanvas
/// - Level: Page-Level Form Layout Surface
/// - Purpose: 2-pane responsive form canvas framing main form content (flexed up to 1400px) alongside an optional fixed-width right sidebar (default 340px) and top header row.
/// - Widget Composition: LayoutBuilder -> Center -> ConstrainedBox(max 1400px) -> Column(Header + Row(Expanded(mainPane) + SizedBox(sidePane))).
/// - Scroll Control: Bounded layout when isScrollable=false allows inner table expanded scrolling; scrollable when isScrollable=true.

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// [PageFormCanvas] — Modular 2-pane form canvas container.
/// Places header as the top row inside the canvas, flexes [mainPane] within [maxWidth] (default 1400.0 px),
/// and sets fixed [sidePaneWidth] (default 340.0 px).
/// When [isScrollable] is false (default), [mainPane] is bounded so inner [Expanded] widgets (like tables) fit perfectly.
class PageFormCanvas extends StatelessWidget {
  final Widget? header;
  final Widget? mainPane;
  final Widget? sidePane;
  final Widget? child;
  final double maxWidth;
  final double sidePaneWidth;
  final double sidePaneGap;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;

  const PageFormCanvas({
    super.key,
    this.header,
    this.mainPane,
    this.sidePane,
    this.child,
    this.maxWidth = 1400.0,
    this.sidePaneWidth = 340.0,
    this.sidePaneGap = 16.0,
    this.padding = EdgeInsets.zero,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final effectiveMain = mainPane ?? child;

    Widget body;
    if (isScrollable) {
      body = SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              header!,
              const shad.DensityGap(shad.gapMd),
            ],
            if (effectiveMain != null && sidePane != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: effectiveMain),
                  SizedBox(width: sidePaneGap * theme.scaling),
                  SizedBox(
                    width: sidePaneWidth * theme.scaling,
                    child: sidePane!,
                  ),
                ],
              )
            else if (effectiveMain != null)
              effectiveMain,
          ],
        ),
      );
    } else {
      body = Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              header!,
              const shad.DensityGap(shad.gapMd),
            ],
            if (effectiveMain != null && sidePane != null)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: effectiveMain),
                    SizedBox(width: sidePaneGap * theme.scaling),
                    SizedBox(
                      width: sidePaneWidth * theme.scaling,
                      child: SingleChildScrollView(child: sidePane!),
                    ),
                  ],
                ),
              )
            else if (effectiveMain != null)
              Expanded(child: effectiveMain),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth * theme.scaling),
        child: body,
      ),
    );
  }
}
