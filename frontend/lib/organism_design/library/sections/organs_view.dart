import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../../tissues.dart';
import '../../organs.dart';
import '../../plasma.dart';
import '../widgets/library_section.dart';

class OrgansView extends StatelessWidget {
  const OrgansView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverlaysSection(context, colors),
        _buildOrgansSection(colors),
        _buildMasterDetailSection(context, colors),
      ],
    );
  }

  Widget _buildMasterDetailSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'MasterDetail Composition (SYSTEM CORE)',
      subtitle: 'The 4-organ structure for high-density ERP registries.',
      child: Container(
        height: 700,
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          border: Border.all(color: colors.border),
          borderRadius: OrganismTheme.borderLg,
        ),
        child: Row(
          children: [
            // ── PANE 1 & 2: Registry List ─────────────────────────────
            SizedBox(
              width: 340,
              child: Column(
                children: [
                   OrganPaneHeader(
                    title: 'Registry',
                    onSearchChanged: (_) {},
                    onAddPressed: () {},
                  ),
                  Expanded(
                    child: OrganPaneList(
                      itemCount: 10,
                      currentPage: 1,
                      totalPages: 12,
                      totalCount: 1248,
                      limit: 50,
                      onPageChanged: (_) {},
                      itemBuilder: (context, index) => TissueListCard(
                        title: Text('Ambaji Fashion House #$index'),
                        subtitle: Text('Gst: 24AAACC1234F1Z1 • ₹5,00,000'),
                        onTap: () {},
                        isSelected: index == 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(width: 1),

            // ── SECTION 3: Unified Detail Canvas ──────────────────────
            Expanded(
              child: OrganSectionCanvas(
                title: 'Ambaji Fashion House',
                tabs: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CellButton(text: 'Profile', variant: CellButtonVariant.input, isCompact: true, onPressed: () {}),
                      const SizedBox(width: 8),
                      CellButton(text: 'Ledger', variant: CellButtonVariant.ghost, isCompact: true, onPressed: () {}),
                      const SizedBox(width: 8),
                      CellButton(text: 'Compliance', variant: CellButtonVariant.ghost, isCompact: true, onPressed: () {}),
                    ],
                  ),
                ),
                actions: [
                  CellButton(
                    text: 'Edit',
                    icon: LucideIcons.edit,
                    variant: CellButtonVariant.primary,
                    isCompact: true,
                    onPressed: () {},
                  ),
                  CellButton(
                    text: 'Actions',
                    icon: LucideIcons.chevronDown,
                    variant: CellButtonVariant.secondary,
                    isCompact: true,
                    onPressed: () {},
                  ),
                ],
                children: [
                  TissueCard(
                    children: [
                      const TissueCardHeader(title: 'General Information'),
                      TissueCardContent(
                        child: Row(
                          children: [
                            const Expanded(
                              child: TissueReadOnlyField(
                                label: 'GST Number',
                                value: '24AAACC1234F1Z1',
                              ),
                            ),
                            const SizedBox(width: OrganismTheme.spacingMd),
                            const Expanded(
                              child: TissueReadOnlyField(
                                label: 'Contact Person',
                                value: 'Rahul Mehta',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TissueCard(
                    children: [
                      const TissueCardHeader(title: 'Financial Settings'),
                      TissueCardContent(
                        child: TissueFormField(
                          label: 'Credit Limit',
                          inputCell: CellInputNumber(
                            prefix: '₹',
                            initialValue: 500000,
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlaysSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Macro Overlays & Z-Axis',
      subtitle:
          'Managing depth, physics, and absolute positioning for modals and popovers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryComponentDoc(
            filePath: 'organism_design/plasma/dialog.dart',
            description: 'Macro system modals and high-density dropdowns leveraging the Plasma overlay physics.',
            child: Row(
              children: [
                CellButton(
                  text: 'Launch System Modal',
                  variant: CellButtonVariant.primary,
                  onPressed: () {
                    PlasmaAlertDialog.show(
                      context: context,
                      title: 'System Confirmation',
                      message: 'Are you sure you want to commit these changes?',
                      isDestructive: false,
                    );
                  },
                ),
                const SizedBox(width: OrganismTheme.spacingMd),
                SizedBox(
                  width: 200,
                  child: TissueMenu(
                    child: const CellButton(
                      text: 'Action Menu',
                      variant: CellButtonVariant.outline,
                      icon: LucideIcons.moreVertical,
                    ),
                    items: [
                      TissueMenuItemData(label: 'Edit Record', icon: LucideIcons.edit, onTap: () {}),
                      TissueMenuItemData(label: 'Download PDF', icon: LucideIcons.download, onTap: () {}),
                      TissueMenuItemData(label: 'Delete', icon: LucideIcons.trash2, isDestructive: true, onTap: () {}),
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

  Widget _buildOrgansSection(OrganismColors colors) {
    return LibrarySection(
      title: 'App Organs & Shells',
      subtitle: 'Higher level assembled modular blocks like the NavBoat sidebar.',
      child: LibraryComponentDoc(
        filePath: 'organism_design/organs/nav_boat.dart',
        description: 'Global vertical navigation shell featuring state-aware peeking and extension animations.',
        child: Container(
          height: 600,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: OrganismTheme.borderLg,
            boxShadow: OrganismTheme.shadowMd,
          ),
          child: ClipRRect(
            borderRadius: OrganismTheme.borderLg,
            child: Stack(
              children: [
                NavBoat(
                  selectedIndex: 0,
                  onItemSelected: (i) {},
                  controller: KineticWorkspaceController(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
