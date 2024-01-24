import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../providers/current_firm_provider.dart';

Future<void> printPdf(
  CurrentFirmProvider firmData, {
  isSplit = false,
  invoice = '',
  required dateTime,
  totalQuantity = 0,
  netAmount = 0,
  required itemsList,
  required gstDetails,
  cashAmount = 0,
  onlineAmount = 0,
  required String selectedModeOfPayment,
  discAmount,
}) async {
  final List<Map<String, dynamic>> returnedItems = [];
  final List<Map<String, dynamic>> nonReturnedItems = [];

  for (var itemData in itemsList) {
    if (itemData['isBeingReturned'] == true) {
      returnedItems.add(itemData);
    } else {
      nonReturnedItems.add(itemData);
    }
  }

  final pdf = pw.Document();

  // Load NotoSans font with different styles
  final boldFont = await PdfGoogleFonts.notoSansDevanagariBold();
  final regularFont = await PdfGoogleFonts.notoSansDevanagariRegular();
  // final italicFont = await PdfGoogleFonts.notoSansDevanagariLight();

  // Set the custom paper size for POS printing (adjust width as needed)
  const PdfPageFormat format =
      PdfPageFormat.roll80; // A4 size, you can adjust the width

  // Build the entire content in a single Column wrapped in a Container with padding
  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(16), // Add your desired padding
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey300,
              ),
              child: pw.Text(
                firmData.currentFirmName,
                style: pw.TextStyle(font: boldFont, fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 8),

            // Address
            pw.Text(
              firmData.currentFirmAddress,
              style: pw.TextStyle(font: regularFont, fontSize: 11),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 8),

            // Phone and GSTIN

            pw.Text(
              'Phone: ${firmData.currentFirmPhone.toString()}',
              style: pw.TextStyle(font: regularFont, fontSize: 9),
            ),
            pw.Text(
              'GSTIN: ${firmData.currentFirmGSTIN}',
              style: pw.TextStyle(font: regularFont, fontSize: 9),
            ),

            pw.SizedBox(height: 16),

            // Invoice details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Invoice# $invoice',
                  style: pw.TextStyle(font: boldFont, fontSize: 8),
                ),
                pw.Spacer(),
                pw.Text(
                  // DateTime.now().toString(),
                  'Date: ${DateFormat('EEE dd-MM-yyyy').format(dateTime).toString()}',
                  style: pw.TextStyle(font: boldFont, fontSize: 8),
                ),
              ],
            ),

            pw.SizedBox(height: 8),

            // POS INVOICE
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey300,
              ),
              child: pw.Text(
                'POS INVOICE',
                style: pw.TextStyle(font: regularFont, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Divider(),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Item',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Qty',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Rate',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Amount',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                  ],
                ),
              ],
            ),
            for (var itemData in nonReturnedItems)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${itemData['name']}',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${itemData['quantity']}',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${itemData['rate']}',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${(itemData['rate'] * itemData['quantity'])}',
                        style: pw.TextStyle(font: boldFont, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),

            for (var itemData in returnedItems)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${itemData['name']}',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '- ${itemData['quantity']}',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${itemData['rate']}',
                        style: pw.TextStyle(font: regularFont, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '- ${(itemData['rate'] * itemData['quantity'])}',
                        style: pw.TextStyle(font: boldFont, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),

            pw.Divider(),

            // Total Quantity and Net Amount
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Total Items:',
                  style: pw.TextStyle(font: boldFont, fontSize: 7),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  totalQuantity.toString(),
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
                pw.Spacer(),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Net Amt.:(INR)',
                      style: pw.TextStyle(font: boldFont, fontSize: 7),
                    ),
                    pw.Text(
                      '(incl. of GST)',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ],
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  ' $netAmount',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
              ],
            ),
            discAmount != 0.0
                ? pw.Column(
                    children: [
                      pw.Divider(),
                      pw.Text(
                        'Disc. Amount: Rs. $discAmount',
                        style: pw.TextStyle(font: boldFont, fontSize: 8),
                      ),
                    ],
                  )
                : pw.SizedBox(),
            pw.Divider(),
            isSplit == false
                ? pw.Text(
                    'Mode of Payment: $selectedModeOfPayment',
                    style: pw.TextStyle(font: boldFont, fontSize: 8),
                  )
                : pw.Column(
                    children: [
                      pw.Text(
                        'Split Bill',
                        style: pw.TextStyle(font: regularFont, fontSize: 8),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Cash Amt.: $cashAmount',
                        style: pw.TextStyle(font: boldFont, fontSize: 9),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Online Amt.: $onlineAmount',
                        style: pw.TextStyle(font: boldFont, fontSize: 9),
                      ),
                      pw.Text(
                        'Mode: $selectedModeOfPayment',
                        style: pw.TextStyle(font: boldFont, fontSize: 8),
                      ),
                    ],
                  ),

            pw.Divider(),
            pw.Column(
              children: [
                pw.Text(
                  'Tax Details:',
                  style: pw.TextStyle(font: regularFont, fontSize: 8),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Total SGST: ${gstDetails.totalSgst.toStringAsFixed(2)}, Total CGST: ${gstDetails.totalCgst.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: regularFont, fontSize: 8),
                ),
                pw.Text(
                  'Total Tax: Rs. ${gstDetails.totalTax.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: regularFont, fontSize: 8),
                ),
                // pw.SizedBox(height: 5),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              height: 35,
              data: invoice.toString().toLowerCase(),
              // errorBuilder: (context, error) => Center(child: Text(error)),
            ),
            // Footer
            pw.SizedBox(height: 5),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey300,
              ),
              child: pw.Text(
                'Thanks for shopping with us!',
                style: pw.TextStyle(font: regularFont, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  final Uint8List bytes = await pdf.save();

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => bytes,
    name: 'billx_invoice.pdf',
    format: format,
    dynamicLayout: true,
  );
}
