import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme.dart';
import 'package:flutter/material.dart';

class LibrarySection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  const LibrarySection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.all(OrganismTheme.spacingLg),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: OrganismTheme.spacingSm,
            bottom: OrganismTheme.spacingXs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: OrganismTheme.labelLarge(context).copyWith(
                  color: colors.textMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: OrganismTheme.bodySmall(context).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: OrganismTheme.borderLg,
            border: Border.all(color: colors.border),
            boxShadow: OrganismTheme.shadowSm,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
        const SizedBox(height: OrganismTheme.spacing2Xl),
      ],
    );
  }
}

class LibraryComponentDoc extends StatelessWidget {
  final String filePath;
  final String description;
  final Widget child;

  const LibraryComponentDoc({
    super.key,
    required this.filePath,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.background, // Nested back out explicitly
        borderRadius: OrganismTheme.borderMd,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doc Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: OrganismTheme.spacingMd,
                vertical: OrganismTheme.spacingSm),
            decoration: BoxDecoration(
              color: colors.stone100.withValues(alpha: 0.5),
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.fileCode, size: 14, color: colors.textMuted),
                const SizedBox(width: OrganismTheme.spacingSm),
                Expanded(
                  child: Text(
                    filePath,
                    style: OrganismTheme.codeTabular(context).copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: description,
                  child:
                      Icon(LucideIcons.info, size: 14, color: colors.textMuted),
                )
              ],
            ),
          ),

          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(OrganismTheme.spacingMd,
                  OrganismTheme.spacingXs, OrganismTheme.spacingMd, 0),
              child: Text(
                description,
                style: OrganismTheme.bodySmall(context).copyWith(
                    color: colors.textMuted, fontStyle: FontStyle.italic),
              ),
            ),

          // Actual Component
          Padding(
            padding: const EdgeInsets.all(OrganismTheme.spacingLg),
            child: child,
          ),
        ],
      ),
    );
  }
}
