import 'package:flutter/material.dart';
import '../theme.dart';
import '../cells/spatial.dart';
import '../cells/button.dart';

class TissueWizardStep {
  final String title;
  final Widget content;
  final Future<bool> Function()? onValidate;

  const TissueWizardStep({
    required this.title,
    required this.content,
    this.onValidate,
  });
}

class TissueWizard extends StatefulWidget {
  final List<TissueWizardStep> steps;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  const TissueWizard({
    super.key,
    required this.steps,
    required this.onFinish,
    required this.onCancel,
  });

  @override
  State<TissueWizard> createState() => _TissueWizardState();
}

class _TissueWizardState extends State<TissueWizard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;

  Future<void> _nextStep() async {
    if (_currentIndex == widget.steps.length - 1) {
      widget.onFinish();
      return;
    }

    final step = widget.steps[_currentIndex];
    if (step.onValidate != null) {
      setState(() => _isLoading = true);
      final isValid = await step.onValidate!();
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!isValid) return;
    }

    setState(() => _currentIndex++);
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStepper(OrganismColors colors) {
    return Row(
      children: List.generate(widget.steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line separator
          final stepIndex = index ~/ 2;
          final isCompleted = _currentIndex > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? colors.primary : colors.border,
              margin: const EdgeInsets.symmetric(horizontal: OrganismTheme.spacingSm),
            ),
          );
        } else {
          // Node
          final stepIndex = index ~/ 2;
          final isActive = _currentIndex == stepIndex;
          final isCompleted = _currentIndex > stepIndex;

          Color bgColor = colors.surfaceSubtle;
          Color textColor = colors.textMuted;
          Color borderColor = colors.border;

          if (isActive) {
            bgColor = colors.primary;
            textColor = colors.surface;
            borderColor = colors.primary;
          } else if (isCompleted) {
            bgColor = colors.primary.withValues(alpha: 0.1);
            textColor = colors.primary;
            borderColor = colors.primary;
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: OrganismTheme.buttonHeightCompact * 0.75,
                height: OrganismTheme.buttonHeightCompact * 0.75,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${stepIndex + 1}',
                  style: OrganismTheme.labelMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 12, // Using labelMedium but keeping 12 specifically for node bubbles
                  ),
                ),
              ),
              CellGap.small,
              Text(
                widget.steps[stepIndex].title,
                style: OrganismTheme.labelMedium(context).copyWith(
                  color: isActive || isCompleted ? colors.textPrimary : colors.textMuted,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepper(colors),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.steps.map((e) => e.content).toList(),
          ),
        ),
        const SizedBox(height: OrganismTheme.spacingLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex == 0)
              CellButton(
                text: 'Cancel',
                variant: CellButtonVariant.ghost,
                onPressed: widget.onCancel,
              )
            else
              CellButton(
                text: 'Back',
                variant: CellButtonVariant.outline,
                onPressed: _isLoading ? null : _prevStep,
              ),
            CellButton(
              text: _currentIndex == widget.steps.length - 1 ? 'Finish' : 'Next',
              variant: CellButtonVariant.primary,
              isLoading: _isLoading,
              onPressed: _nextStep,
            ),
          ],
        ),
      ],
    );
  }
}
