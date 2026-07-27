import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseSettings extends StatefulWidget {
  const PageShowcaseSettings({super.key});

  @override
  State<PageShowcaseSettings> createState() => _PageShowcaseSettingsState();
}

class _PageShowcaseSettingsState extends State<PageShowcaseSettings> {
  bool _autoSync = true;
  String _fiscalSchema = 'immbe2627';

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
                  Text('System Configuration & Airbyte Sync Settings', style: theme.typography.h2),
                  Text('Manage Supabase Postgres 17 target schema IMMBE2627, Airbyte read-only mirrors, and user permissions.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Text('Save Configuration'),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Settings Controls Card
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Airbyte & Database Mirror Controls', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),

                // Auto Sync Toggle
                Row(
                  children: [
                    shad.Switch(
                      value: _autoSync,
                      onChanged: (v) => setState(() => _autoSync = v),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enable Auto Sync with Airbyte MSSQL (AMAZE)', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                        Text('Strict Read-Only sq_* mirror table sync active.', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                      ],
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapMd),
                const shad.Divider(),
                const shad.DensityGap(shad.gapMd),

                // Target Fiscal Schema Radio Group
                Text('Target Fiscal Schema Scope', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                const shad.DensityGap(shad.gapSm),
                shad.RadioGroup<String>(
                  value: _fiscalSchema,
                  onChanged: (val) => setState(() => _fiscalSchema = val),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shad.RadioItem(
                        value: 'immbe2627',
                        trailing: Text('IMMBE2627 (Current Fiscal Year 26-27)', style: theme.typography.textSmall),
                      ),
                      shad.RadioItem(
                        value: 'immbe2526',
                        trailing: Text('IMMBE2526 (Archive Fiscal Year 25-26)', style: theme.typography.textSmall),
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
}
