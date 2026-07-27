import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ShowcaseOverlaysDialogs extends StatefulWidget {
  const ShowcaseOverlaysDialogs({super.key});

  @override
  State<ShowcaseOverlaysDialogs> createState() => _ShowcaseOverlaysDialogsState();
}

class _ShowcaseOverlaysDialogsState extends State<ShowcaseOverlaysDialogs> {
  bool _isSheetOpen = false;

  void _showStandardDialog(BuildContext context) {
    const shad.DialogOverlayHandler().show(
      context: context,
      alignment: Alignment.center,
      builder: (context) {
        return SizedBox(
          width: 440,
          child: shad.AlertDialog(
            title: const Text('Update Party Credit Limit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set new credit threshold limit for Ambaji Traders (Surat).'),
                const shad.DensityGap(shad.gapMd),
                const shad.TextField(
                  placeholder: Text('Enter amount e.g. ₹5,00,000'),
                ),
              ],
            ),
            actions: [
              shad.OutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              shad.PrimaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    const shad.DialogOverlayHandler().show(
      context: context,
      alignment: Alignment.center,
      builder: (context) {
        return SizedBox(
          width: 420,
          child: shad.AlertDialog(
            title: const Row(
              children: [
                Icon(shad.LucideIcons.triangleAlert, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Delete Cutting Batch?'),
              ],
            ),
            content: const Text(
              'This action cannot be undone. Batch #C-2049 will be permanently removed from FY 26-27 records.',
            ),
            actions: [
              shad.OutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep Batch'),
              ),
              shad.DestructiveButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Delete Permanently'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPopover(BuildContext context) {
    final theme = shad.Theme.of(context);
    shad.showOverlay(
      context,
      shad.PopoverConfiguration(
        alignment: Alignment.bottomLeft,
        offset: const Offset(0, 8),
        builder: (context) {
          return shad.ModalContainer(
            child: SizedBox(
              width: 260,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Party Quick Info', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                    const shad.DensityGap(shad.gapSm),
                    Text('Ambaji Textiles (Pvt Ltd)', style: theme.typography.xSmall),
                    Text('GST: 24AAAAA0000A1Z5', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                    Text('Phone: +91 98251 00000', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                    const shad.DensityGap(shad.gapMd),
                    shad.PrimaryButton(
                      size: shad.ButtonSize.small,
                      onPressed: () => shad.closeOverlay(context),
                      child: const Text('View Full Ledger'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Text('Overlays, Popovers, Drawers & Dialogs', style: theme.typography.h2),
              Text(
                'Interactive floating overlays, popovers, sheets, context menus, and side drawer panels for desktop workflows.',
                style: theme.typography.textMuted,
              ),
              const shad.DensityGap(shad.gapLg),

              // 1. Dialogs & Modals Triggers
              shad.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modal & Alert Dialog Triggers', style: theme.typography.h3),
                    const shad.DensityGap(shad.gapMd),
                    Wrap(
                      spacing: 16 * theme.scaling,
                      runSpacing: 12 * theme.scaling,
                      children: [
                        shad.PrimaryButton(
                          onPressed: () => _showStandardDialog(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(shad.LucideIcons.slidersHorizontal, size: 16),
                              shad.DensityGap(shad.gapSm),
                              Text('Open Form Modal Dialog'),
                            ],
                          ),
                        ),
                        shad.DestructiveButton(
                          onPressed: () => _showAlertDialog(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(shad.LucideIcons.trash2, size: 16),
                              shad.DensityGap(shad.gapSm),
                              Text('Open Delete Confirmation Dialog'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // 2. Popovers & Hover Cards
              shad.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Popovers & Context Hover Cards', style: theme.typography.h3),
                    const shad.DensityGap(shad.gapMd),
                    Wrap(
                      spacing: 20 * theme.scaling,
                      runSpacing: 16 * theme.scaling,
                      children: [
                        // Popover Trigger
                        Builder(
                          builder: (btnContext) {
                            return shad.OutlineButton(
                              onPressed: () => _showPopover(btnContext),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(shad.LucideIcons.user, size: 16),
                                  shad.DensityGap(shad.gapSm),
                                  Text('Trigger Anchored Popover'),
                                ],
                              ),
                            );
                          },
                        ),
                        // Hover Card Container Demo
                        shad.OutlinedContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const shad.Avatar(initials: 'AM', size: 32),
                                const shad.DensityGap(shad.gapMd),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hover Card Target', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Hover mouse to reveal quick card', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // 3. Side Drawers & Sheets
              shad.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Side Drawers & Slide-Over Sheets (ERP Record Inspectors)', style: theme.typography.h3),
                    Text(
                      'Right-side drawer panel used for inspecting detail lines, editing records, or audit histories.',
                      style: theme.typography.textSmall.copyWith(color: colors.mutedForeground),
                    ),
                    const shad.DensityGap(shad.gapMd),
                    shad.PrimaryButton(
                      onPressed: () => setState(() => _isSheetOpen = true),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(shad.LucideIcons.panelRightOpen, size: 16),
                          shad.DensityGap(shad.gapSm),
                          Text('Open Right-Side Drawer Sheet'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // 4. Directional Tooltips
              shad.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Directional Tooltips', style: theme.typography.h3),
                    const shad.DensityGap(shad.gapMd),
                    Wrap(
                      spacing: 16 * theme.scaling,
                      runSpacing: 12 * theme.scaling,
                      children: [
                        shad.Tooltip(
                          tooltip: (context) => const shad.TooltipContainer(child: Text('Top Tooltip: Save voucher (Ctrl+S)')),
                          alignment: Alignment.topCenter,
                          child: const shad.OutlineButton(child: Text('Top Tooltip')),
                        ),
                        shad.Tooltip(
                          tooltip: (context) => const shad.TooltipContainer(child: Text('Bottom Tooltip: Download PDF Report')),
                          alignment: Alignment.bottomCenter,
                          child: const shad.OutlineButton(child: Text('Bottom Tooltip')),
                        ),
                        shad.Tooltip(
                          tooltip: (context) => const shad.TooltipContainer(child: Text('Left Tooltip: Refresh connection')),
                          alignment: Alignment.centerLeft,
                          child: const shad.OutlineButton(child: Text('Left Tooltip')),
                        ),
                        shad.Tooltip(
                          tooltip: (context) => const shad.TooltipContainer(child: Text('Right Tooltip: System settings')),
                          alignment: Alignment.centerRight,
                          child: const shad.OutlineButton(child: Text('Right Tooltip')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const shad.DensityGap(shad.gapLg),

              // 5. Dropdown & Context Menus
              shad.Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dropdown & Context Menus', style: theme.typography.h3),
                    const shad.DensityGap(shad.gapMd),
                    Wrap(
                      spacing: 20 * theme.scaling,
                      runSpacing: 16 * theme.scaling,
                      children: [
                        // Dropdown Action List
                        shad.OutlinedContainer(
                          child: SizedBox(
                            width: 240,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMenuItem(context, 'Edit Cutting Batch', shad.LucideIcons.pencil, 'Ctrl+E'),
                                _buildMenuItem(context, 'Duplicate Record', shad.LucideIcons.copy, 'Ctrl+D'),
                                _buildMenuItem(context, 'Export to Excel', shad.LucideIcons.fileSpreadsheet, 'Alt+X'),
                                const shad.Divider(),
                                _buildMenuItem(context, 'Delete Batch', shad.LucideIcons.trash2, 'Del', isDestructive: true),
                              ],
                            ),
                          ),
                        ),
                        // Desktop Floating Window Preview Card
                        shad.OutlinedContainer(
                          child: SizedBox(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: colors.muted,
                                  child: Row(
                                    children: [
                                      const Icon(shad.LucideIcons.appWindow, size: 16),
                                      const SizedBox(width: 8),
                                      Text('Floating Sub-Window Scaffold', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      Icon(shad.LucideIcons.x, size: 14, color: colors.mutedForeground),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text('Self-contained desktop dialog window wrapper.', style: theme.typography.xSmall),
                                ),
                              ],
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

        // Slide-Over Sheet Drawer Layer
        if (_isSheetOpen)
          Positioned.fill(
            child: Stack(
              children: [
                // Backdrop
                GestureDetector(
                  onTap: () => setState(() => _isSheetOpen = false),
                  child: Container(
                    color: Colors.black45,
                  ),
                ),
                // Right-Side Drawer Body
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    elevation: 16,
                    color: colors.background,
                    child: SizedBox(
                      width: 380 * theme.scaling,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text('Order Detail Inspector', style: theme.typography.h3),
                                const Spacer(),
                                shad.IconButton.ghost(
                                  icon: const Icon(shad.LucideIcons.x, size: 18),
                                  onPressed: () => setState(() => _isSheetOpen = false),
                                ),
                              ],
                            ),
                          ),
                          const shad.Divider(),
                          // Content Body
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16.0),
                              children: [
                                Text('Voucher: #PO-2026-904', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                const shad.DensityGap(shad.gapSm),
                                Text('Party: Ambaji Sarees Pvt Ltd', style: theme.typography.xSmall),
                                Text('Station: Surat HQ', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                                const shad.DensityGap(shad.gapLg),
                                Text('Line Items Summary', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                const shad.DensityGap(shad.gapSm),
                                _buildDrawerLineItem(context, 'Silk Saree Design #102', '500 Mtr', '₹1,25,000'),
                                _buildDrawerLineItem(context, 'Chiffon Border Roll #88', '200 Mtr', '₹34,000'),
                                _buildDrawerLineItem(context, 'Embroidered Lace Batch', '150 Pcs', '₹45,000'),
                              ],
                            ),
                          ),
                          const shad.Divider(),
                          // Footer Action
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: shad.OutlineButton(
                                    onPressed: () => setState(() => _isSheetOpen = false),
                                    child: const Text('Close Drawer'),
                                  ),
                                ),
                                const shad.DensityGap(shad.gapMd),
                                Expanded(
                                  child: shad.PrimaryButton(
                                    onPressed: () => setState(() => _isSheetOpen = false),
                                    child: const Text('Confirm Record'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String shortcut, {bool isDestructive = false}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = isDestructive ? colors.destructive : colors.foreground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: theme.typography.textSmall.copyWith(color: textColor)),
          ),
          Text(shortcut, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildDrawerLineItem(BuildContext context, String title, String qty, String total) {
    final theme = shad.Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600)),
                Text(qty, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),
          Text(total, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
