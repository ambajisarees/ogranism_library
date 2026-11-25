/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES INVOICE PRINT & PREVIEW DIALOG (dia_sales_invoice_print.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - High-density interactive modal dialog displaying vector A4 Tax Invoice preview
     with 1-click Direct Print, Windows PDF Download, and page zoom navigation.
   - Designed strictly with native `shadcn_flutter` component tokens and layout rules.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses `shad.showOverlay` with `DialogConfiguration` to present the dialog
     without depending on Material's `showDialog`.
   - Bridges `Localizations` with `Locale('en', 'IN')` and `DefaultMaterialLocalizations.delegate`
     for the `PdfPreview` rendering surface.
   - Primary Action: `SrvSalesPrint().directPrint(...)` (Windows printer spooler).
   - Secondary Action: `SrvSalesPrint().downloadPdfToFile(...)` (Save PDF dialog).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Closes using `shad.closeOverlay(context)`.
   - Dialog sizes dynamically to 82% screen width and 88% screen height with safe desktop bounds.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future expansion will allow toggling between Tax Invoice A4 and Thermal Sticker (7.6 x 4.8 cm).
================================================================================
*/

import 'package:flutter/material.dart' hide Card, Tab, Badge;
import 'package:printing/printing.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../models/core/sq/sq_billdet.dart';
import '../../../../models/sales/mdl_sales.dart';
import '../../../../services/sales/srv_sales_pdf_builder.dart';
import '../../../../services/sales/srv_sales_print.dart';

/// [DiaSalesInvoicePrint] — Interactive Tax Invoice Print Preview & Download Modal.
class DiaSalesInvoicePrint extends StatefulWidget {
  final MdlSalesBill bill;
  final List<SqBilldetModel> lineItems;

  const DiaSalesInvoicePrint({
    super.key,
    required this.bill,
    required this.lineItems,
  });

  /// Static helper to trigger the dialog overlay anywhere in the app using shadcn overlay.
  static Future<void> show(
    BuildContext context, {
    required MdlSalesBill bill,
    required List<SqBilldetModel> lineItems,
  }) {
    final completer = shad.showOverlay(
      context,
      const shad.DialogConfiguration(
        barrierDismissible: true,
      ),
      builder: (overlayContext) => DiaSalesInvoicePrint(
        bill: bill,
        lineItems: lineItems,
      ),
    );
    return completer.future;
  }

  @override
  State<DiaSalesInvoicePrint> createState() => _DiaSalesInvoicePrintState();
}

class _DiaSalesInvoicePrintState extends State<DiaSalesInvoicePrint> {
  final SrvSalesPrint _printService = SrvSalesPrint();
  bool _isExporting = false;

  Future<void> _handleDirectPrint() async {
    final success = await _printService.directPrint(widget.bill, widget.lineItems);
    if (!mounted) return;
    if (success) {
      shad.showToast(
        context: context,
        builder: (context, overlay) => shad.Card(
          theme: const shad.CardTheme(padding: EdgeInsets.all(12)),
          child: Text('Print job dispatched for Invoice #${widget.bill.billNo}'),
        ),
      );
    }
  }

  Future<void> _handleDownloadPdf() async {
    setState(() => _isExporting = true);
    final savedPath = await _printService.downloadPdfToFile(widget.bill, widget.lineItems);
    if (!mounted) return;
    setState(() => _isExporting = false);

    if (savedPath != null) {
      shad.showToast(
        context: context,
        builder: (context, overlay) => shad.Card(
          theme: const shad.CardTheme(padding: EdgeInsets.all(12)),
          child: Text('Invoice saved successfully to:\n$savedPath'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final dialogWidth = (mediaQuery.size.width * 0.82).clamp(750.0, 1100.0);
    final dialogHeight = (mediaQuery.size.height * 0.88).clamp(550.0, 850.0);

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: shad.Card(
          theme: const shad.CardTheme(
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. DIALOG TOP BAR
                Container(
                  height: 52 * theme.scaling,
                  padding: EdgeInsets.symmetric(horizontal: 16 * theme.scaling),
                  decoration: BoxDecoration(
                    color: colors.card,
                    border: Border(
                      bottom: BorderSide(color: colors.border, width: 1.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        shad.LucideIcons.printer,
                        size: 18 * theme.scaling,
                        color: colors.primary,
                      ),
                      const shad.DensityGap(shad.gapSm),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tax Invoice #${widget.bill.billNo}',
                                  style: theme.typography.textSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.foreground,
                                  ),
                                ),
                                const shad.DensityGap(shad.gapSm),
                                Focus(
                                  canRequestFocus: false,
                                  skipTraversal: true,
                                  descendantsAreFocusable: false,
                                  child: shad.PrimaryBadge(
                                    child: Text(widget.bill.dispatchStage),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${widget.bill.effectivePartyName} • ${widget.bill.formattedDate} • ${widget.bill.formattedBillAmount}',
                              style: theme.typography.xSmall.copyWith(
                                color: colors.mutedForeground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Actions Row
                      shad.OutlineButton(
                        onPressed: _isExporting ? null : _handleDownloadPdf,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(shad.LucideIcons.download, size: 14),
                            shad.DensityGap(shad.gapSm),
                            Text('Save PDF'),
                          ],
                        ),
                      ),
                      const shad.DensityGap(shad.gapSm),

                      shad.PrimaryButton(
                        onPressed: _handleDirectPrint,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(shad.LucideIcons.printer, size: 14),
                            shad.DensityGap(shad.gapSm),
                            Text('Print'),
                          ],
                        ),
                      ),
                      const shad.DensityGap(shad.gapMd),

                      shad.IconButton.ghost(
                        size: shad.ButtonSize.small,
                        density: shad.ButtonDensity.compact,
                        icon: Icon(shad.LucideIcons.x, size: 18 * theme.scaling),
                        onPressed: () => shad.closeOverlay(context),
                      ),
                    ],
                  ),
                ),

                // 2. VECTOR PDF PREVIEW CANVAS (Bridged with en_IN Localizations)
                Expanded(
                  child: Localizations(
                    locale: const Locale('en', 'IN'),
                    delegates: const [
                      DefaultMaterialLocalizations.delegate,
                      DefaultWidgetsLocalizations.delegate,
                    ],
                    child: Material(
                      type: MaterialType.transparency,
                      child: PdfPreview(
                        build: (format) => SrvSalesPdfBuilder.buildSingleInvoicePdf(
                          widget.bill,
                          widget.lineItems,
                        ),
                        allowPrinting: false,
                        allowSharing: false,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        previewPageMargin: const EdgeInsets.all(16),
                        loadingWidget: const Center(child: shad.CircularProgressIndicator()),
                        pdfFileName: 'Tax_Invoice_${widget.bill.billNo}.pdf',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
