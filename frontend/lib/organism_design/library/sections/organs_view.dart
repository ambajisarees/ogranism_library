import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../index.dart';
import '../widgets/library_header.dart';

class OrgansView extends StatelessWidget {
  const OrgansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryHeader(
          title: 'Level 4: Macro Overlays & Z-Axis',
          description: 'Managing depth, physics, and absolute positioning for modals, popovers, and toasts.',
        ),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildOverlaysSection(context),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildComplexTissuesSection(),
        
        const SizedBox(height: 64.0),
        
        const LibraryHeader(
          title: 'Level 5: Organs (App Shells)',
          description: 'Assembling tissues into complete structural organs like the NavBoat. The largest modular blocks.',
        ),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildOrgansSection(),
      ],
    );
  }

  Widget _buildOverlaysSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dialogs & Deep Context (Z-Axis)', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        Row(
          children: [
            CellButton(
              text: 'Launch System Modal',
              variant: CellButtonVariant.primary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (c) => const Dialog(
                    child: TissueAlert(
                      title: 'System Confirmation',
                      message: 'Are you sure you want to commit these changes to the master ledger?',
                      variant: CellBadgeVariant.warning,
                      icon: LucideIcons.alertTriangle,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: OrganismTheme.spacingMd),
            CellButton(
              text: 'Trigger Context Menu',
              variant: CellButtonVariant.outline,
              onPressed: () {}, // Handled by TissueMenu in practice
            ),
          ],
        )
      ],
    );
  }

  Widget _buildComplexTissuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Multi-Stage Organelles', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        SizedBox(
          width: 250,
          child: TissueMenu(
            child: const CellButton(
              text: 'Open Action Menu',
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
    );
  }

  Widget _buildOrgansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Structural Shells', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        Container(
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: OrganismTheme.border),
            borderRadius: OrganismTheme.borderLg,
          ),
          child: ClipRRect(
            borderRadius: OrganismTheme.borderLg,
            child: NavBoat(
              selectedIndex: 0,
              onItemSelected: (i) {},
            ),
          ),
        ),
      ],
    );
  }
}
