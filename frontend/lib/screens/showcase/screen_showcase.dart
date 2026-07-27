import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

// Import 16 Showcase Page Modules
import 'page_showcase_classic_dashboard.dart';
import 'page_showcase_ecommerce_dashboard.dart';
import 'page_showcase_payment_dashboard.dart';
import 'page_showcase_mill_dashboard.dart';
import 'page_showcase_product_list.dart';
import 'page_showcase_product_detail.dart';
import 'page_showcase_add_product.dart';
import 'page_showcase_order_list.dart';
import 'page_showcase_order_detail.dart';
import 'page_showcase_stock_location.dart';
import 'page_showcase_kanban.dart';
import 'page_showcase_notes_tasks.dart';
import 'page_showcase_crm.dart';
import 'page_showcase_file_manager.dart';
import 'page_showcase_settings.dart';
import 'page_showcase_profile_empty.dart';
import 'page_showcase_dispatch.dart';
import 'page_showcase_aging_analysis.dart';
import 'page_showcase_broker_commission.dart';
import 'page_showcase_price_matrix.dart';
import 'page_showcase_claims_notes.dart';

class ScreenShowcase extends StatefulWidget {
  const ScreenShowcase({super.key});

  @override
  State<ScreenShowcase> createState() => _ScreenShowcaseState();
}

class _ScreenShowcaseState extends State<ScreenShowcase> {
  int _selectedPageIndex = 0;

  final List<Map<String, dynamic>> _pageScenarios = const [
    {'title': '1. Executive Classic Dashboard', 'category': 'DASHBOARDS', 'widget': PageShowcaseClassicDashboard()},
    {'title': '2. E-Commerce & B2B Sales Dashboard', 'category': 'DASHBOARDS', 'widget': PageShowcaseEcommerceDashboard()},
    {'title': '3. Payment & Cashflow Dashboard', 'category': 'DASHBOARDS', 'widget': PageShowcasePaymentDashboard()},
    {'title': '4. Mill & Dyeing Operations Dashboard', 'category': 'DASHBOARDS', 'widget': PageShowcaseMillDashboard()},
    {'title': '5. Saree Catalog Product List', 'category': 'PRODUCTS & MASTERS', 'widget': PageShowcaseProductList()},
    {'title': '6. Recipe Specification Detail Sheet', 'category': 'PRODUCTS & MASTERS', 'widget': PageShowcaseProductDetail()},
    {'title': '7. New Design & Voucher Entry (Add Page)', 'category': 'PRODUCTS & MASTERS', 'widget': PageShowcaseAddProduct()},
    {'title': '8. Purchase & Sales Order Ledger', 'category': 'ORDERS & INVENTORY', 'widget': PageShowcaseOrderList()},
    {'title': '9. Voucher Inspection Canvas (Detail)', 'category': 'ORDERS & INVENTORY', 'widget': PageShowcaseOrderDetail()},
    {'title': '10. Warehouse Stock & Location Grid', 'category': 'ORDERS & INVENTORY', 'widget': PageShowcaseStockLocation()},
    {'title': '11. Production Stage Kanban Board', 'category': 'APPS & CRM', 'widget': PageShowcaseKanban()},
    {'title': '12. Mill Notes & Task Checklist', 'category': 'APPS & CRM', 'widget': PageShowcaseNotesTasks()},
    {'title': '13. CRM & Customer WhatsApp Exchange', 'category': 'APPS & CRM', 'widget': PageShowcaseCrm()},
    {'title': '14. Mill Document Vault & File Manager', 'category': 'APPS & CRM', 'widget': PageShowcaseFileManager()},
    {'title': '15. System Configuration & Airbyte Settings', 'category': 'SYSTEM & UTILITIES', 'widget': PageShowcaseSettings()},
    {'title': '16. User Profile & Empty State Patterns', 'category': 'SYSTEM & UTILITIES', 'widget': PageShowcaseProfileEmpty()},
    {'title': '17. Dispatch Gate Pass & Transport LR Sheet', 'category': 'DISPATCH & LOGISTICS', 'widget': PageShowcaseDispatch()},
    {'title': '18. Party Outstanding 30-60-90 Day Aging', 'category': 'FINANCE & CREDIT', 'widget': PageShowcaseAgingAnalysis()},
    {'title': '19. Agent & Broker Commission Settlement', 'category': 'BROKERAGE & AGENTS', 'widget': PageShowcaseBrokerCommission()},
    {'title': '20. Tiered Quantity Slab Price List Manager', 'category': 'PRICING & DISCOUNTS', 'widget': PageShowcasePriceMatrix()},
    {'title': '21. Goods Return, Credit & Debit Notes Canvas', 'category': 'CLAIMS & RETURNS', 'widget': PageShowcaseClaimsNotes()},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final currentScenario = _pageScenarios[_selectedPageIndex];

    return Scaffold(
      body: Column(
        children: [
          // Top Showcase Control Header Strip with Select Switcher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                // Icon & Label
                Icon(shad.LucideIcons.layoutGrid, size: 20, color: colors.primary),
                const SizedBox(width: 10),
                Text('ERP Page Showcase:', style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),

                // Scenario Select Switcher Dropdown (16 Pages)
                Builder(
                  builder: (context) {
                    return shad.OutlineButton(
                      onPressed: () {
                        shad.showOverlay(
                          context,
                          shad.PopoverConfiguration(
                            alignment: Alignment.bottomLeft,
                            offset: const Offset(0, 4),
                            builder: (context) => shad.ModalContainer(
                              child: SizedBox(
                                width: 340,
                                height: 420,
                                child: ListView.builder(
                                  itemCount: _pageScenarios.length,
                                  itemBuilder: (context, idx) {
                                    final p = _pageScenarios[idx];
                                    final isSelected = idx == _selectedPageIndex;
                                    return shad.Button.ghost(
                                      onPressed: () {
                                        shad.closeOverlay(context);
                                        setState(() => _selectedPageIndex = idx);
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            p['title'],
                                            style: theme.typography.textSmall.copyWith(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? colors.primary : colors.foreground,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isSelected) const Icon(shad.LucideIcons.check, size: 14),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(currentScenario['title'], style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Icon(shad.LucideIcons.chevronDown, size: 14, color: colors.mutedForeground),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Scenario Counter Badge
                shad.SecondaryBadge(
                  child: Text('Scenario ${_selectedPageIndex + 1} of ${_pageScenarios.length}'),
                ),
                const SizedBox(width: 16),

                // Previous Button
                shad.OutlineButton(
                  onPressed: _selectedPageIndex > 0
                      ? () => setState(() => _selectedPageIndex--)
                      : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shad.LucideIcons.chevronLeft, size: 14),
                      SizedBox(width: 4),
                      Text('Previous'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Next Button
                shad.OutlineButton(
                  onPressed: _selectedPageIndex < _pageScenarios.length - 1
                      ? () => setState(() => _selectedPageIndex++)
                      : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Next'),
                      SizedBox(width: 4),
                      Icon(shad.LucideIcons.chevronRight, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Active Page View Slot
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: currentScenario['widget'] as Widget,
            ),
          ),
        ],
      ),
    );
  }
}
