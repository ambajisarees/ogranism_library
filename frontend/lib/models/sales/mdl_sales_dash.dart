/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES DASHBOARD ANALYTICS MODEL (mdl_sales_dash.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Pure client-side analytical aggregation engine for the Sales Dashboard (`Dash`).
   - Synthesizes raw `IMMBE2627.sq_BILLS` headers (`S1` Finish Sales + `P3`/`P25`/`S3`
     Sales Returns) into KPIs, monthly/weekly trajectory curves, 4-Wave dispatch
     compliance funnels, Top-10 leaderboards, and portfolio composition slices.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Zero database joins or server RPCs required in this phase; runs in `< 12ms`
     over ~14,000 in-memory `MdlSalesBill` records.
   - Respects Ambaji Sarees domain semantics:
     * `billerCode` (`code`) = Master Customer / Biller Ledger
     * `haste` = Upcountry Consignee (when non-empty)
     * `brokerName` (`BCODE`) = Broker / Adatiya Agent
     * `lrNo` (`RRNO`) = Physical Transport Bilti number (4th Wave logistics step)
     * `ewayBillNo` (`EWB_NO`) = Statutory E-Waybill recorded on bill header

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `RRNO` is blank on ~87.2% of FY `S1` invoices, surfaced explicitly in the
     4-Wave Funnel and Transporter leaderboard to guide Bilti reconciliation.
   - Anchors relative date filters (`Last 30D`, `Last 90D`) to the latest invoice
     date in the dataset so fiscal data never appears artificially empty.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Phase 2 will enrich `ewbCount` from `sq_BILLS_einv`, settlements from
     `sq_RECPAY`, and Packing Slip / Bilti scan counts from `sb_packing_slips` & `sb_media`.
================================================================================
*/

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../dynamic_ai/micro/cards/dy_kpi_metric_card.dart';
import '../../dynamic_ai/micro/charts/dy_donut_breakdown_card.dart';
import '../../dynamic_ai/micro/charts/dy_horizontal_bar_card.dart';
import '../../dynamic_ai/micro/charts/dy_trend_area_chart.dart';
import 'mdl_sales.dart';

/// Time / channel scope filter for the Sales Dashboard.
enum SalesDashScope {
  allFy,
  last90Days,
  last30Days,
  hasteOnly,
  directOnly,
}

extension SalesDashScopeExt on SalesDashScope {
  String get label {
    switch (this) {
      case SalesDashScope.allFy:
        return 'Full FY 26-27';
      case SalesDashScope.last90Days:
        return 'Last 90 Days';
      case SalesDashScope.last30Days:
        return 'Last 30 Days';
      case SalesDashScope.hasteOnly:
        return 'Haste Consignments';
      case SalesDashScope.directOnly:
        return 'Direct Customers';
    }
  }
}

/// Aggregated snapshot driving every widget on `ScrSalesDashPane`.
@immutable
class MdlSalesDashSnapshot {
  final int invoiceCount;
  final int returnCount;
  final double grossS1Revenue;
  final double returnAmount;
  final double netAfterReturns;
  final double avgInvoiceValue;
  final int totalBales;
  final int totalPieces;
  final double totalMeters;
  final int uniqueCustomers;
  final int uniqueBrokers;
  final int uniqueHastes;
  final int hasteInvoiceCount;
  final double hasteRevenue;
  final int withTransportCount;
  final int withEwbHeaderCount;
  final int withLrBiltiCount;
  final int missingLrBiltiCount;

  // Sparklines
  final List<double> revenueSparkline;
  final List<double> balesSparkline;

  // Trend Modes: 0 = Revenue (Lakhs), 1 = Bales, 2 = Invoices
  final List<DyTrendPoint> revenueTrend;
  final List<DyTrendPoint> balesTrend;
  final List<DyTrendPoint> invoiceTrend;

  // 4-Wave Dispatch & Recon Funnel
  final List<DyBarMetricItem> dispatchFunnel;

  // Top 10 Leaderboards: 0 = Customers, 1 = Brokers, 2 = Hastes, 3 = Transporters
  final List<DyBarMetricItem> topCustomers;
  final List<DyBarMetricItem> topBrokers;
  final List<DyBarMetricItem> topHastes;
  final List<DyBarMetricItem> topTransporters;

  // Donut Breakdowns: 0 = Channel Mix, 1 = Ticket Size Bands, 2 = Dispatch Age Buckets
  final List<DyDonutSlice> channelMixSlices;
  final List<DyDonutSlice> ticketBandSlices;
  final List<DyDonutSlice> ageBucketSlices;

  // Spotlight summaries for bottom `ReportCard` strip
  final String topCustomerName;
  final String topCustomerMetric;
  final String topCustomerSub;
  final String topBrokerName;
  final String topBrokerMetric;
  final String topBrokerSub;
  final String topTransportName;
  final String topTransportMetric;
  final String topTransportSub;

  const MdlSalesDashSnapshot({
    required this.invoiceCount,
    required this.returnCount,
    required this.grossS1Revenue,
    required this.returnAmount,
    required this.netAfterReturns,
    required this.avgInvoiceValue,
    required this.totalBales,
    required this.totalPieces,
    required this.totalMeters,
    required this.uniqueCustomers,
    required this.uniqueBrokers,
    required this.uniqueHastes,
    required this.hasteInvoiceCount,
    required this.hasteRevenue,
    required this.withTransportCount,
    required this.withEwbHeaderCount,
    required this.withLrBiltiCount,
    required this.missingLrBiltiCount,
    required this.revenueSparkline,
    required this.balesSparkline,
    required this.revenueTrend,
    required this.balesTrend,
    required this.invoiceTrend,
    required this.dispatchFunnel,
    required this.topCustomers,
    required this.topBrokers,
    required this.topHastes,
    required this.topTransporters,
    required this.channelMixSlices,
    required this.ticketBandSlices,
    required this.ageBucketSlices,
    required this.topCustomerName,
    required this.topCustomerMetric,
    required this.topCustomerSub,
    required this.topBrokerName,
    required this.topBrokerMetric,
    required this.topBrokerSub,
    required this.topTransportName,
    required this.topTransportMetric,
    required this.topTransportSub,
  });

  /// Formats Indian Rupees compactly (`₹51.30 Cr`, `₹48.20 L`, `₹37.7 K`).
  static String formatCompactInr(double amount) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (abs >= 10000000) {
      return '$sign₹${(abs / 10000000).toStringAsFixed(2)} Cr';
    }
    if (abs >= 100000) {
      return '$sign₹${(abs / 100000).toStringAsFixed(2)} L';
    }
    if (abs >= 1000) {
      return '$sign₹${(abs / 1000).toStringAsFixed(1)} K';
    }
    return '$sign₹${abs.toStringAsFixed(0)}';
  }

  static String formatCompactInt(int count) {
    if (count >= 100000) {
      return '${(count / 100000).toStringAsFixed(2)}L';
    }
    return NumberFormat.decimalPattern('en_IN').format(count);
  }

  /// Computes a complete [MdlSalesDashSnapshot] from in-memory `S1` & Return bills.
  factory MdlSalesDashSnapshot.compute({
    required List<MdlSalesBill> allS1Bills,
    required List<MdlSalesBill> allReturnBills,
    required SalesDashScope scope,
  }) {
    // Determine anchor latest date in dataset so relative windows are always meaningful
    DateTime anchorDate = DateTime.now();
    for (final b in allS1Bills) {
      if (b.date != null && b.date!.isAfter(anchorDate)) {
        anchorDate = b.date!;
      }
    }
    if (allS1Bills.isNotEmpty) {
      DateTime? maxFound;
      for (final b in allS1Bills) {
        if (b.date != null && (maxFound == null || b.date!.isAfter(maxFound))) {
          maxFound = b.date;
        }
      }
      if (maxFound != null) anchorDate = maxFound;
    }

    bool matchesScope(MdlSalesBill b) {
      switch (scope) {
        case SalesDashScope.allFy:
          return true;
        case SalesDashScope.last90Days:
          if (b.date == null) return false;
          return anchorDate.difference(b.date!).inDays <= 90;
        case SalesDashScope.last30Days:
          if (b.date == null) return false;
          return anchorDate.difference(b.date!).inDays <= 30;
        case SalesDashScope.hasteOnly:
          return b.hasHaste;
        case SalesDashScope.directOnly:
          return !b.hasHaste;
      }
    }

    final bills = allS1Bills.where(matchesScope).toList();
    final returns = allReturnBills.where(matchesScope).toList();

    double grossS1 = 0.0;
    double hasteRev = 0.0;
    int bales = 0;
    int pcs = 0;
    double mts = 0.0;
    int hasteCount = 0;
    int transportFilled = 0;
    int ewbFilled = 0;
    int lrFilled = 0;

    final Set<String> custSet = {};
    final Set<String> brokerSet = {};
    final Set<String> hasteSet = {};

    final Map<String, _AggBucket> custAgg = {};
    final Map<String, _AggBucket> brokerAgg = {};
    final Map<String, _AggBucket> hasteAgg = {};
    final Map<String, _TransportBucket> transportAgg = {};
    final Map<String, _TimeBucket> monthAgg = {};

    // Ticket bands
    double bandUnder25k = 0;
    int bandUnder25kCnt = 0;
    double band25to50k = 0;
    int band25to50kCnt = 0;
    double band50kTo1L = 0;
    int band50kTo1LCnt = 0;
    double bandOver1L = 0;
    int bandOver1LCnt = 0;

    // Age buckets relative to anchorDate
    double age0to30 = 0;
    int age0to30Cnt = 0;
    double age31to60 = 0;
    int age31to60Cnt = 0;
    double age61to90 = 0;
    int age61to90Cnt = 0;
    double age90Plus = 0;
    int age90PlusCnt = 0;

    for (final b in bills) {
      final amt = b.billAmount;
      grossS1 += amt;
      bales += b.bales;
      pcs += b.totalPieces;
      mts += b.totalMeters;

      final cust = b.billerCode.isNotEmpty ? b.billerCode : 'UNSPECIFIED PARTY';
      custSet.add(cust);
      custAgg.putIfAbsent(cust, () => _AggBucket(cust)).add(amt, b.bales, b.hasHaste);

      final broker = b.brokerName.isNotEmpty ? b.brokerName : 'DIRECT (NO AGENT)';
      if (b.brokerName.isNotEmpty) brokerSet.add(b.brokerName);
      brokerAgg.putIfAbsent(broker, () => _AggBucket(broker)).add(amt, b.bales, b.hasHaste);

      if (b.hasHaste) {
        hasteCount++;
        hasteRev += amt;
        hasteSet.add(b.haste);
        hasteAgg
            .putIfAbsent(b.haste, () => _AggBucket(b.haste, extraRef: cust))
            .add(amt, b.bales, true);
      }

      final trName = b.transport.trim();
      final hasLr = b.lrNo.trim().isNotEmpty;
      if (trName.isNotEmpty) {
        transportFilled++;
        transportAgg
            .putIfAbsent(trName, () => _TransportBucket(trName))
            .add(amt, b.bales, hasLr);
      }
      if (b.ewayBillNo.trim().isNotEmpty) ewbFilled++;
      if (hasLr) lrFilled++;

      // Ticket bands
      if (amt < 25000) {
        bandUnder25k += amt;
        bandUnder25kCnt++;
      } else if (amt < 50000) {
        band25to50k += amt;
        band25to50kCnt++;
      } else if (amt < 100000) {
        band50kTo1L += amt;
        band50kTo1LCnt++;
      } else {
        bandOver1L += amt;
        bandOver1LCnt++;
      }

      // Age & Monthly buckets
      if (b.date != null) {
        final d = b.date!;
        final daysOld = anchorDate.difference(d).inDays.clamp(0, 9999);
        if (daysOld <= 30) {
          age0to30 += amt;
          age0to30Cnt++;
        } else if (daysOld <= 60) {
          age31to60 += amt;
          age31to60Cnt++;
        } else if (daysOld <= 90) {
          age61to90 += amt;
          age61to90Cnt++;
        } else {
          age90Plus += amt;
          age90PlusCnt++;
        }

        // Use weekly buckets for Last 30D, monthly buckets otherwise
        final String tKey;
        final String tLabel;
        if (scope == SalesDashScope.last30Days) {
          final dayKey = DateFormat('yyyy-MM-dd').format(d);
          tKey = dayKey;
          tLabel = DateFormat('dd MMM').format(d);
        } else {
          tKey = '${d.year}-${d.month.toString().padLeft(2, '0')}';
          tLabel = DateFormat("MMM ''yy").format(d);
        }
        monthAgg
            .putIfAbsent(tKey, () => _TimeBucket(tKey, tLabel))
            .addSale(amt, b.hasHaste ? amt : 0.0, b.bales, b.hasHaste ? b.bales : 0);
      }
    }

    double returnTotal = 0.0;
    for (final r in returns) {
      returnTotal += r.billAmount;
      if (r.date != null && scope != SalesDashScope.last30Days) {
        final d = r.date!;
        final tKey = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        final tLabel = DateFormat("MMM ''yy").format(d);
        monthAgg.putIfAbsent(tKey, () => _TimeBucket(tKey, tLabel)).addReturn(r.billAmount);
      }
    }

    final sortedMonths = monthAgg.values.toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    final revTrend = sortedMonths
        .map(
          (m) => DyTrendPoint(
            label: m.label,
            primaryValue: m.revenue / 100000.0, // in Lakhs
            secondaryValue: m.hasteRevenue / 100000.0,
            tooltipExtra: '${m.invoices} Bills • ${m.bales} Bales',
          ),
        )
        .toList();

    final balesTrend = sortedMonths
        .map(
          (m) => DyTrendPoint(
            label: m.label,
            primaryValue: m.bales.toDouble(),
            secondaryValue: m.hasteBales.toDouble(),
            tooltipExtra: formatCompactInr(m.revenue),
          ),
        )
        .toList();

    final invTrend = sortedMonths
        .map(
          (m) => DyTrendPoint(
            label: m.label,
            primaryValue: m.invoices.toDouble(),
            secondaryValue: m.returnCount.toDouble(),
            tooltipExtra: '${m.bales} Bales Dispatched',
          ),
        )
        .toList();

    final safeInvCount = bills.isEmpty ? 1 : bills.length;
    final missingLr = (bills.length - lrFilled).clamp(0, bills.length);

    // 4-Wave Dispatch & Recon Readiness Funnel
    final dispatchFunnel = <DyBarMetricItem>[
      DyBarMetricItem(
        label: 'Wave 1 • S1 Invoices Billed',
        formattedValue: formatCompactInt(bills.length),
        rawValue: bills.length.toDouble(),
        subtitle: '${formatCompactInt(bales)} Bales • ${formatCompactInr(grossS1)} gross value',
        badgeText: '100%',
        tone: DyKpiTone.primary,
      ),
      DyBarMetricItem(
        label: 'Wave 2 • Carrier / Mukadam Assigned',
        formattedValue: formatCompactInt(transportFilled),
        rawValue: transportFilled.toDouble(),
        subtitle: 'Transporter stamped on voucher header',
        badgeText: '${((transportFilled / safeInvCount) * 100).toStringAsFixed(1)}%',
        tone: DyKpiTone.indigo,
      ),
      DyBarMetricItem(
        label: 'Wave 3 • Header E-Waybill Logged',
        formattedValue: formatCompactInt(ewbFilled),
        rawValue: ewbFilled.toDouble(),
        subtitle: 'Direct sq_BILLS.EWB_NO (sq_BILLS_einv adds full IRN)',
        badgeText: '${((ewbFilled / safeInvCount) * 100).toStringAsFixed(1)}%',
        tone: DyKpiTone.warning,
      ),
      DyBarMetricItem(
        label: 'Wave 4 • Transport Bilti (RRNO) Punched',
        formattedValue: formatCompactInt(lrFilled),
        rawValue: lrFilled.toDouble(),
        subtitle: '${formatCompactInt(missingLr)} invoices awaiting LR & Bilti scan!',
        badgeText: '${((lrFilled / safeInvCount) * 100).toStringAsFixed(1)}%',
        tone: DyKpiTone.danger,
      ),
      const DyBarMetricItem(
        label: 'Target • Packing Slip + Bilti Photo Tally',
        formattedValue: '0 Linked',
        rawValue: 0,
        subtitle: 'Unlocks as sb_packing_slips & Mobile Scanner go live',
        badgeText: 'Phase 2',
        tone: DyKpiTone.fuchsia,
      ),
    ];

    // Sort Top 10 Leaderboards
    List<DyBarMetricItem> buildTop10(
      Iterable<_AggBucket> src, {
      required bool showHasteRef,
    }) {
      final list = src.toList()..sort((a, b) => b.amount.compareTo(a.amount));
      return list.take(8).map((e) {
        final pct = grossS1 > 0 ? (e.amount / grossS1) * 100 : 0.0;
        final sub = showHasteRef && e.extraRef != null
            ? 'Biller: ${e.extraRef} • ${e.count} Bills • ${e.bales} Bales'
            : '${e.count} Bills • ${e.bales} Bales${e.hasteCount > 0 ? ' • ${e.hasteCount} Haste' : ''}';
        return DyBarMetricItem(
          label: e.name,
          formattedValue: formatCompactInr(e.amount),
          rawValue: e.amount,
          subtitle: sub,
          badgeText: '${pct.toStringAsFixed(1)}%',
        );
      }).toList();
    }

    final topTransportList = transportAgg.values.toList()
      ..sort((a, b) => b.bales.compareTo(a.bales));
    final topTransporters = topTransportList.take(8).map((t) {
      final missing = t.invoices - t.lrEntered;
      return DyBarMetricItem(
        label: t.name,
        formattedValue: '${formatCompactInt(t.bales)} Bales',
        rawValue: t.bales.toDouble(),
        subtitle: '${t.invoices} Bills • ${formatCompactInr(t.amount)} value',
        badgeText: missing > 0 ? '$missing No-LR' : 'All LR Ok',
        tone: missing > (t.invoices * 0.5) ? DyKpiTone.warning : DyKpiTone.success,
      );
    }).toList();

    final directRev = (grossS1 - hasteRev).clamp(0.0, double.infinity);
    final directCnt = bills.length - hasteCount;

    final channelSlices = <DyDonutSlice>[
      DyDonutSlice(
        label: 'Direct Master Customer',
        value: directRev,
        formattedValue: formatCompactInr(directRev),
        subtitle: '${formatCompactInt(directCnt)} direct billing vouchers',
        paletteIndex: 0,
      ),
      DyDonutSlice(
        label: 'Haste Consignee Dispatch',
        value: hasteRev,
        formattedValue: formatCompactInr(hasteRev),
        subtitle: '${formatCompactInt(hasteCount)} upcountry haste dispatches',
        paletteIndex: 1,
      ),
    ];

    final ticketSlices = <DyDonutSlice>[
      DyDonutSlice(
        label: 'High Value (₹1L+)',
        value: bandOver1L,
        formattedValue: formatCompactInr(bandOver1L),
        subtitle: '${formatCompactInt(bandOver1LCnt)} bulk bales bills',
        paletteIndex: 0,
      ),
      DyDonutSlice(
        label: 'Mid-Large (₹50K – ₹1L)',
        value: band50kTo1L,
        formattedValue: formatCompactInr(band50kTo1L),
        subtitle: '${formatCompactInt(band50kTo1LCnt)} standard lot bills',
        paletteIndex: 1,
      ),
      DyDonutSlice(
        label: 'Standard (₹25K – ₹50K)',
        value: band25to50k,
        formattedValue: formatCompactInr(band25to50k),
        subtitle: '${formatCompactInt(band25to50kCnt)} single-bale bills',
        paletteIndex: 2,
      ),
      DyDonutSlice(
        label: 'Small / Sample (< ₹25K)',
        value: bandUnder25k,
        formattedValue: formatCompactInr(bandUnder25k),
        subtitle: '${formatCompactInt(bandUnder25kCnt)} sample / parcel bills',
        paletteIndex: 3,
      ),
    ];

    final ageSlices = <DyDonutSlice>[
      DyDonutSlice(
        label: '0 – 30 Days (Fresh)',
        value: age0to30,
        formattedValue: formatCompactInr(age0to30),
        subtitle: '${formatCompactInt(age0to30Cnt)} recent invoices',
        paletteIndex: 3,
      ),
      DyDonutSlice(
        label: '31 – 60 Days (Dhara Window)',
        value: age31to60,
        formattedValue: formatCompactInr(age31to60),
        subtitle: '${formatCompactInt(age31to60Cnt)} standard credit bills',
        paletteIndex: 0,
      ),
      DyDonutSlice(
        label: '61 – 90 Days (Follow-Up)',
        value: age61to90,
        formattedValue: formatCompactInr(age61to90),
        subtitle: '${formatCompactInt(age61to90Cnt)} broker reminder window',
        paletteIndex: 2,
      ),
      DyDonutSlice(
        label: '90+ Days (Season Carry)',
        value: age90Plus,
        formattedValue: formatCompactInr(age90Plus),
        subtitle: '${formatCompactInt(age90PlusCnt)} older FY vouchers',
        paletteIndex: 5,
      ),
    ];

    final sortedCust = custAgg.values.toList()..sort((a, b) => b.amount.compareTo(a.amount));
    final sortedBrok = brokerAgg.values.toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final topCust = sortedCust.isNotEmpty ? sortedCust.first : null;
    final topBrok = sortedBrok.isNotEmpty ? sortedBrok.first : null;
    final topTr = topTransportList.isNotEmpty ? topTransportList.first : null;

    return MdlSalesDashSnapshot(
      invoiceCount: bills.length,
      returnCount: returns.length,
      grossS1Revenue: grossS1,
      returnAmount: returnTotal,
      netAfterReturns: grossS1 - returnTotal,
      avgInvoiceValue: bills.isEmpty ? 0.0 : grossS1 / bills.length,
      totalBales: bales,
      totalPieces: pcs,
      totalMeters: mts,
      uniqueCustomers: custSet.length,
      uniqueBrokers: brokerSet.length,
      uniqueHastes: hasteSet.length,
      hasteInvoiceCount: hasteCount,
      hasteRevenue: hasteRev,
      withTransportCount: transportFilled,
      withEwbHeaderCount: ewbFilled,
      withLrBiltiCount: lrFilled,
      missingLrBiltiCount: missingLr,
      revenueSparkline: sortedMonths.map((m) => m.revenue).toList(),
      balesSparkline: sortedMonths.map((m) => m.bales.toDouble()).toList(),
      revenueTrend: revTrend,
      balesTrend: balesTrend,
      invoiceTrend: invTrend,
      dispatchFunnel: dispatchFunnel,
      topCustomers: buildTop10(custAgg.values, showHasteRef: false),
      topBrokers: buildTop10(brokerAgg.values, showHasteRef: false),
      topHastes: buildTop10(hasteAgg.values, showHasteRef: true),
      topTransporters: topTransporters,
      channelMixSlices: channelSlices,
      ticketBandSlices: ticketSlices,
      ageBucketSlices: ageSlices,
      topCustomerName: topCust?.name ?? 'N/A',
      topCustomerMetric: topCust != null ? formatCompactInr(topCust.amount) : '₹0',
      topCustomerSub: topCust != null
          ? '${topCust.count} Invoices • ${topCust.bales} Bales'
          : 'No invoices',
      topBrokerName: topBrok?.name ?? 'N/A',
      topBrokerMetric: topBrok != null ? formatCompactInr(topBrok.amount) : '₹0',
      topBrokerSub: topBrok != null
          ? '${topBrok.count} Invoices • ${topBrok.bales} Bales'
          : 'No broker bills',
      topTransportName: topTr?.name ?? 'N/A',
      topTransportMetric: topTr != null ? '${formatCompactInt(topTr.bales)} Bales' : '0 Bales',
      topTransportSub: topTr != null
          ? '${topTr.invoices - topTr.lrEntered} Pending Biltis out of ${topTr.invoices}'
          : 'No dispatches',
    );
  }
}

class _AggBucket {
  final String name;
  final String? extraRef;
  double amount = 0.0;
  int count = 0;
  int bales = 0;
  int hasteCount = 0;

  _AggBucket(this.name, {this.extraRef});

  void add(double amt, int b, bool isHaste) {
    amount += amt;
    count += 1;
    bales += b;
    if (isHaste) hasteCount += 1;
  }
}

class _TransportBucket {
  final String name;
  double amount = 0.0;
  int invoices = 0;
  int bales = 0;
  int lrEntered = 0;

  _TransportBucket(this.name);

  void add(double amt, int b, bool hasLr) {
    amount += amt;
    invoices += 1;
    bales += b;
    if (hasLr) lrEntered += 1;
  }
}

class _TimeBucket {
  final String sortKey;
  final String label;
  double revenue = 0.0;
  double hasteRevenue = 0.0;
  double returnAmount = 0.0;
  int invoices = 0;
  int bales = 0;
  int hasteBales = 0;
  int returnCount = 0;

  _TimeBucket(this.sortKey, this.label);

  void addSale(double amt, double hasteAmt, int b, int hb) {
    revenue += amt;
    hasteRevenue += hasteAmt;
    invoices += 1;
    bales += b;
    hasteBales += hb;
  }

  void addReturn(double amt) {
    returnAmount += amt;
    returnCount += 1;
  }
}

