import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../providers/current_firm_provider.dart';

Future<void> printPdf(
  CurrentFirmProvider firmData, {
  invoice = '',
  required dateTime,
  totalQuantity = 0,
  netAmount = 0,
  itemsList,
  gstDetails,
  required String selectedModeOfPayment,
}) async {
  final pdf = pw.Document();

  // Load NotoSans font with different styles
  final boldFont = await PdfGoogleFonts.notoSansDevanagariBold();
  final regularFont = await PdfGoogleFonts.notoSansDevanagariRegular();
  final italicFont = await PdfGoogleFonts.notoSansDevanagariLight();

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
                  style: pw.TextStyle(font: regularFont, fontSize: 7),
                ),
                pw.Spacer(),
                pw.Text(
                  // DateTime.now().toString(),
                  'Date: ${DateFormat('EEE dd-MM-yyyy').format(dateTime).toString()}',
                  style: pw.TextStyle(font: regularFont, fontSize: 7),
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
            pw.SizedBox(height: 8),

            // Items with proper categorization (Header row bold)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                for (var header in ['Item', 'Qty', 'Rate', 'Amount'])
                  pw.Text(
                    header,
                    style: pw.TextStyle(font: boldFont, fontSize: 8),
                  ),
              ],
            ),
            for (var itemData in itemsList)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          itemData['name'].toString(),
                          style: pw.TextStyle(font: regularFont, fontSize: 8),
                        ),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              // pw.Text(
                              //   'Category: ${itemData['category'].toString()}',
                              //   style: pw.TextStyle(
                              //       font: regularFont, fontSize: 5),
                              // ),
                              // pw.SizedBox(width: 3),
                              pw.Text(
                                'Size: ${itemData['size'].toString()}',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 5),
                              ),
                            ]),
                        pw.Text(
                          itemData['barcode'].toString(),
                          style: pw.TextStyle(font: regularFont, fontSize: 7),
                        ),
                        pw.SizedBox(height: 5),
                      ]),
                  pw.Text(
                    itemData['quantity'].toString(),
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.Text(
                    '₹${itemData['rate'].toString()}',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.Text(
                    '₹${(itemData['rate'] * itemData['quantity']).toString()}',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                ],
              ),
            pw.SizedBox(height: 8),

            // Total Quantity and Net Amount
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Total Quantity:',
                  style: pw.TextStyle(font: regularFont, fontSize: 7),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  totalQuantity.toString(),
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
                pw.Spacer(),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Net Amt.:',
                      style: pw.TextStyle(font: regularFont, fontSize: 7),
                    ),
                    pw.Text(
                      '(incl. of GST)',
                      style: pw.TextStyle(font: regularFont, fontSize: 6),
                    ),
                  ],
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  '₹$netAmount',
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Mode of Payment: $selectedModeOfPayment',
              style: pw.TextStyle(font: italicFont, fontSize: 7),
            ),
            // GST details with a smaller font
            pw.SizedBox(height: 4),

            pw.Column(
              children: [
                pw.Text(
                  'Tax Details:',
                  style: pw.TextStyle(font: regularFont, fontSize: 8),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Total SGST: ₹${gstDetails.totalSgst}, Total CGST: ₹${gstDetails.totalCgst}',
                  style: pw.TextStyle(font: italicFont, fontSize: 8),
                ),
                pw.Text(
                  'Total Tax: ₹${gstDetails.totalTax}',
                  style: pw.TextStyle(font: italicFont, fontSize: 8),
                ),
                // pw.SizedBox(height: 5),
                pw.Text(
                  '---',
                  style: pw.TextStyle(font: italicFont, fontSize: 5),
                ),
                // pw.SizedBox(height: 5),
                pw.Text(
                  'For item less than ₹1000 => CGST(2.5%) + SGST(2.5%)',
                  style: pw.TextStyle(font: italicFont, fontSize: 5),
                ),
                pw.Text(
                  'For item greater than ₹1000 => CGST(6.0%) + SGST(6.0%)',
                  style: pw.TextStyle(font: italicFont, fontSize: 5),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              height: 35,
              data: invoice.toString(),
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
  final PrintingInfo info = await Printing.info();

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => bytes,
    name: 'example.pdf',
    format: format,
    dynamicLayout: true,
  );
}
