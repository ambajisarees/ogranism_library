import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../cells.dart';
import '../amounts.dart';
import 'identity_badges.dart';

class OrganPartyCard extends StatelessWidget {
  final String name;
  final String code;
  final DomainPartyType type;
  final String gstin;
  final double balance;
  final VoidCallback onTap;

  const OrganPartyCard({
    super.key,
    required this.name,
    required this.code,
    required this.type,
    required this.gstin,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return InkWell(
      onTap: onTap,
      borderRadius: OrganismTheme.borderMd,
      child: Container(
        padding: const EdgeInsets.all(OrganismTheme.spacingLg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: OrganismTheme.borderMd,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: OrganismTheme.titleSmall(context).copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: $code',
                        style: OrganismTheme.monoLabel(context).copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                DomainPartyTypeBadge(type: type),
              ],
            ),
            const SizedBox(height: OrganismTheme.spacingLg),
            DomainGstBadge(gstin: gstin),
            const SizedBox(height: OrganismTheme.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Balance',
                  style: OrganismTheme.labelMedium(context).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                DomainAmount(
                  value: balance.abs(),
                  isCredit: balance > 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
