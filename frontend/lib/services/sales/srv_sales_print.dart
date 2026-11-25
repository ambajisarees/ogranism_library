/*
================================================================================
LLM CONTEXT & QUERY SPACE — SALES PRINT & EXPORT SERVICE (srv_sales_print.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - High-level orchestration service for Tax Invoice printing, PDF rendering,
     and disk exports for the Sales module (`sales` / `so`).
   - Connects `SrvSalesPdfBuilder` with `printing` and `file_picker` libraries.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Single Invoice Actions:
     * `generateInvoicePdfBytes`: Computes in-memory PDF byte stream.
     * `directPrint`: Dispatches vector print job to Windows default/selected printer.
     * `downloadPdfToFile`: Opens Windows Save File Dialog (`INV_<billNo>.pdf`).
     * `sharePdf`: Opens system share sheet or clipboard.
   - Multi-Invoice Actions:
     * `directPrintBatch`: Dispatches combined multi-page print stream.
     * `downloadBatchPdfToFile`: Saves combined PDF to disk.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Handles empty line items by falling back gracefully without crash.
   - Safe file I/O using `file_picker` with `.pdf` extension enforcement.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Batch thermal barcode sticker printing will connect here once label templates are added.
================================================================================
*/

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';

import '../../models/core/sq/sq_billdet.dart';
import '../../models/sales/mdl_sales.dart';
import 'srv_sales_pdf_builder.dart';

/// [SrvSalesPrint] — Singleton service handling print jobs and PDF file exports.
class SrvSalesPrint {
  static final SrvSalesPrint _instance = SrvSalesPrint._internal();
  factory SrvSalesPrint() => _instance;
  SrvSalesPrint._internal();

  /// Generates the raw PDF bytes for a single invoice.
  Future<Uint8List> generateInvoicePdfBytes(
    MdlSalesBill bill,
    List<SqBilldetModel> lineItems,
  ) async {
    return SrvSalesPdfBuilder.buildSingleInvoicePdf(bill, lineItems);
  }

  /// Sends a single invoice directly to the Windows printer spooler.
  Future<bool> directPrint(
    MdlSalesBill bill,
    List<SqBilldetModel> lineItems,
  ) async {
    try {
      final bytes = await generateInvoicePdfBytes(bill, lineItems);
      return await Printing.layoutPdf(
        name: 'Tax_Invoice_${bill.billNo}',
        onLayout: (format) async => bytes,
      );
    } catch (e) {
      debugPrint('Error during directPrint: $e');
      return false;
    }
  }

  /// Prompts user with a Windows Save File Dialog to save the invoice as a PDF file.
  Future<String?> downloadPdfToFile(
    MdlSalesBill bill,
    List<SqBilldetModel> lineItems,
  ) async {
    try {
      final bytes = await generateInvoicePdfBytes(bill, lineItems);
      final defaultFileName = 'INV_${bill.billNo}_${bill.billerCode.replaceAll(RegExp(r'[^\w\s-]'), '')}.pdf';

      final outputPath = await FilePicker.saveFile(
        dialogTitle: 'Save Tax Invoice PDF',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );

      if (outputPath != null && outputPath.isNotEmpty) {
        final finalPath = outputPath.endsWith('.pdf') ? outputPath : '$outputPath.pdf';
        final file = File(finalPath);
        if (!await file.exists()) {
          await file.writeAsBytes(bytes);
        }
        return finalPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error saving PDF to file: $e');
      return null;
    }
  }

  /// Generates combined PDF bytes for a batch of multiple invoices.
  Future<Uint8List> generateBatchPdfBytes(
    List<InvoicePrintBundle> bundles,
  ) async {
    return SrvSalesPdfBuilder.buildBatchInvoicesPdf(bundles);
  }

  /// Prints multiple invoices continuously in a single multi-page print job.
  Future<bool> directPrintBatch(
    List<InvoicePrintBundle> bundles,
  ) async {
    try {
      final bytes = await generateBatchPdfBytes(bundles);
      return await Printing.layoutPdf(
        name: 'Sales_Invoices_Batch_${bundles.length}',
        onLayout: (format) async => bytes,
      );
    } catch (e) {
      debugPrint('Error during directPrintBatch: $e');
      return false;
    }
  }

  /// Saves a batch of multiple invoices as a single combined PDF.
  Future<String?> downloadBatchPdfToFile(
    List<InvoicePrintBundle> bundles,
  ) async {
    try {
      final bytes = await generateBatchPdfBytes(bundles);
      final defaultFileName = 'Sales_Invoices_Batch_${bundles.length}_records.pdf';

      final outputPath = await FilePicker.saveFile(
        dialogTitle: 'Save Batch Invoices PDF',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );

      if (outputPath != null && outputPath.isNotEmpty) {
        final finalPath = outputPath.endsWith('.pdf') ? outputPath : '$outputPath.pdf';
        final file = File(finalPath);
        if (!await file.exists()) {
          await file.writeAsBytes(bytes);
        }
        return finalPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error saving batch PDF to file: $e');
      return null;
    }
  }
}
