import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseProfileEmpty extends StatefulWidget {
  const PageShowcaseProfileEmpty({super.key});

  @override
  State<PageShowcaseProfileEmpty> createState() => _PageShowcaseProfileEmptyState();
}

class _PageShowcaseProfileEmptyState extends State<PageShowcaseProfileEmpty> {
  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Profile & Empty State Patterns', style: theme.typography.h2),
                  Text('Employee profile card, security roles, and 4 standardized empty state layouts.', style: theme.typography.textMuted),
                ],
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Employee Profile Card
          shad.Card(
            child: Row(
              children: [
                const shad.Avatar(initials: 'SM', size: 64),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sushil Mittal (Administrator)', style: theme.typography.h3),
                    Text('Role: Master AI ERP Systems Operator • Branch: Surat HQ', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    const shad.DensityGap(shad.gapSm),
                    const shad.PrimaryBadge(child: Text('Full Schema IMMBE2627 Access')),
                  ],
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // 4 Empty State Patterns Grid
          Text('Standardized Empty State Patterns', style: theme.typography.h3),
          const shad.DensityGap(shad.gapMd),
          Row(
            children: [
              Expanded(child: _buildEmptyCard(context, icon: shad.LucideIcons.searchX, title: 'No Search Results', desc: 'No saree designs match filter criteria.')),
              const shad.DensityGap(shad.gapMd),
              Expanded(child: _buildEmptyCard(context, icon: shad.LucideIcons.wifiOff, title: 'No Airbyte Sync', desc: 'Check network connection to Supabase.')),
              const shad.DensityGap(shad.gapMd),
              Expanded(child: _buildEmptyCard(context, icon: shad.LucideIcons.fileX2, title: 'No Vouchers Created', desc: 'Click "New Voucher" to issue purchase order.')),
              const shad.DensityGap(shad.gapMd),
              Expanded(child: _buildEmptyCard(context, icon: shad.LucideIcons.shieldAlert, title: 'Access Restricted', desc: 'Requires Master Admin permission token.')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, {required IconData icon, required String title, required String desc}) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Icon(icon, size: 36, color: colors.mutedForeground),
            const shad.DensityGap(shad.gapSm),
            Text(title, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const shad.DensityGap(shad.gapSm),
            Text(desc, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
