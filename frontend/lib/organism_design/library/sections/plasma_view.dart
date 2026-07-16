import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../plasma.dart';
import '../../cells.dart';
import '../../tissues.dart';
import '../widgets/library_section.dart';

class PlasmaView extends StatelessWidget {
  const PlasmaView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildZIndexScaleSection(context, colors),
        _buildOverlaysSection(context, colors),
        _buildDepthSection(context, colors),
        _buildGeometrySection(context, colors),
        _buildDataVizSections(context, colors),
        _buildResponsiveSection(context, colors),
      ],
    );
  }

  Widget _buildZIndexScaleSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Z-Index Governance',
      subtitle: 'Strict stacking order for the 3rd Dimension.',
      child: LibraryComponentDoc(
        filePath: 'organism_design/theme.dart',
        description: 'Global Z-Index registry defining semantic layering.',
        child: Container(
          padding: const EdgeInsets.all(OrganismTheme.spacingLg),
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: OrganismTheme.borderMd,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _zIndexRow(context, colors, 'Tooltip', OrganismTheme.zIndexTooltip, 'Absolute Peak (Global Notifications)'),
              _zIndexRow(context, colors, 'Toast', OrganismTheme.zIndexToast, 'Status Feedback (Ephemeral Alerts)'),
              _zIndexRow(context, colors, 'Dialog', OrganismTheme.zIndexDialog, 'Focus Modals (User Blocking)'),
              _zIndexRow(context, colors, 'Popover', OrganismTheme.zIndexPopover, 'Context Menus (Anchored Overlays)'),
              _zIndexRow(context, colors, 'Dropdown', OrganismTheme.zIndexDropdown, 'Field Options (Inline Selections)'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zIndexRow(BuildContext context, OrganismColors colors, String name, int value, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primaryLight.withValues(alpha: 0.1),
              borderRadius: OrganismTheme.borderSm,
            ),
            child: Text(value.toString(),
                style: OrganismTheme.code(context).copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(name,
                style: OrganismTheme.labelLarge(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(desc,
                textAlign: TextAlign.right,
                style: OrganismTheme.bodySmall(context).copyWith(color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlaysSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Overlay Systems',
      subtitle: 'Managed floating layers using semantic physics.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          // Dialog Trigger
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/dialog.dart',
            description: 'Focus stealing blocking modals. Utilizes scale-in physics.',
            child: CellButton(
              text: 'Open Modal Dialog',
              variant: CellButtonVariant.outline,
              onPressed: () {
                PlasmaDialog.show(
                  context: context,
                  title: 'Quality Verification',
                  description: 'Please confirm the MTS count for the current cutting block.',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TissueFormField(
                        label: 'Actual MTS',
                        inputCell: CellInputNumber(
                          initialValue: 0.0,
                          onChanged: (v) {},
                          suffix: 'MTS',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    CellButton(
                      text: 'Cancel',
                      variant: CellButtonVariant.ghost,
                      onPressed: () => Navigator.pop(context),
                    ),
                    CellButton(
                      text: 'Save & Verify',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
            ),
          ),

          // Drawer Trigger
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/drawer.dart',
            description: 'Slide-out right side navigation panel for detailed inline edits.',
            child: CellButton(
              text: 'Open Right Drawer',
              variant: CellButtonVariant.outline,
              onPressed: () {
                PlasmaDrawer.show(
                  context: context,
                  title: 'Line Item Edit',
                  subtitle: 'Modify slip parameters non-destructively.',
                  content: Column(
                    children: [
                      TissueFormField(
                        label: 'Quantity (MTS)',
                        inputCell: CellInputNumber(initialValue: 80, onChanged: (v) {}),
                      ),
                      const SizedBox(height: 16),
                      CellButton(text: 'Save Changes', onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                );
              },
            ),
          ),

          // Toast Trigger
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/toast.dart',
            description: 'Ephemeral feedback alerts that auto-dismiss.',
            child: CellButton(
              text: 'Show Status Toast',
              variant: CellButtonVariant.outline,
              onPressed: () {
                PlasmaToastManager.instance.show(context, 'Transaction Saved Successfully', variant: CellBadgeVariant.success);
              },
            ),
          ),

          // Popover Trigger
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/popover.dart',
            description: 'Anchored contextual floating menus.',
            child: PlasmaPopover(
              trigger: const CellButton(text: 'Show Popover', variant: CellButtonVariant.outline),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Quick Actions', style: OrganismTheme.labelMedium(context)),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellListTile(
                    title: 'Edit Current',
                    leading: Icon(LucideIcons.edit2, size: 16),
                    onTap: () {},
                  ),
                  const CellDivider(),
                  CellListTile(
                    title: 'Discard',
                    leading: Icon(LucideIcons.trash, size: 16, color: Colors.red),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Context Menu
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/context_menu.dart',
            description: 'Right-click trigger capturing mouse position for menu spawning.',
            child: PlasmaContextMenu(
              items: [
                const TissueMenuGroup(
                  title: 'Row Actions',
                  children: [
                    CellMenuItem(label: 'Quick Edit', icon: LucideIcons.edit2),
                    CellMenuItem(label: 'Duplicate', icon: LucideIcons.copy),
                  ],
                ),
                TissueMenuGroup(
                  showDivider: true,
                  children: [
                    CellMenuItem(label: 'Delete', icon: LucideIcons.trash2, isDestructive: true, onTap: () {}),
                  ],
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                decoration: BoxDecoration(
                  color: colors.primarySubtle,
                  borderRadius: OrganismTheme.borderMd,
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                ),
                child: Text('Right Click Me', style: OrganismTheme.labelLarge(context).copyWith(color: colors.primary)),
              ),
            ),
          ),
          // Hover Card
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/hover_card.dart',
            description: 'Non-destructive data preview with open/close delays.',
            child: PlasmaHoverCard(
              trigger: Container(
                padding: const EdgeInsets.all(OrganismTheme.spacingLg),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: OrganismTheme.borderMd,
                  border: Border.all(color: colors.border),
                ),
                child: const Text('Hover Me (500ms)'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CellAvatar(name: 'Ambaji', size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ambaji Sarees', style: OrganismTheme.titleMedium(context)),
                          Text('GST: 24AAACA1234F1Z5', style: OrganismTheme.labelMedium(context)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Credit Limit:', style: OrganismTheme.bodySmall(context)),
                      const CellCurrencyDisplay(amount: 500000),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepthSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Depth & Kinetic Stacking',
      subtitle: 'Visualizing TissueZStack coordinate layering.',
      child: LibraryComponentDoc(
        filePath: 'organism_design/tissues/geometry/z_stack.dart',
        description: 'Absolute positioning bounds engine handling semantic depth layers.',
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: OrganismTheme.borderLg,
            border: Border.all(color: colors.border),
          ),
          child: TissueZStack(
            children: [
              TissueZLayer(
                zIndex: 0,
                left: 40,
                top: 40,
                child: _depthCard(context, colors, 'Layer 0 (Base)', colors.surface),
              ),
              TissueZLayer(
                zIndex: 1,
                left: 80,
                top: 60,
                child: _depthCard(context, colors, 'Layer 1 (Raised)', colors.surface, elevation: 2),
              ),
              TissueZLayer(
                zIndex: 2,
                left: 120,
                top: 80,
                child: _depthCard(context, colors, 'Layer 2 (Floating)', colors.surface, elevation: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _depthCard(BuildContext context, OrganismColors colors, String label, Color color, {double elevation = 1}) {
    return Container(
      width: 150,
      height: 80,
      padding: const EdgeInsets.all(OrganismTheme.spacingMd),
      decoration: BoxDecoration(
        color: color,
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: colors.border),
        boxShadow: OrganismTheme.shadowsOf(context, elevation: elevation),
      ),
      child: Text(label, style: OrganismTheme.labelMedium(context)),
    );
  }

  Widget _buildGeometrySection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Geometry & Radius Mappings',
      subtitle: 'Shadow tiers and standard architectural curves.',
      child: LibraryComponentDoc(
        filePath: 'organism_design/theme/',
        description: 'Global standard radii tokens applied dynamically via shadowsOf.',
        child: Wrap(
          spacing: OrganismTheme.spacingLg,
          runSpacing: OrganismTheme.spacingLg,
          children: [
            _shadowBoxCompact(
                context, 'Sm Radius', 1, OrganismTheme.borderMd, colors),
            _shadowBoxCompact(
                context, 'Md Float', 2, OrganismTheme.borderLg, colors),
            _shadowBoxCompact(context, 'Deep Radius', 3,
                BorderRadius.circular(OrganismTheme.radiusXl), colors),
            _shadowBoxCompact(
                context, 'Glow Pill', 1, OrganismTheme.borderPill, colors,
                isGlow: true),
          ],
        ),
      ),
    );
  }

  Widget _shadowBoxCompact(BuildContext context, String label, double elevation,
      BorderRadius radius, OrganismColors colors,
      {bool isGlow = false}) {
    return Container(
      width: 130,
      height: 100,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        boxShadow: OrganismTheme.shadowsOf(context,
            elevation: elevation, isGlow: isGlow),
        border: Border.all(
          color: isGlow
              ? colors.primary.withValues(alpha: 0.5)
              : colors.border.withValues(alpha: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(label,
          textAlign: TextAlign.center,
          style: OrganismTheme.labelLarge(context).copyWith(color: colors.textPrimary)),
    );
  }

  Widget _buildDataVizSections(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Data Vis: Categorical 12',
      subtitle: 'High-contrast hues tuned for Slate.',
      child: LibraryComponentDoc(
        filePath: 'organism_design/theme/colors.dart',
        description: 'Semantic categorization engine providing highly divergent palettes for metric data.',
        child: Wrap(
          spacing: OrganismTheme.spacingSm,
          runSpacing: OrganismTheme.spacingSm,
          children: [
            _colorSwatchCompact(context, 'C1', colors.chart1, colors),
            _colorSwatchCompact(context, 'C2', colors.chart2, colors),
            _colorSwatchCompact(context, 'C3', colors.chart3, colors),
            _colorSwatchCompact(context, 'C4', colors.chart4, colors),
            _colorSwatchCompact(context, 'C5', colors.chart5, colors),
            _colorSwatchCompact(context, 'C6', colors.chart6, colors),
          ],
        ),
      ),
    );
  }

  Widget _colorSwatchCompact(
      BuildContext context, String label, Color color, OrganismColors colors) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: OrganismTheme.borderMd,
            border: Border.all(color: colors.border),
          ),
        ),
        const SizedBox(height: OrganismTheme.spacingXs),
        Text(label, style: OrganismTheme.bodySmall(context)),
      ],
    );
  }

  Widget _buildResponsiveSection(BuildContext context, OrganismColors colors) {
    final breakpoint = OrganismTheme.breakpointOf(context);
    return LibrarySection(
      title: 'Responsivity',
      subtitle: 'Current: ${breakpoint.name.toUpperCase()}',
      child: LibraryComponentDoc(
        filePath: 'organism_design/theme/metrics.dart',
        description: 'Global threshold engine defining viewport breakpoint constraints.',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primarySubtle,
            borderRadius: OrganismTheme.borderMd,
            border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.monitor, color: colors.primary),
              const SizedBox(width: 12),
              Text('Scaling Tier: ${breakpoint.name.toUpperCase()}', style: OrganismTheme.labelLarge(context)),
            ],
          ),
        ),
      ),
    );
  }
}
