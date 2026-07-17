import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:textile_erp/organism_design/index.dart';
import '../../models/production/model_grey.dart';
import '../../services/production/service_grey.dart';
import 'pipeline/dialogs/grey_deal_dialog.dart';

class GreyScreen extends StatefulWidget {
  const GreyScreen({super.key});

  @override
  State<GreyScreen> createState() => _GreyScreenState();
}

class _GreyScreenState extends State<GreyScreen> with SingleTickerProviderStateMixin {
  final _service = GreyService();
  late TabController _tabController;
  
  final List<String> _tabNames = ['Grey Deals', 'Grey Purchase', 'Mill Inward'];
  
  // Data for Tab 0: Grey Deals (Orders)
  List<GreyDealModel> _greyDeals = [];
  GreyDealModel? _selectedDeal;
  List<Map<String, dynamic>> _dealReceipts = [];
  bool _isReceiptsLoading = false;

  // Data for Tab 1: Purchase Bills (P1)
  List<GreyPurchaseModel> _purchaseBills = [];
  GreyPurchaseModel? _selectedBill;
  
  // Data for Tab 2: Mill Inward
  List<MillInwardModel> _millInwardBills = [];
  MillInwardModel? _selectedInward;

  List<TakaModel> _takas = [];
  
  int _currentPage = 1;
  int _totalCount = 0;
  final int _limit = 50;
  bool _isLoading = false;
  bool _isDetailLoading = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentPage = 1;
          _selectedDeal = null;
          _selectedBill = null;
          _selectedInward = null;
          _detailsClear();
        });
        _loadData();
      }
    });
    _loadData();
  }

  void _detailsClear() {
    _takas = [];
    _dealReceipts = [];
    _isDetailLoading = false;
    _isReceiptsLoading = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    if (_tabController.index == 0) {
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
        });
      }
    } else if (_tabController.index == 1) {
      final result = await _service.getPurchaseBills(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      if (mounted) {
        setState(() {
          _purchaseBills = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
        });
      }
    } else {
      final result = await _service.getMillInwardBills(
        offset: (_currentPage - 1) * _limit,
        limit: _limit,
        searchTerm: _searchTerm,
      );
      if (mounted) {
        setState(() {
          _millInwardBills = result.data;
          _totalCount = result.totalCount;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTakaDetails(int vno, String type) async {
    setState(() {
      _isDetailLoading = true;
      _takas = [];
    });
    
    final details = await _service.getBillDetails(vno, type);
    
    if (mounted) {
      setState(() {
        _takas = details;
        _isDetailLoading = false;
      });
    }
  }

  Future<void> _loadDealDetails(GreyDealModel deal) async {
    setState(() {
      _isReceiptsLoading = true;
      _dealReceipts = [];
    });

    final receipts = await _service.getReceivedBillsForDeal(deal.orderNo);

    if (mounted) {
      setState(() {
        _dealReceipts = receipts;
        _isReceiptsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);
    final monoStyle = OrganismTheme.monoBody(context).copyWith(
      fontSize: 14,
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () => _tabController.animateTo(0),
        const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () => _tabController.animateTo(1),
        const SingleActivator(LogicalKeyboardKey.digit3, alt: true): () => _tabController.animateTo(2),
      },
      child: Focus(
        autofocus: true,
        child: SystemAppMasterLayout(
          isDetailVisible: (_tabController.index == 0
              ? _selectedDeal != null
              : (_tabController.index == 1 ? _selectedBill != null : _selectedInward != null)),
          
          tabs: TissueTabChrome(
            items: [
              CellTabItem(
                icon: LucideIcons.handshake,
                title: _tabNames[0],
                kbdShortcut: 'Alt+1',
                isSelected: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
              CellTabItem(
                icon: LucideIcons.fileText,
                title: _tabNames[1],
                kbdShortcut: 'Alt+2',
                isSelected: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
              CellTabItem(
                icon: LucideIcons.packageCheck,
                title: _tabNames[2],
                kbdShortcut: 'Alt+3',
                isSelected: _tabController.index == 2,
                onTap: () => _tabController.animateTo(2),
              ),
            ],
          ),

          paneHeader: OrganPaneHeader(
            title: _tabNames[_tabController.index],
            onSearchChanged: (val) {
              setState(() {
                _searchTerm = val;
                _currentPage = 1;
              });
              _loadData();
            },
            onAddPressed: _tabController.index == 0
                ? () {
                    final controller = KineticWorkspaceProvider.of(context);
                    controller.showOverlay(
                      content: GreyDealAddCanvas(
                        onSaved: () {
                          controller.hideOverlay();
                          _loadData();
                        },
                        onCancel: () {
                          controller.hideOverlay();
                        },
                      ),
                      onCloseRequest: () async => true,
                    );
                  }
                : null,
            addLabel: _tabController.index == 0 ? 'Add Deal' : '',
          ),

          paneList: OrganPaneList(
            isLoading: _isLoading,
            itemCount: _tabController.index == 0
                ? _greyDeals.length
                : (_tabController.index == 1 ? _purchaseBills.length : _millInwardBills.length),
            currentPage: _currentPage,
            totalPages: (_totalCount / _limit).ceil().clamp(1, 999),
            totalCount: _totalCount,
            limit: _limit,
            onPageChanged: (p) {
              setState(() => _currentPage = p);
              _loadData();
            },
            itemBuilder: (context, index) {
              if (_tabController.index == 0) {
                final item = _greyDeals[index];
                final isSelected = _selectedDeal?.orderNo == item.orderNo;
                
                final double orderedVal = item.unit == 'PCS'
                    ? (item.pcs ?? 0).toDouble()
                    : (item.mts ?? 0.0) * (item.lots ?? 1);
                
                final displayQty = item.unit == 'PCS'
                    ? '${item.pcs} PCS'
                    : '${orderedVal.toStringAsFixed(1)} M';
                final receivedQty = item.unit == 'PCS'
                    ? '${item.rcvPcs} PCS'
                    : '${item.rcvMts.toStringAsFixed(1)} M';

                final double rcvVal = item.unit == 'PCS' ? item.rcvPcs.toDouble() : item.rcvMts;
                final progress = orderedVal > 0 ? (rcvVal / orderedVal).clamp(0.0, 1.0) : 0.0;

                return TissueListCard(
                  isSelected: isSelected,
                  isCompact: false,
                  showDivider: true,
                  onTap: () {
                    setState(() => _selectedDeal = item);
                    _loadDealDetails(item);
                  },
                  leading: CellCardAvatar(date: item.date),
                  title: Text(item.weaverGroupName ?? item.gcode, style: OrganismTheme.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                  )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${item.orderNo} • ${item.qual}', style: OrganismTheme.bodySmall(context)),
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
                  trailing: CellBadge(
                    text: item.closed == 'Y' ? 'CLOSED' : 'OPEN',
                    variant: item.closed == 'Y' ? CellBadgeVariant.success : CellBadgeVariant.primary,
                  ),
                  footer: Row(
                    children: [
                      Text('Rcvd: $receivedQty / $displayQty', style: monoStyle.copyWith(
                        fontSize: 12,
                        color: colors.textSecondary,
                      )),
                      const Spacer(),
                      Text('₹${item.rate.toStringAsFixed(2)}', style: monoStyle.copyWith(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                );
              } else if (_tabController.index == 1) {
                final item = _purchaseBills[index];
                final isSelected = _selectedBill?.vno == item.vno;
                
                return TissueListCard(
                  isSelected: isSelected,
                  isCompact: false,
                  showDivider: true,
                  onTap: () {
                    setState(() => _selectedBill = item);
                    _loadTakaDetails(item.vno, 'P1');
                  },
                  leading: CellCardAvatar(date: item.date),
                  title: Text(item.qual, style: monoStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
                  subtitle: Text(item.code.replaceAll('*', '').trim(), style: OrganismTheme.bodyMedium(context)),
                  trailing: Text(item.vno.toString(), style: monoStyle.copyWith(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
                  footer: Row(
                    children: [
                      Text('${item.totMts.toStringAsFixed(2)} M', style: monoStyle.copyWith(
                        fontSize: 12,
                        color: colors.textSecondary,
                      )),
                      const Spacer(),
                      Text('₹${item.rate.toStringAsFixed(2)}', style: monoStyle.copyWith(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                );
              } else {
                final item = _millInwardBills[index];
                final isSelected = _selectedInward?.vno == item.vno;
                return TissueListCard(
                  isSelected: isSelected,
                  isCompact: false,
                  showDivider: true,
                  onTap: () {
                    setState(() => _selectedInward = item);
                    _loadTakaDetails(item.vno, 'J1');
                  },
                  leading: CellCardAvatar(date: item.date),
                  title: Text(item.qual, style: monoStyle.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.code.replaceAll('*', '').trim(), style: OrganismTheme.bodyMedium(context)),
                  trailing: Text(item.vno.toString(), style: monoStyle.copyWith(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
                  footer: Row(
                    children: [
                      Text('${item.totMts.toStringAsFixed(2)} M', style: monoStyle.copyWith(fontSize: 12)),
                      const Spacer(),
                      Text('${item.totPcs} PCS', style: monoStyle.copyWith(fontSize: 12)),
                    ],
                  ),
                );
              }
            },
          ),

          sectionCanvas: _buildSectionCanvas(),

          emptyTitle: _tabNames[_tabController.index],
          emptyMessage: 'Select a record from the registry to view fabrication and processing details.',
          emptyIcon: _tabController.index == 0
              ? LucideIcons.handshake
              : (_tabController.index == 1 ? LucideIcons.fileText : LucideIcons.packageCheck),
        ),
      ),
    );
  }

  Widget? _buildSectionCanvas() {
    if (_tabController.index == 0 && _selectedDeal == null) return null;
    if (_tabController.index == 1 && _selectedBill == null) return null;
    if (_tabController.index == 2 && _selectedInward == null) return null;

    final colors = OrganismTheme.colorsOf(context);

    if (_tabController.index == 0) {
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
                      child: Text(deal.weaverGroupName ?? deal.gcode, style: OrganismTheme.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      )),
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
                      child: Text(deal.bcode ?? 'DIRECT', style: OrganismTheme.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      )),
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
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
                  if (bdateStr.isNotEmpty) {
                    try {
                      final bdate = DateTime.parse(bdateStr);
                      leadTimeDays = bdate.difference(deal.date).inDays;
                    } catch (_) {}
                  }

                  return ListTile(
                    dense: true,
                    leading: CellBadge(text: '${index + 1}', variant: CellBadgeVariant.secondary),
                    title: Text('Bill No: $bno (VNO: $vno)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Qty: $pcs Pcs / ${mts.toStringAsFixed(1)} Mts • Lead Time: $leadTimeDays Days'),
                    trailing: Text(bdateStr.split('T')[0], style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.w600,
                    )),
                  );
                },
              ),
            ),
        ],
      );
    }

    final title = _tabController.index == 1 ? _selectedBill!.code : 'Inward No: ${_selectedInward!.vno}';
    final currentQual = _tabController.index == 1 ? _selectedBill!.qual : _selectedInward!.qual;
    final currentMts = _tabController.index == 1 ? _selectedBill!.totMts : _selectedInward!.totMts;
    final currentPcs = _tabController.index == 1 ? _selectedBill!.totPcs : _selectedInward!.totPcs;
    final currentFinalAmt = _tabController.index == 1 ? _selectedBill!.finalAmt : _selectedInward!.finalAmt;

    return OrganSectionCanvas(
      title: title,
      actions: const [
        CellButton(text: 'Print', icon: LucideIcons.printer, variant: CellButtonVariant.ghost),
      ],
      children: [
        CellBox(
          padding: const EdgeInsets.all(OrganismTheme.spacingMd),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    currentQual, 
                    style: OrganismTheme.titleSmall(context).copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('METERS', currentMts),
                  _buildMetric('CARDS', currentPcs),
                  _buildMetric('NET AMT', currentFinalAmt),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isDetailLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_takas.isNotEmpty)
          SizedBox(
            height: 480,
            child: ListView.builder(
              itemCount: _takas.length,
              itemBuilder: (context, index) {
                final taka = _takas[index];
                return ListTile(
                  dense: true,
                  leading: CellBadge(text: '${index + 1}', variant: CellBadgeVariant.secondary),
                  title: Text(taka.qual, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Lot: ${taka.lotNo} • Rate: ₹${taka.rate.toStringAsFixed(2)}'),
                  trailing: Text('${taka.mts.toStringAsFixed(2)} M', style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w600,
                  )),
                );
              },
            ),
          )
        else 
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No Taka Details Found'),
            ),
          ),
      ],
    );
  }

  Widget _buildMetric(String label, dynamic value) {
    final colors = OrganismTheme.colorsOf(context);
    return Column(
      children: [
        Text(label, style: OrganismTheme.labelMedium(context).copyWith(
          color: colors.textMuted,
          letterSpacing: 1.1,
        )),
        Text(value.toString(), style: OrganismTheme.monoBody(context).copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        )),
      ],
    );
  }
}
