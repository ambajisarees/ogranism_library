/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC DETAILS PANE (dy_details_pane.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - High-density right-hand detail inspection canvas for split-view pages.
   - Houses sticky header, metadata key-value grid, image gallery preview,
     item line-table tab, activity history, and action toolbar.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Encapsulated inside `shad.OutlinedContainer` with `colors.card` background.
   - Header matches `DynamicContentPane` and `DynamicDenseTable` sticky headers.
   - Supports key-value info tiles, image gallery lightbox trigger, and line items.
   - Uses native `shadcn_flutter` color, density, and typography tokens strictly.
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../specs/dy_color_system.dart';

/// [DyDetailsPane] — Full-height detail inspection pane for split-view layouts.
class DyDetailsPane extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? statusBadge;
  final Map<String, String> metadata;
  final List<String> imageUrls;
  final Widget? lineItemsTable;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;

  const DyDetailsPane({
    super.key,
    required this.title,
    this.subtitle,
    this.statusBadge,
    this.metadata = const {},
    this.imageUrls = const [],
    this.lineItemsTable,
    this.onClose,
    this.onEdit,
    this.onDelete,
    this.onPrint,
  });

  @override
  State<DyDetailsPane> createState() => _DyDetailsPaneState();
}

class _DyDetailsPaneState extends State<DyDetailsPane> {
  int _activeTabIndex = 0;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = colors.brightness == Brightness.dark;
    final defaultHeaderBg = DyColorSystem.resolveSurfaceCanvas(isDark);

    return shad.OutlinedContainer(
      borderColor: colors.border,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      clipBehavior: Clip.antiAlias,
      backgroundColor: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. STICKY TOP HEADER BAR
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * theme.scaling,
              vertical: 10 * theme.scaling,
            ),
            color: defaultHeaderBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        if (widget.statusBadge != null) ...[
                          SizedBox(width: 8 * theme.scaling),
                          widget.statusBadge!,
                        ],
                      ],
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 2 * theme.scaling),
                      Text(
                        widget.subtitle!,
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                if (widget.onPrint != null) ...[
                  SizedBox(
                    width: 28 * theme.scaling,
                    height: 28 * theme.scaling,
                    child: shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.compact,
                      icon: Icon(shad.LucideIcons.printer, size: 16 * theme.scaling),
                      onPressed: widget.onPrint,
                    ),
                  ),
                  SizedBox(width: 4 * theme.scaling),
                ],
                if (widget.onEdit != null) ...[
                  SizedBox(
                    width: 28 * theme.scaling,
                    height: 28 * theme.scaling,
                    child: shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.compact,
                      icon: Icon(shad.LucideIcons.pencil, size: 16 * theme.scaling),
                      onPressed: widget.onEdit,
                    ),
                  ),
                  SizedBox(width: 4 * theme.scaling),
                ],
                if (widget.onDelete != null) ...[
                  SizedBox(
                    width: 28 * theme.scaling,
                    height: 28 * theme.scaling,
                    child: shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.compact,
                      icon: Icon(shad.LucideIcons.trash2, size: 16 * theme.scaling),
                      onPressed: widget.onDelete,
                    ),
                  ),
                  SizedBox(width: 4 * theme.scaling),
                ],
                if (widget.onClose != null) ...[
                  SizedBox(
                    width: 28 * theme.scaling,
                    height: 28 * theme.scaling,
                    child: shad.IconButton.ghost(
                      size: shad.ButtonSize.small,
                      density: shad.ButtonDensity.compact,
                      icon: Icon(shad.LucideIcons.x, size: 16 * theme.scaling),
                      onPressed: widget.onClose,
                    ),
                  ),
                ],
              ],
            ),
          ),

          shad.Divider(color: colors.border),

          // 2. INNER TAB SWITCHER
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * theme.scaling,
              vertical: 8 * theme.scaling,
            ),
            child: shad.Tabs(
              index: _activeTabIndex,
              onChanged: (idx) => setState(() => _activeTabIndex = idx),
              children: const [
                shad.TabItem(child: Text('Overview')),
                shad.TabItem(child: Text('Items')),
                shad.TabItem(child: Text('Gallery')),
                shad.TabItem(child: Text('History')),
              ],
            ),
          ),

          shad.Divider(color: colors.border),

          // 3. SCROLLABLE TAB BODY
          Expanded(
            child: IndexedStack(
              index: _activeTabIndex,
              children: [
                // TAB 0: OVERVIEW & KEY-VALUE METADATA GRID
                SingleChildScrollView(
                  padding: EdgeInsets.all(16 * theme.scaling),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Featured Hero Image (if available)
                      if (widget.imageUrls.isNotEmpty) ...[
                        Container(
                          height: 200 * theme.scaling,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                            border: Border.all(color: colors.border),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.imageUrls[_selectedImageIndex.clamp(0, widget.imageUrls.length - 1)],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * theme.scaling),
                      ],

                      // Key-Value Grid Specs
                      Wrap(
                        spacing: 12 * theme.scaling,
                        runSpacing: 12 * theme.scaling,
                        children: widget.metadata.entries.map((entry) {
                          return Container(
                            width: 170 * theme.scaling,
                            padding: EdgeInsets.all(10 * theme.scaling),
                            decoration: BoxDecoration(
                              color: colors.muted.withAlpha(50),
                              borderRadius: BorderRadius.circular(theme.radiusSm),
                              border: Border.all(color: colors.border.withAlpha(120)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key.toUpperCase(),
                                  style: theme.typography.xSmall.copyWith(
                                    color: colors.mutedForeground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4 * theme.scaling),
                                Text(
                                  entry.value,
                                  style: theme.typography.textSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // TAB 1: LINE ITEMS TABLE
                widget.lineItemsTable ??
                    Center(
                      child: Text(
                        'No line items available',
                        style: theme.typography.textSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ),

                // TAB 2: GALLERY PREVIEW
                widget.imageUrls.isEmpty
                    ? Center(
                        child: Text(
                          'No images available',
                          style: theme.typography.textSmall.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16 * theme.scaling),
                        itemCount: widget.imageUrls.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 140 * theme.scaling,
                          mainAxisExtent: 140 * theme.scaling,
                          crossAxisSpacing: 12 * theme.scaling,
                          mainAxisSpacing: 12 * theme.scaling,
                        ),
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedImageIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedImageIndex = index),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(theme.radiusSm),
                                border: Border.all(
                                  color: isSelected ? colors.primary : colors.border,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(widget.imageUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                // TAB 3: ACTIVITY HISTORY TIMELINE
                SingleChildScrollView(
                  padding: EdgeInsets.all(16 * theme.scaling),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Timeline',
                        style: theme.typography.h4.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12 * theme.scaling),
                      _buildTimelineTile(
                        context,
                        title: 'Voucher Created',
                        subtitle: 'Created by SM User on 2026-08-01 09:30 AM',
                        icon: shad.LucideIcons.plus,
                      ),
                      _buildTimelineTile(
                        context,
                        title: 'Status Changed to Pending',
                        subtitle: 'System auto-assigned to Cutting Dept',
                        icon: shad.LucideIcons.clock,
                      ),
                      _buildTimelineTile(
                        context,
                        title: 'Quality Verification Completed',
                        subtitle: 'Verified by Quality Inspector',
                        icon: shad.LucideIcons.check,
                      ),
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

  Widget _buildTimelineTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * theme.scaling),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16 * theme.scaling, color: colors.primary),
          SizedBox(width: 10 * theme.scaling),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
