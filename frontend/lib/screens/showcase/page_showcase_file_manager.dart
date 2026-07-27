import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PageShowcaseFileManager extends StatefulWidget {
  const PageShowcaseFileManager({super.key});

  @override
  State<PageShowcaseFileManager> createState() => _PageShowcaseFileManagerState();
}

class _PageShowcaseFileManagerState extends State<PageShowcaseFileManager> {
  final List<Map<String, String>> _files = const [
    {'name': 'Design_Artwork_D4089.pdf', 'size': '4.2 MB', 'date': '24/07/2026', 'type': 'PDF Artwork'},
    {'name': 'Purchase_Bill_PO90481.pdf', 'size': '1.8 MB', 'date': '22/07/2026', 'type': 'Voucher Tax PDF'},
    {'name': 'Recipe_Formula_V3.json', 'size': '124 KB', 'date': '19/07/2026', 'type': 'JSON Spec'},
    {'name': 'Airbyte_Sync_Log_Jul25.txt', 'size': '45 KB', 'date': '25/07/2026', 'type': 'System Log'},
  ];

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
                  Text('Mill Document Vault & File Manager', style: theme.typography.h2),
                  Text('Organize design CAD artworks, purchase bill tax PDFs, and recipe specification backups.', style: theme.typography.textMuted),
                ],
              ),
              const Spacer(),
              shad.PrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shad.LucideIcons.upload, size: 16),
                    SizedBox(width: 8),
                    Text('Upload Artwork File'),
                  ],
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapLg),

          // Storage Quota Bar
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Vault Storage Capacity (64.2 GB of 100 GB used)', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('64.2%', style: theme.typography.mono.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                const shad.Progress(progress: 0.642),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapLg),

          // Files Table
          shad.Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Document Vault Repository', style: theme.typography.h3),
                const shad.DensityGap(shad.gapMd),
                shad.OutlinedContainer(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: colors.muted.withAlpha(120),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text('FILE NAME', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('FILE TYPE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('SIZE', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('DATE MODIFIED', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const shad.Divider(),
                      ..._files.map((f) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    Icon(shad.LucideIcons.fileText, size: 16, color: colors.primary),
                                    const SizedBox(width: 8),
                                    Text(f['name']!, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 2, child: Text(f['type']!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground))),
                              Expanded(flex: 2, child: Text(f['size']!, style: theme.typography.textSmall)),
                              Expanded(flex: 2, child: Text(f['date']!, style: theme.typography.textSmall)),
                            ],
                          ),
                        );
                      }),
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
