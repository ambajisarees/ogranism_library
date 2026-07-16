import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../../tissues.dart';
import '../../organs.dart';
import '../widgets/library_section.dart';

/// Full cells catalogue — all 33 active cells, grouped by function.
class CellsView extends StatefulWidget {
  const CellsView({super.key});

  @override
  State<CellsView> createState() => _CellsViewState();
}

class _CellsViewState extends State<CellsView> {
  // State for interactive demos
  bool _checkboxVal = true;
  bool _switchVal = true;
  String _radioVal = 'mts';
  double _sliderVal = 0.6;
  String? _comboVal;
  String? _toggleVal = 'grid';
  final List<String> _chips = ['Dola Silk', 'Vichitra'];

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildButtonsSection(context, colors),
        _buildInputsSection(context, colors),
        _buildSelectionControlsSection(context, colors),
        _buildDataEntrySection(context, colors),
        _buildDisplaySection(context, colors),
        _buildFormattingAtomsSection(context, colors),
        _buildStructuralSection(context, colors),
        _buildNavigationSection(context, colors),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 1 — BUTTONS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildButtonsSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Action Dynamics',
      subtitle:
          'CellButton, CellMultiButton — Button variants and interaction states.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _subLabel(context, colors, 'Standard Variants (40px) — button.dart'),
          const SizedBox(height: OrganismTheme.spacingMd),
          LibraryComponentDoc(
            filePath: 'organism_design/cells/button.dart',
            description:
                'Primary action atom. 5 semantic variants × 2 sizes. Supports leading/trailing icons, loading state, disabled.',
            child: Wrap(
              spacing: OrganismTheme.spacingMd,
              runSpacing: OrganismTheme.spacingMd,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CellButton(
                    text: 'Primary',
                    variant: CellButtonVariant.primary,
                    onPressed: () {}),
                CellButton(
                    text: 'Secondary',
                    variant: CellButtonVariant.secondary,
                    onPressed: () {}),
                CellButton(
                    text: 'Destructive',
                    variant: CellButtonVariant.destructive,
                    icon: LucideIcons.trash2,
                    onPressed: () {}),
                CellButton(
                    text: 'Outline',
                    variant: CellButtonVariant.outline,
                    onPressed: () {}),
                CellButton(
                    text: 'Ghost',
                    variant: CellButtonVariant.ghost,
                    onPressed: () {}),
                const CellButton(
                    text: 'Disabled',
                    variant: CellButtonVariant.primary,
                    onPressed: null),
              ],
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingXl),
          _subLabel(context, colors, 'Compact 32px + Icon Composition'),
          const SizedBox(height: OrganismTheme.spacingMd),
          LibraryComponentDoc(
            filePath: 'organism_design/cells/button.dart',
            description:
                'isCompact: true reduces height to 32px. Icon-only uses icon: without text.',
            child: Wrap(
              spacing: OrganismTheme.spacingMd,
              runSpacing: OrganismTheme.spacingMd,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CellButton(
                    text: 'Compact Primary', isCompact: true, onPressed: () {}),
                CellButton(
                    text: 'Leading Icon',
                    icon: LucideIcons.plus,
                    isCompact: true,
                    onPressed: () {}),
                CellButton(
                    text: 'Trailing Icon',
                    trailingIcon: LucideIcons.externalLink,
                    isCompact: true,
                    onPressed: () {}),
                CellButton(
                    icon: LucideIcons.bell,
                    isCompact: true,
                    onPressed: () {}),
                CellButton(
                    icon: LucideIcons.search,
                    variant: CellButtonVariant.outline,
                    isCompact: true,
                    onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingXl),
          _subLabel(context, colors, 'Segmented Groups — multi_button.dart'),
          const SizedBox(height: OrganismTheme.spacingMd),
          LibraryComponentDoc(
            filePath: 'organism_design/cells/multi_button.dart',
            description:
                'CellMultiButton merges adjacent borders for tight button groups. Wrap CellButton children directly.',
            child: CellMultiButton(
              children: [
                CellButton(
                    icon: LucideIcons.alignLeft,
                    variant: CellButtonVariant.ghost,
                    isCompact: true,
                    onPressed: () {}),
                CellButton(
                    icon: LucideIcons.alignCenter,
                    variant: CellButtonVariant.ghost,
                    isCompact: true,
                    onPressed: () {}),
                CellButton(
                    icon: LucideIcons.alignRight,
                    variant: CellButtonVariant.ghost,
                    isCompact: true,
                    onPressed: () {}),
                CellButton(
                    icon: LucideIcons.alignJustify,
                    variant: CellButtonVariant.ghost,
                    isCompact: true,
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 2 — TEXT INPUTS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildInputsSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Text & Numeric Entry',
      subtitle:
          'CellInput, CellInputNumber — Focus mechanics, validation states, Indian lakhs formatting.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryComponentDoc(
            filePath: 'organism_design/cells/input.dart',
            description:
                'Universal text field. Supports prefix/suffix icons, search mode, multiline, error state, compact density.',
            child: Wrap(
              spacing: OrganismTheme.spacingXl,
              runSpacing: OrganismTheme.spacingLg,
              children: [
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subLabel(context, colors, 'Standard + Affix Icons'),
                      const SizedBox(height: OrganismTheme.spacingXs),
                      const CellInput(
                        placeholder: 'Enter portal URL',
                        prefixIcon: LucideIcons.globe,
                        suffixIcon: LucideIcons.externalLink,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subLabel(
                          context, colors, 'Compact Search (isCompact: true)'),
                      const SizedBox(height: OrganismTheme.spacingXs),
                      const CellInput(
                        placeholder: 'Search grid...',
                        isSearch: true,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subLabel(context, colors, 'Multiline Note Field'),
                      const SizedBox(height: OrganismTheme.spacingXs),
                      const CellInput(
                        placeholder: 'Enter party notes...',
                        minLines: 3,
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subLabel(context, colors, 'Validation Error State'),
                      const SizedBox(height: OrganismTheme.spacingXs),
                      const CellInput(
                          placeholder: 'Field required', hasError: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingXl),
          LibraryComponentDoc(
            filePath: 'organism_design/cells/input_number.dart',
            description:
                'Numeric-only input. On blur, formats to Indian Lakhs locale (e.g. 1,45,000.00). '
                'initialValue sets the starting number.',
            child: Wrap(
            spacing: OrganismTheme.spacingLg,
            runSpacing: OrganismTheme.spacingLg,
            children: [
              SizedBox(
                width: 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(
                        context, colors, 'CellInputNumber — Indian Locale'),
                    const SizedBox(height: OrganismTheme.spacingXs),
                    const CellInputNumber(
                      initialValue: 145000,
                      placeholder: 'Enter rate...',
                      isCompact: true,
                    ),
                    const SizedBox(height: OrganismTheme.spacingXs),
                    Text('Blur → 1,45,000.00',
                        style: OrganismTheme.bodySmall(context)
                            .copyWith(color: colors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 3 — SELECTION CONTROLS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSelectionControlsSection(
      BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Selection Controls',
      subtitle:
          'CellCheckbox, CellSwitch, CellRadio, CellSlider, CellToggleGroup — Boolean and scalar pickers.',
      child: Wrap(
        spacing: OrganismTheme.spacing2Xl,
        runSpacing: OrganismTheme.spacingXl,
        children: [
          // Checkbox
          LibraryComponentDoc(
            filePath: 'organism_design/cells/checkbox.dart',
            description:
                'Three-state boolean box. Supports indeterminate (null), disabled state.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellCheckbox'),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CellCheckbox(
                      value: _checkboxVal,
                      onChanged: (v) => setState(() => _checkboxVal = v ?? false),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellCheckbox(value: true),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellCheckbox(value: false, isDisabled: true),
                  ],
                ),
              ],
            ),
          ),
          // Switch
          LibraryComponentDoc(
            filePath: 'organism_design/cells/switch.dart',
            description:
                'Capsule sliding binary toggle for settings and feature flags.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellSwitch'),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CellSwitch(
                      value: _switchVal,
                      onChanged: (v) => setState(() => _switchVal = v),
                    ),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellSwitch(value: false),
                  ],
                ),
              ],
            ),
          ),
          // Radio
          LibraryComponentDoc(
            filePath: 'organism_design/cells/radio.dart',
            description:
                'Mutually exclusive option selector. Wrap multiple CellRadio with same groupValue.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellRadio'),
                const SizedBox(height: OrganismTheme.spacingMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _radioRow(context, colors, 'mts', 'Metres'),
                    _radioRow(context, colors, 'pcs', 'Pieces'),
                    _radioRow(context, colors, 'kg', 'Kilograms'),
                  ],
                ),
              ],
            ),
          ),
          // Slider
          LibraryComponentDoc(
            filePath: 'organism_design/cells/slider.dart',
            description:
                'Horizontal dragging track. Returns 0.0–1.0 via onChanged.',
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel(context, colors,
                      'CellSlider  (${(_sliderVal * 100).round()}%)'),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellSlider(
                    value: _sliderVal,
                    onChanged: (v) => setState(() => _sliderVal = v),
                  ),
                ],
              ),
            ),
          ),
          // ToggleGroup
          LibraryComponentDoc(
            filePath: 'organism_design/cells/toggle_group.dart',
            description:
                'Segmented exclusive selector using generic type T. Renders each item via itemBuilder.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellToggleGroup'),
                const SizedBox(height: OrganismTheme.spacingMd),
                CellToggleGroup<String>(
                  value: _toggleVal!,
                  items: const ['list', 'grid', 'kanban'],
                  onChanged: (v) => setState(() => _toggleVal = v),
                  itemBuilder: (item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item == 'list'
                            ? LucideIcons.list
                            : item == 'grid'
                                ? LucideIcons.layoutGrid
                                : LucideIcons.columns,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(item.substring(0, 1).toUpperCase() + item.substring(1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 4 — DATA ENTRY: DATE/TIME/COMBO/INPUTCHIP
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildDataEntrySection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Advanced Data Entry',
      subtitle:
          'CellCombobox, CellDatePicker, CellTimePicker, CellCalendar, CellInputChip — Popover-based pickers.',
      child: Wrap(
        spacing: OrganismTheme.spacingXl,
        runSpacing: OrganismTheme.spacingXl,
        children: [
          // Combobox
          LibraryComponentDoc(
            filePath: 'organism_design/cells/combobox.dart',
            description:
                'Virtualized popover dropdown for 10k+ item lists. Does NOT use native DropdownButton. '
                'Powered by PlasmaPopover + ListView.builder.',
            child: SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel(context, colors, 'CellCombobox'),
                  const SizedBox(height: OrganismTheme.spacingXs),
                  CellCombobox<String>(
                    items: const [
                      'Dola Silk',
                      'Vichitra',
                      'Crepe',
                      'Organza',
                      'Georgette',
                      'Viscose',
                    ],
                    value: _comboVal,
                    labelBuilder: (s) => s,
                    placeholder: 'Select quality...',
                    onChanged: (v) => setState(() => _comboVal = v),
                  ),
                ],
              ),
            ),
          ),
          // DatePicker
          LibraryComponentDoc(
            filePath: 'organism_design/cells/date_picker.dart',
            description:
                'Compact date button that opens a CellCalendar in a PlasmaPopover. Returns DateTime.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellDatePicker'),
                const SizedBox(height: OrganismTheme.spacingXs),
                CellDatePicker(
                  value: DateTime.now(),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          // TimePicker
          LibraryComponentDoc(
            filePath: 'organism_design/cells/time_picker.dart',
            description:
                'Popover time selector with 30-minute ERP-standard blocks.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellTimePicker'),
                const SizedBox(height: OrganismTheme.spacingXs),
                CellTimePicker(
                  value: const TimeOfDay(hour: 10, minute: 30),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          // Calendar (standalone)
          LibraryComponentDoc(
            filePath: 'organism_design/cells/calendar.dart',
            description:
                'Standalone month-grid calendar. Used by CellDatePicker internally, but can be embedded directly.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellCalendar (Standalone)'),
                const SizedBox(height: OrganismTheme.spacingXs),
                CellCalendar(
                  value: DateTime.now(),
                  onDateSelected: (_) {},
                ),
              ],
            ),
          ),
          // InputChip
          LibraryComponentDoc(
            filePath: 'organism_design/cells/input_chip.dart',
            description:
                'Tokenized tag entry used inside CellCombobox multi-select mode. Renders a deletable chip.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(
                    context, colors, 'CellInputChip (multi-select tokens)'),
                const SizedBox(height: OrganismTheme.spacingMd),
                Wrap(
                  spacing: OrganismTheme.spacingXs,
                  runSpacing: OrganismTheme.spacingXs,
                  children: _chips
                      .map((chip) => CellInputChip(
                            label: chip,
                            onDeleted: () =>
                                setState(() => _chips.remove(chip)),
                          ))
                      .toList(),
                ),
                if (_chips.isEmpty)
                  Text('All chips removed',
                      style: OrganismTheme.bodySmall(context)
                          .copyWith(color: colors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 5 — DISPLAY & INDICATORS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildDisplaySection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Display & Indicators',
      subtitle:
          'CellBadge, CellCountBadge, CellAvatar, CellFilterChip, CellTag, CellStatusDot, '
          'CellProgressBar, CellTooltip, CellSkeleton, CellAlert, CellKbd — Visual communication atoms.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          LibraryComponentDoc(
            filePath: 'organism_design/cells/badge.dart',
            description:
                'Semantic density pill. Non-interactive. 6 variants: primary, secondary, outline, success, warning, error.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellBadge — Semantic Status'),
                const SizedBox(height: OrganismTheme.spacingMd),
                Wrap(
                  spacing: OrganismTheme.spacingSm,
                  runSpacing: OrganismTheme.spacingSm,
                  children: const [
                    CellBadge(text: 'Primary', variant: CellBadgeVariant.primary),
                    CellBadge(text: 'Success', variant: CellBadgeVariant.success),
                    CellBadge(text: 'Warning', variant: CellBadgeVariant.warning),
                    CellBadge(text: 'Error', variant: CellBadgeVariant.error),
                    CellBadge(text: 'Secondary', variant: CellBadgeVariant.secondary),
                    CellBadge(text: 'Outline', variant: CellBadgeVariant.outline),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingXl),
          Wrap(
            spacing: OrganismTheme.spacing2Xl,
            runSpacing: OrganismTheme.spacingXl,
            children: [
              // CountBadge
              LibraryComponentDoc(
                filePath: 'organism_design/cells/count_badge.dart',
                description:
                    'Circular numeric counter. Caps at 99+. Used on nav items and avatar overlays.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellCountBadge'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    Wrap(
                      spacing: OrganismTheme.spacingMd,
                      runSpacing: OrganismTheme.spacingSm,
                      children: const [
                        CellCountBadge(count: 3),
                        CellCountBadge(count: 12),
                        CellCountBadge(count: 100),
                      ],
                    ),
                  ],
                ),
              ),
              // Avatar
              LibraryComponentDoc(
                filePath: 'organism_design/cells/avatar.dart',
                description:
                    'Initials parser + optional image. statusColor adds a bottom-right presence dot.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellAvatar'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    Wrap(
                      spacing: OrganismTheme.spacingSm,
                      runSpacing: OrganismTheme.spacingSm,
                      children: const [
                        CellAvatar(name: 'Smit Kumar', size: 40),
                        CellAvatar(name: 'Ambaji Sarees', size: 32),
                        CellAvatar(
                            name: 'Shreeji Tex',
                            size: 28,
                            statusColor: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              // FilterChip
              LibraryComponentDoc(
                filePath: 'organism_design/cells/filter_chip.dart',
                description:
                    'Boolean toggle chip for list filtering. isSelected drives visual state.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellFilterChip'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    const Wrap(
                      spacing: OrganismTheme.spacingSm,
                      children: [
                        CellFilterChip(label: 'All', isSelected: true),
                        CellFilterChip(label: 'Pending', isSelected: false),
                        CellFilterChip(label: 'Closed', isSelected: false),
                      ],
                    ),
                  ],
                ),
              ),
              // Tag
              LibraryComponentDoc(
                filePath: 'organism_design/cells/tag.dart',
                description:
                    'Removable tag chip. Distinct from FilterChip (toggle) and Badge (static). '
                    'onRemove → renders × button. 5 semantic variants.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellTag'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    Wrap(
                      spacing: OrganismTheme.spacingSm,
                      runSpacing: OrganismTheme.spacingSm,
                      children: [
                        const CellTag(label: 'Neutral'),
                        CellTag(
                            label: 'Accent',
                            variant: CellTagVariant.accent,
                            icon: LucideIcons.tag),
                        CellTag(
                            label: 'Quality: DS',
                            variant: CellTagVariant.success,
                            onRemove: () {}),
                        CellTag(
                            label: 'Overdue',
                            variant: CellTagVariant.error,
                            onRemove: () {}),
                        CellTag(
                            label: 'Review',
                            variant: CellTagVariant.warning,
                            onRemove: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              // StatusDot
              LibraryComponentDoc(
                filePath: 'organism_design/cells/status_dot.dart',
                description:
                    'Animated pulsing dot. active + syncing variants animate glow; idle/warning/error are static.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellStatusDot'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CellStatusDot(
                            label: 'Supabase Live',
                            variant: CellStatusVariant.active),
                        SizedBox(height: OrganismTheme.spacingXs),
                        CellStatusDot(
                            label: 'Syncing...',
                            variant: CellStatusVariant.syncing),
                        SizedBox(height: OrganismTheme.spacingXs),
                        CellStatusDot(
                            label: 'Offline',
                            variant: CellStatusVariant.error),
                        SizedBox(height: OrganismTheme.spacingXs),
                        CellStatusDot(
                            label: 'Idle', variant: CellStatusVariant.idle),
                      ],
                    ),
                  ],
                ),
              ),
              // Progress
              LibraryComponentDoc(
                filePath: 'organism_design/cells/progress_bar.dart',
                description:
                    'Linear 0.0–1.0 progress track. Animates on value change.',
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subLabel(context, colors, 'CellProgressBar'),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      const CellProgressBar(value: 0.72),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      const CellProgressBar(value: 0.33),
                    ],
                  ),
                ),
              ),
              // Tooltip
              LibraryComponentDoc(
                filePath: 'organism_design/cells/tooltip.dart',
                description:
                    'Z-axis hover semantic pop. Wraps any child; shows message on hover/long-press.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellTooltip'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    CellTooltip(
                      message: 'Shortcut: Ctrl+N',
                      child: CellButton(
                          text: 'Hover me',
                          variant: CellButtonVariant.outline,
                          onPressed: () {}),
                    ),
                  ],
                ),
              ),
              // Skeleton
              LibraryComponentDoc(
                filePath: 'organism_design/cells/skeleton.dart',
                description:
                    'Structural shimmer loading box. Use while data is being fetched.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellSkeleton'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    const CellSkeleton(width: 180, height: 16),
                    const SizedBox(height: OrganismTheme.spacingXs),
                    const CellSkeleton(width: 120, height: 12),
                    const SizedBox(height: OrganismTheme.spacingXs),
                    const CellSkeleton(width: 220, height: 12),
                  ],
                ),
              ),
              // Alert
              LibraryComponentDoc(
                filePath: 'organism_design/cells/alert.dart',
                description:
                    'Inline semantic banner. 4 variants: info, success, warning, error.',
                child: SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subLabel(context, colors, 'CellAlert'),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      const CellAlert(
                        title: 'Bill saved successfully.',
                        icon: LucideIcons.checkCircle2,
                        variant: CellBadgeVariant.success,
                      ),
                      const SizedBox(height: OrganismTheme.spacingSm),
                      const CellAlert(
                        title: 'Stock mismatch on O7 dispatch.',
                        icon: LucideIcons.alertTriangle,
                        variant: CellBadgeVariant.warning,
                      ),
                      const SizedBox(height: OrganismTheme.spacingSm),
                      const CellAlert(
                        title: 'Connection to EMPIRE lost.',
                        icon: LucideIcons.alertCircle,
                        variant: CellBadgeVariant.error,
                      ),
                    ],
                  ),
                ),
              ),
              // Kbd
              LibraryComponentDoc(
                filePath: 'organism_design/cells/kbd.dart',
                description:
                    'Keyboard key chip. Use inline in tooltips, button labels, or help text.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subLabel(context, colors, 'CellKbd'),
                    const SizedBox(height: OrganismTheme.spacingMd),
                    const Wrap(
                      spacing: OrganismTheme.spacingXs,
                      children: [
                        CellKbd(keyString: 'Ctrl'),
                        CellKbd(keyString: '+'),
                        CellKbd(keyString: 'N'),
                      ],
                    ),
                    const SizedBox(height: OrganismTheme.spacingSm),
                    const Wrap(
                      spacing: OrganismTheme.spacingXs,
                      children: [
                        CellKbd(keyString: 'ESC'),
                        SizedBox(width: 4),
                        CellKbd(keyString: 'F5'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 6 — STRUCTURAL DNA
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildStructuralSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Structural DNA',
      subtitle:
          'CellBox, CellDivider, CellLabel, CellListTile, CellPlaceholder — Invisible geometric compliance rules.',
      child: Wrap(
        spacing: OrganismTheme.spacing2Xl,
        runSpacing: OrganismTheme.spacingXl,
        children: [
          // Spatial Utilities
          LibraryComponentDoc(
            filePath: 'organism_design/cells/spatial.dart',
            description:
                'Statically enforced spacing atoms. strictly multiplier × OrganismTheme.spacingMd (16px).',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellGap & CellPad'),
                const SizedBox(height: OrganismTheme.spacingMd),
                Row(
                  children: [
                    const CellBox(
                      padding: EdgeInsets.zero,
                      child: SizedBox(width: 40, height: 40),
                    ),
                    const CellGap(0.5), // 8px
                    const CellBox(
                      padding: EdgeInsets.zero,
                      child: SizedBox(width: 40, height: 40),
                    ),
                    const CellGap(), // 16px
                    const CellBox(
                      padding: EdgeInsets.zero,
                      child: SizedBox(width: 40, height: 40),
                    ),
                  ],
                ),
                const SizedBox(height: OrganismTheme.spacingMd),
                const CellBox(
                  padding: EdgeInsets.zero,
                  child: CellPad(
                    multiplier: 0.5,
                    child: Text('CellPad(0.5)'),
                  ),
                ),
                const SizedBox(height: OrganismTheme.spacingSm),
                const CellBox(
                  padding: EdgeInsets.zero,
                  child: CellPad(
                    child: Text('CellPad()'),
                  ),
                ),
              ],
            ),
          ),
          // CellBox
          SizedBox(
            width: 280,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/box.dart',
              description:
                  'Atomic surface: 1px border + standard radiusMd. All ERP panels descend from this.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel(context, colors, 'CellBox'),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellBox(
                    padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                    child: Column(
                      children: [
                        const CellPlaceholder(height: 80),
                        const SizedBox(height: OrganismTheme.spacingMd),
                        Text('1px border · radiusMd (8px)',
                            style: OrganismTheme.bodySmall(context)
                                .copyWith(color: colors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // CellDivider
          SizedBox(
            width: 280,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/divider.dart',
              description:
                  'Exact 1px structural membrane at theme border color. Horizontal only.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel(context, colors, 'CellDivider'),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellBox(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.all(OrganismTheme.spacingMd),
                          child: Text('Section A',
                              style: OrganismTheme.bodySmall(context)),
                        ),
                        const CellDivider(),
                        Padding(
                          padding:
                              const EdgeInsets.all(OrganismTheme.spacingMd),
                          child: Text('Section B',
                              style: OrganismTheme.bodySmall(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // CellLabel
          LibraryComponentDoc(
            filePath: 'organism_design/cells/label.dart',
            description:
                'Form field title with optional `isRequired` asterisk (*). Renders uppercase label text.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellLabel'),
                const SizedBox(height: OrganismTheme.spacingMd),
                const CellLabel(text: 'Party Name'),
                const SizedBox(height: OrganismTheme.spacingXs),
                const CellInput(placeholder: 'Enter party name...'),
                const SizedBox(height: OrganismTheme.spacingMd),
                const CellLabel(text: 'Quality Code', isRequired: true),
                const SizedBox(height: OrganismTheme.spacingXs),
                const CellInput(placeholder: 'Required field', hasError: false),
              ],
            ),
          ),
          // CellListTile
          SizedBox(
            width: 300,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/list_tile.dart',
              description:
                  'Standard row: leading widget / title / subtitle / trailing. Fixed 48px height.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel(context, colors, 'CellListTile'),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellBox(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        CellListTile(
                          leading: const CellAvatar(name: 'Smit Kumar', size: 32),
                          title: 'Smit Kumar',
                          subtitle: 'Administrator',
                          trailing:
                              Icon(LucideIcons.chevronRight, size: 16),
                          onTap: () {},
                        ),
                        const CellDivider(),
                        CellListTile(
                          leading: Icon(LucideIcons.building2, size: 16),
                          title: 'Ambaji Sarees',
                          subtitle: 'Main Branch · Surat',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // CellPlaceholder
          LibraryComponentDoc(
            filePath: 'organism_design/cells/placeholder.dart',
            description:
                'Dev skeleton block for layout prototyping. Renders a hatched/filled box.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellPlaceholder'),
                const SizedBox(height: OrganismTheme.spacingMd),
                const CellPlaceholder(width: 200, height: 60),
                const SizedBox(height: OrganismTheme.spacingSm),
                const CellPlaceholder(width: 120, height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 7 — NAVIGATION & BRAND
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildNavigationSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Navigation & Brand',
      subtitle:
          'CellNavItem, AmbajiSareeLogo — Shell-level navigation atoms and brand identity.',
      child: Wrap(
        spacing: OrganismTheme.spacing2Xl,
        runSpacing: OrganismTheme.spacingXl,
        children: [
          // NavItem
          LibraryComponentDoc(
            filePath: 'organism_design/cells/nav_item.dart',
            description:
                'Sidebar/Rail navigation entry. isCollapsed: true → Rail mode (icon + label stack). '
                'isCollapsed: false → Sidebar mode (icon + full label row).',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellNavItem — Sidebar Mode'),
                const SizedBox(height: OrganismTheme.spacingMd),
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      CellNavItem(
                        icon: LucideIcons.layoutDashboard,
                        label: 'Dashboard',
                        isSelected: true,
                        isCollapsed: false,
                        onTap: () {},
                      ),
                      CellNavItem(
                        icon: LucideIcons.package,
                        label: 'Items',
                        isSelected: false,
                        isCollapsed: false,
                        onTap: () {},
                      ),
                      CellNavItem(
                        icon: LucideIcons.users,
                        label: 'Parties',
                        isSelected: false,
                        isCollapsed: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          LibraryComponentDoc(
            filePath: 'organism_design/cells/nav_item.dart',
            description:
                'Rail mode: isCollapsed: true renders compact icon-only 84px-wide rail navigation.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'CellNavItem — Rail Mode'),
                const SizedBox(height: OrganismTheme.spacingMd),
                SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      CellNavItem(
                        icon: LucideIcons.layoutDashboard,
                        label: 'Dash',
                        isSelected: true,
                        isCollapsed: true,
                        onTap: () {},
                      ),
                      CellNavItem(
                        icon: LucideIcons.package,
                        label: 'Items',
                        isSelected: false,
                        isCollapsed: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Logo
          LibraryComponentDoc(
            filePath: 'organism_design/cells/logo.dart',
            description:
                'Ambaji Sarees brand logotype. isCollapsed: false → full wordmark. '
                'isCollapsed: true → icon mark only. Scales via size parameter.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subLabel(context, colors, 'AmbajiSareeLogo'),
                const SizedBox(height: OrganismTheme.spacingMd),
                const AmbajiSareeLogo(size: 32),
                const SizedBox(height: OrganismTheme.spacingLg),
                const AmbajiSareeLogo(size: 24, isCollapsed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _subLabel(
          BuildContext context, OrganismColors colors, String text) =>
      Text(text,
          style: OrganismTheme.labelMedium(context)
              .copyWith(color: colors.textMuted));

  Widget _radioRow(BuildContext context, OrganismColors colors,
      String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _radioVal = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CellRadio<String>(
            value: value,
            groupValue: _radioVal,
            onChanged: (v) => setState(() => _radioVal = v!),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: OrganismTheme.bodySmall(context)
                  .copyWith(color: colors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildFormattingAtomsSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Formatting & Media Primitives',
      subtitle: 'CellImage, CellIcon, CellCurrencyDisplay, CellEmptyValue — read-only mappers.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/image.dart',
              description: 'Strict grid thumbnails utilizing load skeletons and error fallbacks natively.',
              child: Row(
                children: [
                  const CellImage(
                    imageUrl: 'https://invalid-url.com/broken.jpg',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: OrganismTheme.spacingMd),
                  const CellImage(
                    imageUrl: 'https://picsum.photos/seed/ambaji/100/100',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 380,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/icon.dart',
              description: 'Icon restrictions bound specifically to sizing and active foreground tokens.',
              child: const Row(
                children: [
                  CellIcon(LucideIcons.diamond, variant: CellIconVariant.primary, size: CellIconSize.large),
                  SizedBox(width: OrganismTheme.spacingMd),
                  CellIcon(LucideIcons.alertTriangle, variant: CellIconVariant.warning, size: CellIconSize.standard),
                  SizedBox(width: OrganismTheme.spacingMd),
                  CellIcon(LucideIcons.xCircle, variant: CellIconVariant.error, size: CellIconSize.standard),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 320,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/currency_display.dart',
              description: 'Safe tabular decimal alignment for the Indian Rupee system.',
              child: Container(
                padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                decoration: BoxDecoration(color: colors.surfaceSubtle, borderRadius: OrganismTheme.borderSm),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CellCurrencyDisplay(amount: 45000.50),
                    CellCurrencyDisplay(amount: -1250.00),
                    CellCurrencyDisplay(amount: 0, variant: CellCurrencyVariant.subdued),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 320,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/empty_value.dart',
              description: 'Consistent structural em-dash for mapping null pointers safely.',
              child: Container(
                padding: const EdgeInsets.all(OrganismTheme.spacingMd),
                decoration: BoxDecoration(border: Border.all(color: colors.borderSubtle)),
                alignment: Alignment.center,
                child: const CellEmptyValue(),
              ),
            ),
          ),
          SizedBox(
            width: 320,
            child: LibraryComponentDoc(
              filePath: 'organism_design/cells/menu_item.dart',
              description: 'Interactive row for menus with icon and trailing shortcuts.',
              child: Column(
                children: [
                  CellMenuItem(label: 'Edit Entry', icon: LucideIcons.edit2, onTap: () {}),
                  CellMenuItem(label: 'Delete Record', icon: LucideIcons.trash2, isDestructive: true, onTap: () {}),
                  CellMenuItem(label: 'Sync Status', icon: LucideIcons.refreshCw, isDisabled: true, trailing: Text('Ctrl+S'), onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}

