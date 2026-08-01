/*
================================================================================
LLM CONTEXT & QUERY SPACE — DYNAMIC GRID CARD (dy_grid_card.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Interactive card tile widget for multi-column grid view rendering (`dy_view_card.dart`).
   - Features fabric thumbnail preview header with status badge overlay, title/voucher
     middle metadata, key metrics footer row, and dynamic selection hover state.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Card width auto-fits grid cross-axis extent (target ~320px).
   - Selection state paints 2.0px `colors.primary` border outline.
   - Hover state applies subtle accent fill tinting.
   - Uses native `shadcn_flutter` color tokens (`colors.card`, `colors.border`, `theme.radiusMd`).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Data item model for [DyGridCard].
class DyGridItem {
  final String id;
  final String title;
  final String voucherNo;
  final String partyName;
  final String designPattern;
  final String quantity;
  final String amount;
  final Widget? statusBadge;
  final String? thumbnailUrl;
  final List<String> imageUrls;
  final Map<String, dynamic>? rawData;

  const DyGridItem({
    required this.id,
    required this.title,
    required this.voucherNo,
    required this.partyName,
    required this.designPattern,
    required this.quantity,
    required this.amount,
    this.statusBadge,
    this.thumbnailUrl,
    this.imageUrls = const [],
    this.rawData,
  });
}

/// [DyGridCard] — Visual Tile Card Widget for Cards View Grid Layout.
class DyGridCard extends StatefulWidget {
  final DyGridItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const DyGridCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DyGridCard> createState() => _DyGridCardState();
}

class _DyGridCardState extends State<DyGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final borderColor = widget.isSelected
        ? colors.primary
        : (_isHovered ? colors.primary.withAlpha(150) : colors.border);

    final cardBg = widget.isSelected
        ? colors.primary.withAlpha(15)
        : (_isHovered ? colors.accent.withAlpha(120) : colors.card);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Image Thumbnail Preview Header (with Status Chip Overlay)
              Stack(
                children: [
                  Container(
                    height: 120 * theme.scaling,
                    width: double.infinity,
                    color: colors.muted.withAlpha(80),
                    child: widget.item.thumbnailUrl != null &&
                            widget.item.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            widget.item.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackThumbnail(theme, colors),
                          )
                        : _buildFallbackThumbnail(theme, colors),
                  ),
                  if (widget.item.statusBadge != null)
                    Positioned(
                      top: 8 * theme.scaling,
                      right: 8 * theme.scaling,
                      child: widget.item.statusBadge!,
                    ),
                ],
              ),

              shad.Divider(color: colors.border),

              // 2. Middle Details Area (Voucher #, Title, Party & Fabric Pattern)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12 * theme.scaling),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.item.voucherNo,
                                style: theme.typography.mono.copyWith(
                                  fontSize: 12 * theme.scaling,
                                  color: colors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.item.designPattern,
                                style: theme.typography.xSmall.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * theme.scaling),
                          Text(
                            widget.item.title,
                            style: theme.typography.textSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2 * theme.scaling),
                          Text(
                            widget.item.partyName,
                            style: theme.typography.xSmall.copyWith(
                              color: colors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // 3. Bottom Key Metrics Badge Row (Quantity & Value)
                      Row(
                        children: [
                          shad.PrimaryBadge(
                            child: Text(
                              widget.item.quantity,
                              style: theme.typography.xSmall,
                            ),
                          ),
                          SizedBox(width: 6 * theme.scaling),
                          shad.SecondaryBadge(
                            child: Text(
                              widget.item.amount,
                              style: theme.typography.xSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail(shad.ThemeData theme, shad.ColorScheme colors) {
    return Container(
      color: colors.primary.withAlpha(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              shad.LucideIcons.scissors,
              size: 28 * theme.scaling,
              color: colors.primary,
            ),
            SizedBox(height: 4 * theme.scaling),
            Text(
              'Fabric Lot #${widget.item.voucherNo.replaceAll(RegExp(r'[^\d]'), '')}',
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
