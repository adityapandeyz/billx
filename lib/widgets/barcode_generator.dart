import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printBarcode({
  String itemId = '',
  String size = '',
  String itemName = '',
  String barcode = '',
  double rate = 0,
  String firmName = '',
}) async {
  final pdf = pw.Document();

  // Load NotoSans font with different styles
  final regularFont = await PdfGoogleFonts.notoSansRegular();

  // Set the custom paper size for the T-shirt tag
  const PdfPageFormat format = PdfPageFormat.a6;

  // Build the entire content in a single Column wrapped in a Container with padding
  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              itemName,
              style: pw.TextStyle(font: regularFont, fontSize: 12),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Size: $size',
              style: pw.TextStyle(font: regularFont, fontSize: 10),
            ),
            pw.SizedBox(height: 4),

            pw.Text(
              'ItemId: $itemId',
              style: pw.TextStyle(font: regularFont, fontSize: 10),
            ),
            pw.SizedBox(height: 4),

            pw.Text(
              'Rs. ${rate.toStringAsFixed(2)}',
              style: pw.TextStyle(font: regularFont, fontSize: 15),
            ),
            pw.SizedBox(height: 4),

            // Barcode
            pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              height: 40,
              width: 80,
              data: barcode.toString().toLowerCase(),
            ),

            pw.Divider(),
            pw.Text(
              firmName,
              style: pw.TextStyle(font: regularFont, fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );

  final Uint8List bytes = await pdf.save();
  // final PrintingInfo info = await Printing.info();

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => bytes,
    name: 'tshirt_tag.pdf',
    format: format,
    dynamicLayout: true,
  );
}
