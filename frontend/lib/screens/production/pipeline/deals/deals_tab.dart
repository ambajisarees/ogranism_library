import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:textile_erp/organism_design/index.dart';
import '../../../../models/production/model_grey.dart';
import '../../../../services/production/service_grey.dart';
import 'grey_deal_dialog.dart';


/// [DealsTab] — Renders the Grey Deals registry, details of received transactions,
/// and deals entry overlay. Ported from legacy GreyScreen.
class DealsTab extends StatefulWidget {
  const DealsTab({super.key});

  @override
  State<DealsTab> createState() => _DealsTabState();
}

class _DealsTabState extends State<DealsTab> {
  final GreyService _service = GreyService();

  List<GreyDealModel> _greyDeals = [];
  GreyDealModel? _selectedDeal;
  List<Map<String, dynamic>> _dealReceipts = [];
  
  bool _isLoading = false;
  bool _isReceiptsLoading = false;
  
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  String _searchTerm = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await _service.getGreyDeals(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      if (mounted) {
        setState(() {
          _greyDeals = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
          // Auto-select first item if list is not empty and nothing selected yet
          if (_greyDeals.isNotEmpty && _selectedDeal == null) {
            _onDealSelected(_greyDeals.first);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading Grey Deals: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onDealSelected(GreyDealModel deal) async {
    setState(() {
      _selectedDeal = deal;
      _isReceiptsLoading = true;
      _dealReceipts = [];
    });

    try {
      final receipts = await _service.getReceivedBillsForDeal(deal.orderNo);
      if (mounted && _selectedDeal?.orderNo == deal.orderNo) {
        setState(() {
          _dealReceipts = receipts;
          _isReceiptsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading receipts for deal ${deal.orderNo}: $e');
      if (mounted && _selectedDeal?.orderNo == deal.orderNo) {
        setState(() => _isReceiptsLoading = false);
      }
    }
  }

  // ignore: unused_element
  void _triggerAddDeal() {
    final controller = KineticWorkspaceProvider.of(context);
    controller.showOverlay(
      content: GreyDealAddCanvas(
        onSaved: () {
          controller.hideOverlay();
          setState(() {
            _selectedDeal = null;
            _currentPage = 1;
          });
          _loadData();
        },
        onCancel: () {
          controller.hideOverlay();
        },
      ),
      onCloseRequest: () async => true,
    );
  }

  Widget _buildMetric(String label, String value) {
    final colors = OrganismTheme.colorsOf(context);
    return Column(
      children: [
        Text(
          label,
          style: OrganismTheme.labelMedium(context).copyWith(
            color: colors.textMuted,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          value,
          style: OrganismTheme.monoBody(context).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(fontSize: 14);

    return SystemAppMasterLayout(
      isDetailVisible: _selectedDeal != null,
      paneHeader: OrganPaneHeader(
        title: 'Grey Deals',
        searchController: _searchController,
        onSearchChanged: (val) {
          setState(() {
            _searchTerm = val;
            _currentPage = 1;
            _selectedDeal = null;
          });
          _loadData();
        },
        searchPlaceholder: 'Search by Weaver, Quality...',
        primaryAction: const CellButton(
          text: 'Add',
          icon: LucideIcons.plus,
          variant: CellButtonVariant.primary,
          isCompact: true,
          onPressed: null, // Disabled
        ),
      ),
      paneList: OrganPaneList(
        isLoading: _isLoading,
        itemCount: _greyDeals.length,
        currentPage: _currentPage,
        totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
        totalCount: _totalCount,
        limit: _limit,
        onPageChanged: (p) {
          setState(() {
            _currentPage = p;
            _selectedDeal = null;
          });
          _loadData();
        },
        itemBuilder: (context, index) {
          final item = _greyDeals[index];
          final isSelected = _selectedDeal?.orderNo == item.orderNo;

          final double orderedVal = item.unit == 'PCS'
              ? (item.pcs ?? 0).toDouble()
              : (item.mts ?? 0.0) * (item.lots ?? 1);

          final receivedQty = item.unit == 'PCS'
              ? '${item.rcvPcs} PCS'
              : '${item.rcvMts.toStringAsFixed(1)} M';

          final double rcvVal = item.unit == 'PCS' ? item.rcvPcs.toDouble() : item.rcvMts;
          final progress = orderedVal > 0 ? (rcvVal / orderedVal).clamp(0.0, 1.0) : 0.0;

          return TissueListCard.registry(
            isSelected: isSelected,
            onTap: () => _onDealSelected(item),
            showDivider: true,
            badgeColor: item.closed == 'Y' ? colors.success : colors.primary,
            registryDate: item.date,
            registryTitle: item.weaverGroupName ?? item.gcode,
            registryBadgeText: '${item.orderNo}',
            registryMetricText: 'RCVD: $receivedQty',
            registrySubtitleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER #${item.orderNo} • ${item.qual}'.toUpperCase(),
                  style: OrganismTheme.labelMedium(context).copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    color: isSelected ? colors.primary.withValues(alpha: 0.8) : colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    color: colors.border,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          color: item.closed == 'Y' ? colors.success : colors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      sectionCanvas: _selectedDeal == null ? null : _buildSectionCanvas(colors, monoStyle),
      emptyTitle: 'No Grey Deal Selected',
      emptyMessage: 'Select a grey deal transaction from the list to inspect contract parameters and receipts.',
      emptyIcon: LucideIcons.handshake,
    );
  }

  Widget _buildSectionCanvas(OrganismColors colors, TextStyle monoStyle) {
    final deal = _selectedDeal!;
    final double orderedVal = deal.unit == 'PCS'
        ? (deal.pcs ?? 0).toDouble()
        : (deal.mts ?? 0.0) * (deal.lots ?? 1);

    final displayQty = deal.unit == 'PCS'
        ? '${deal.pcs} PCS'
        : '${orderedVal.toStringAsFixed(1)} M';
    final receivedQty = deal.unit == 'PCS'
        ? '${deal.rcvPcs} PCS'
        : '${deal.rcvMts.toStringAsFixed(1)} M';

    final displayPending = deal.unit == 'PCS'
        ? '${deal.pendingBal.toInt()} PCS'
        : '${deal.pendingBal.toStringAsFixed(1)} M';

    return OrganSectionCanvas(
      title: 'Deal #${deal.orderNo}',
      actions: [
        CellBadge(
          text: deal.closed == 'Y' ? 'CLOSED' : 'OPEN',
          variant: deal.closed == 'Y' ? CellBadgeVariant.success : CellBadgeVariant.primary,
        ),
      ],
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Weaver Group (Anchor)'),
                  TissueCardContent(
                    child: Text(
                      deal.weaverGroupName ?? deal.gcode,
                      style: OrganismTheme.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TissueCardHeader(title: 'Broker / Agent'),
                  TissueCardContent(
                    child: Text(
                      deal.bcode ?? 'DIRECT',
                      style: OrganismTheme.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TissueCardHeader(title: 'Deal Terms'),
            TissueCardContent(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: TissueReadOnlyField(label: 'Quality', value: deal.qual)),
                      Expanded(child: TissueReadOnlyField(label: 'Ordering Unit', value: deal.unit)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TissueReadOnlyField(label: 'Rate', value: '₹${deal.rate.toStringAsFixed(2)}')),
                      Expanded(child: TissueReadOnlyField(label: 'Dhara (Discount)', value: '${deal.disc.toStringAsFixed(2)}%')),
                      Expanded(child: TissueReadOnlyField(label: 'Grace Days', value: '${deal.graceDays} Days')),
                    ],
                  ),
                  if (deal.rmk != null && deal.rmk!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TissueReadOnlyField(label: 'Remarks', value: deal.rmk!),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TissueCardHeader(title: 'Fulfillment Details'),
            TissueCardContent(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('ORDERED', displayQty),
                  _buildMetric('RECEIVED', receivedQty),
                  _buildMetric('PENDING BAL', displayPending),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('LINKED RECEIVED TRANSACTIONS', style: OrganismTheme.titleMedium(context)),
        const SizedBox(height: 8),
        if (_isReceiptsLoading)
          Column(
            children: List.generate(3, (idx) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const CellSkeleton(width: 32, height: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CellSkeleton(width: 140 + (idx * 20.0), height: 14),
                        const SizedBox(height: 6),
                        const CellSkeleton(width: 200, height: 10),
                      ],
                    ),
                  ),
                  const CellSkeleton(width: 80, height: 14),
                ],
              ),
            )),
          )
        else if (_dealReceipts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No fabric received against this deal yet.'),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _dealReceipts.length,
              itemBuilder: (context, index) {
                final rcv = _dealReceipts[index];
                final vno = rcv['VNO'];
                final pcs = (rcv['PCS'] as num?)?.toInt() ?? 0;
                final mts = (rcv['MTS'] as num?)?.toDouble() ?? 0.0;
                final bno = rcv['bill_no'];
                final bdateStr = rcv['bill_date'];

                int leadTimeDays = 0;
                if (bdateStr != null && bdateStr.toString().isNotEmpty) {
                  try {
                    final bdate = DateTime.parse(bdateStr.toString());
                    leadTimeDays = bdate.difference(deal.date).inDays;
                  } catch (_) {}
                }

                return ListTile(
                  dense: true,
                  leading: CellBadge(text: '${index + 1}', variant: CellBadgeVariant.secondary),
                  title: Text('Bill No: $bno (VNO: $vno)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Qty: $pcs Pcs / ${mts.toStringAsFixed(1)} Mts • Lead Time: $leadTimeDays Days'),
                  trailing: Text(bdateStr != null ? bdateStr.toString().split('T')[0] : '', style: const TextStyle(
                    fontFamily: 'Mono',
                    fontWeight: FontWeight.w600,
                  )),
                );
              },
            ),
          ),
      ],
    );
  }
}
