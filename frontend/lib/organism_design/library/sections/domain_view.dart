import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:textile_erp/organism_design/theme.dart';
import 'package:textile_erp/organism_design/domain.dart';
import 'package:textile_erp/organism_design/library/widgets/library_section.dart';

class DomainView extends StatelessWidget {
  const DomainView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductionSection(context, colors),
        _buildFinancialSection(context, colors),
        _buildInventorySection(context, colors),
        _buildRegistrySection(context, colors),
      ],
    );
  }

  Widget _buildProductionSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Production & Factory Floor',
      subtitle: 'Molecules and KPI panels for tracking manufacturing stages.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _doc(
            'OrganKpiStrip',
            'Dashboard-level metric bar for production tracking.',
            const OrganKpiStrip(
              items: [
                DomainKpiTile(label: 'Today Output', value: '450', unit: 'pcs', trend: DomainKpiTrend.up, delta: '+12%'),
                DomainKpiTile(label: 'Pending Mill', value: '1,240', unit: 'mtr', trend: DomainKpiTrend.down, delta: '-5%'),
                DomainKpiTile(label: 'Cutting Rate', value: '88', unit: '%', trend: DomainKpiTrend.neutral, delta: '±0%'),
              ],
            ),
          ),
          const SizedBox(height: OrganismTheme.spacingLg),
          Wrap(
            spacing: OrganismTheme.spacingLg,
            runSpacing: OrganismTheme.spacingLg,
            children: [
              _doc(
                'DomainKpiTile',
                'Individual high-fidelity metric display.',
                const DomainKpiTile(
                  label: 'Efficiency',
                  value: '94',
                  unit: '%',
                  trend: DomainKpiTrend.up,
                  delta: '+2.4%',
                ),
              ),
              _doc(
                'DomainStageBadge',
                'Semantic status mapping for EMPIRE stages.',
                const DomainStageBadge(
                  stage: DomainProductionStage.workInHouse,
                ),
              ),
              _doc(
                'DomainStockIndicator',
                'Linear density bar for reorder level visualization.',
                const SizedBox(
                  width: 180,
                  child: DomainStockIndicator(current: 45.0, max: 100.0),
                ),
              ),
              _doc(
                'DomainProductionTimeline',
                'Stage-wise progression visualization.',
                const SizedBox(
                  width: 300,
                  child: DomainProductionTimeline(
                    currentStage: DomainProductionStage.dispatchStitching,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Financials & Accounting',
      subtitle: 'Type-safe monetary displays and partner identity cards.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _doc(
                  'OrganPartyCard',
                  'Single Source of Truth partner summary panel.',
                  OrganPartyCard(
                    name: 'MAHADEV FASHION',
                    code: 'M001',
                    type: DomainPartyType.debtor,
                    gstin: '24AAAAA0000A1Z5',
                    balance: -125400,
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(width: OrganismTheme.spacingLg),
              Expanded(
                child: _doc(
                  'OrganPartyCard (Supplier)',
                  'Identity and balance tracking for creditors.',
                  OrganPartyCard(
                    name: 'HINDUSTAN TEXTILES',
                    code: 'H022',
                    type: DomainPartyType.creditor,
                    gstin: '24BBBBB1111B2Z6',
                    balance: 85200,
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OrganismTheme.spacingLg),
          Wrap(
            spacing: OrganismTheme.spacingLg,
            runSpacing: OrganismTheme.spacingLg,
            children: [
              _doc(
                'DomainGstBadge',
                'State-aware GSTIN identifier.',
                const DomainGstBadge(gstin: '24AAAAA0000A1Z5'),
              ),
              _doc(
                'DomainPartyTypeBadge',
                'Semantic identity mapping.',
                const DomainPartyTypeBadge(type: DomainPartyType.debtor),
              ),
              _doc(
                'DomainAmount',
                'Standardized currency display with Dr/Cr coloring.',
                const DomainAmount(value: 12500.50, isCredit: true),
              ),
              _doc(
                'DomainVoucherID',
                'Monospaced sequence ID for financial documents.',
                const DomainVoucherID(id: '882', prefix: 'PV'),
              ),
              _doc(
                'DomainGSTBreakdown',
                'Grid-aligned tax summary.',
                SizedBox(
                  width: 240,
                  child: DomainGSTBreakdown(
                    taxMap: {5: 500.0, 12: 1200.0, 18: 0.0},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Inventory & Item Masters',
      subtitle: 'Core product identifiers and stock summary cards.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          _doc(
            'DomainQualityBadge',
            'Primary product category identifier.',
            const DomainQualityBadge(quality: 'Dola Silk'),
          ),
          _doc(
            'DomainDesignID',
            'Unique design/pattern identifier.',
            const DomainDesignID(designNo: '1001-A'),
          ),
          _doc(
            'DomainShadeBadge',
            'Color/Shade specific tag.',
            const DomainShadeBadge(shadeNo: '44'),
          ),
          _doc(
            'DomainInventorySummary',
            'High-level stock stats molecule.',
            const SizedBox(
              width: 200,
              child: DomainInventorySummary(
                pcs: 1450.0,
                mts: 8500.50,
              ),
            ),
          ),
          _doc(
            'DomainItemMasterCard',
            'Registry-density item summary card.',
            SizedBox(
              width: 240,
              child: DomainItemMasterCard(
                quality: 'VICHITRA',
                designNo: '5501',
                shadeNo: '12',
                stock: 45.0,
                maxStock: 100.0,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrySection(BuildContext context, OrganismColors colors) {
    return LibrarySection(
      title: 'Registry & System Metadata',
      subtitle: 'Administrative controls and search results.',
      child: Wrap(
        spacing: OrganismTheme.spacingLg,
        runSpacing: OrganismTheme.spacingLg,
        children: [
          _doc(
            'OrganSyncMonitor',
            'Production heartbeat and sync tracking panel.',
            SizedBox(
              width: 320,
              child: OrganSyncMonitor(
                isSyncing: false,
                lastSync: DateTime.now().subtract(const Duration(minutes: 12)),
                tableCounts: const {
                  'BILLS': 12450,
                  'BILLDET': 88240,
                  'ACMAS': 1391,
                },
                onRefresh: () {},
              ),
            ),
          ),
          _doc(
            'DomainSyncStatus',
            'Supabase-to-Empire state indicator.',
            const DomainSyncStatus(isSynced: true),
          ),
          _doc(
            'DomainAuditLabel',
            'Traceability metadata for documents.',
            DomainAuditLabel(
              userName: 'admin',
              timestamp: DateTime.now(),
            ),
          ),
          _doc(
            'DomainPrintButton',
            'Standardized print triggering action.',
            DomainPrintButton(onPressed: () {}, isThermal: true),
          ),
          _doc(
            'DomainSearchOverlay',
            'High-density result row for global search.',
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  DomainSearchOverlay(
                    title: 'MAHADEV FASHION',
                    subtitle: 'GATHAMAN, SURAT',
                    icon: LucideIcons.user,
                    metric: '₹2.4L',
                    onTap: () {},
                  ),
                  DomainSearchOverlay(
                    title: 'DOLA SILK 1001',
                    subtitle: 'STOCK: 45 PCS',
                    icon: LucideIcons.package,
                    metric: 'SH: 12',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doc(String title, String desc, Widget child) {
    return LibraryComponentDoc(
      filePath: 'domain/${title.toLowerCase()}.dart',
      description: desc,
      child: child,
    );
  }
}
