import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme.dart';
import '../../index.dart';
import '../widgets/library_header.dart';

class CellsView extends StatelessWidget {
  const CellsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryHeader(
          title: 'Level 2: Cells (Atomic Mechanics)',
          description: 'Headless logic blocks handling states (hover/focus/active) stripped of Material bloat. The Micro level components.',
        ),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildInteractionsSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildInputsSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildSemanticsSection(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        const CellDivider(),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        _buildMicroGapSection(),
      ],
    );
  }

  Widget _buildInteractionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Interaction Sandbox: <CellButton />', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingSm),
        Text('Hover and click these components to see Shadcn mechanics operating through Organism Themes.', style: OrganismTheme.bodyMedium),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        Wrap(
          spacing: OrganismTheme.spacingXl,
          runSpacing: OrganismTheme.spacingLg,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CellButton(text: 'Primary Action', variant: CellButtonVariant.primary, onPressed: () {}),
            CellButton(text: 'Secondary (Action)', variant: CellButtonVariant.secondary, onPressed: () {}),
            CellButton(text: 'Destructive', variant: CellButtonVariant.destructive, onPressed: () {}, icon: LucideIcons.trash2),
            CellButton(text: 'Outline State', variant: CellButtonVariant.outline, onPressed: () {}),
            CellButton(text: 'Ghost State', variant: CellButtonVariant.ghost, onPressed: () {}),
            CellButton(text: 'System Loading', variant: CellButtonVariant.primary, isLoading: true, onPressed: () {}),
            const CellButton(text: 'Disabled Button', variant: CellButtonVariant.primary, onPressed: null),
          ],
        )
      ],
    );
  }

  Widget _buildInputsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Form Data Entry Sandbox', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingSm),
        Text('Click inside these inputs to watch the physical focus ring bloom. The Material bloat has been thoroughly stripped out.', style: OrganismTheme.bodyMedium),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Standard Client Name', style: OrganismTheme.labelLarge),
              const SizedBox(height: OrganismTheme.spacingXs),
              const CellInput(placeholder: 'e.g. Acme Textiles Ltd.'),
              const SizedBox(height: OrganismTheme.spacingLg),

              Text('Search Directory (With Vector)', style: OrganismTheme.labelLarge),
              const SizedBox(height: OrganismTheme.spacingXs),
              const CellInput(placeholder: 'Search invoices...', isSearch: true),
              const SizedBox(height: OrganismTheme.spacingLg),

              Text('Numeric / Currency (JetBrains Mono enforced)', style: OrganismTheme.labelLarge),
              const SizedBox(height: OrganismTheme.spacingXs),
              const CellInput(placeholder: '0.00', isNumeric: true),
              const SizedBox(height: OrganismTheme.spacingLg),

              Text('Validation Error State', style: OrganismTheme.labelLarge.copyWith(color: OrganismTheme.error)),
              const SizedBox(height: OrganismTheme.spacingXs),
              const CellInput(placeholder: 'Field required', hasError: true),
              const SizedBox(height: OrganismTheme.spacingLg),

              Text('System Disabled Lock', style: OrganismTheme.labelLarge),
              const SizedBox(height: OrganismTheme.spacingXs),
              const CellInput(placeholder: 'System generated ID', isDisabled: true),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSemanticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Toggles & Data Capsules', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingSm),
        Text('Visual flags and structural toggles representing the lowest level variables in the ERP.', style: OrganismTheme.bodyMedium),
        const SizedBox(height: OrganismTheme.spacing2Xl),
        
        Wrap(
          spacing: OrganismTheme.spacingXl,
          runSpacing: OrganismTheme.spacingLg,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('<CellCheckbox />', style: OrganismTheme.labelLarge),
                 const SizedBox(height: OrganismTheme.spacingMd),
                 Row(
                  children: [
                    const CellCheckbox(value: false),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellCheckbox(value: true),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellCheckbox(value: false, isDisabled: true),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellCheckbox(value: true, isDisabled: true),
                  ],
                 )
              ],
            ),
            Container(width: 1, height: 60, color: OrganismTheme.border),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('<CellBadge />', style: OrganismTheme.labelLarge),
                 const SizedBox(height: OrganismTheme.spacingMd),
                 Wrap(
                  spacing: OrganismTheme.spacingSm,
                  children: [
                    const CellBadge(text: 'Draft', variant: CellBadgeVariant.secondary),
                    const CellBadge(text: 'Pending', variant: CellBadgeVariant.warning),
                    const CellBadge(text: 'Dispatched', variant: CellBadgeVariant.primary),
                    const CellBadge(text: 'Completed', variant: CellBadgeVariant.success),
                    const CellBadge(text: 'Rejected', variant: CellBadgeVariant.error),
                    const CellBadge(text: 'Outline State', variant: CellBadgeVariant.outline),
                  ],
                 )
              ],
            ),
            Container(width: 1, height: 60, color: OrganismTheme.border),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('<CellSwitch />', style: OrganismTheme.labelLarge),
                 const SizedBox(height: OrganismTheme.spacingMd),
                 Row(
                  children: [
                    const CellSwitch(value: false),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellSwitch(value: true),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellSwitch(value: false, isDisabled: true),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellSwitch(value: true, isDisabled: true),
                  ],
                 )
              ],
            ),
            Container(width: 1, height: 60, color: OrganismTheme.border),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('<CellAvatar /> & <CellLabel />', style: OrganismTheme.labelLarge),
                 const SizedBox(height: OrganismTheme.spacingMd),
                 Row(
                  children: [
                    const CellAvatar(name: 'Smit Kumar', size: 36),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellAvatar(name: 'Ambaji Textiles', size: 36),
                    const SizedBox(width: OrganismTheme.spacingMd),
                    const CellAvatar(name: 'Omega', size: 36),
                    const SizedBox(width: OrganismTheme.spacingXl),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CellLabel(text: 'Standard Validation'),
                        SizedBox(height: 4),
                        CellLabel(text: 'Required Validation', isRequired: true),
                      ]
                    )
                  ],
                 )
              ],
            ),
            Container(width: 1, height: 60, color: OrganismTheme.border),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('<CellSkeleton /> & <CellDivider />', style: OrganismTheme.labelLarge),
                 const SizedBox(height: OrganismTheme.spacingMd),
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CellSkeleton(width: 200, height: 16),
                    SizedBox(height: 8),
                    CellSkeleton(width: 150, height: 16),
                    SizedBox(height: 8),
                    CellDivider(length: 200),
                  ],
                 )
               ],
             ),
             Container(width: 1, height: 60, color: OrganismTheme.border),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('<CellRadio> & <CellSlider>', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  Row(
                   children: [
                     CellRadio<int>(value: 1, groupValue: 1, onChanged: (v){}),
                     CellRadio<int>(value: 2, groupValue: 1, onChanged: (v){}),
                     const SizedBox(width: OrganismTheme.spacingMd),
                     SizedBox(width: 100, child: CellSlider(value: 0.4, onChanged: (v){})),
                   ],
                  )
               ],
             ),
             Container(width: 1, height: 60, color: OrganismTheme.border),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('<CellTooltip>', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellTooltip(
                    message: 'Edit record details',
                    child: CellButton(icon: LucideIcons.edit2, variant: CellButtonVariant.outline, onPressed: (){}, text: ''),
                  )
               ],
             ),
             Container(width: 1, height: 60, color: OrganismTheme.border),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('<CellToggleGroup>', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellToggleGroup<String>(
                    value: 'grid',
                    items: const ['list', 'grid'],
                    itemBuilder: (i) => Icon(i == 'grid' ? LucideIcons.layoutGrid : LucideIcons.list, size: OrganismTheme.iconSizeSm),
                    onChanged: (i) {},
                  ),
               ],
             ),
             Container(width: 1, height: 60, color: OrganismTheme.border),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('<CellInputChip>', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  CellInputChip(label: 'IMMBE2627', onDeleted: () {}),
               ],
             ),
           ],
         )
       ],
     );
    }

  Widget _buildMicroGapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Micro Data Trackers', style: OrganismTheme.titleLarge),
        const SizedBox(height: OrganismTheme.spacingXl),
        
        Wrap(
          spacing: OrganismTheme.spacing2Xl,
          runSpacing: OrganismTheme.spacing2Xl,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('<TissuePipeline />', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  const TissuePipeline(
                    stages: [
                      PipelineStageData(label: 'Cutting', isCompleted: true),
                      PipelineStageData(label: 'Stitching', isActive: true),
                      PipelineStageData(label: 'Dispatch'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('<CellFilterChip />', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  Row(
                    children: [
                      const CellFilterChip(label: 'Party: Shreeji', isSelected: true),
                      const SizedBox(width: OrganismTheme.spacingSm),
                      CellFilterChip(label: 'Dates: Apr 1 - 30', isSelected: true, onDeleted: (){}),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('<TissueStepper />', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  TissueStepper(value: 12, onChanged: (v) {}),
                ],
              ),
            ),
            
            SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('<CellProgressBar />', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  const CellProgressBar(value: 0.65),
                ],
              ),
            ),

            SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('<CellKbd />', style: OrganismTheme.labelLarge),
                  const SizedBox(height: OrganismTheme.spacingMd),
                  const CellKbd(keyString: 'ESC'),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
