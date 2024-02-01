import 'package:billx/models/barcode.dart';
import 'package:xml/xml.dart' as xml;

void exportBillDetailsToXml(
    List<Barcode> nonReturnedItems,
    List<Barcode> returnedItems,
    String invoiceNum,
    String dateTime,
    double netAmount,
    double totalTax,
    bool isSplit,
    int cash,
    int online,
    bool isPos,
    bool isUpi,
    int disc) {
  final xmlBuilder = xml.XmlBuilder();

  xmlBuilder.element('BillDetails', nest: () {
    xmlBuilder.element('InvoiceNumber', nest: invoiceNum);
    xmlBuilder.element('DateTime', nest: dateTime);

    // Non-Returned Items
    xmlBuilder.element('NonReturnedItems', nest: () {
      for (var item in nonReturnedItems) {
        xmlBuilder.element('Item', nest: () {
          xmlBuilder.element('Name', nest: item.name);
          xmlBuilder.element('Rate', nest: item.rate.toString());
          xmlBuilder.element('Barcode', nest: item.barcode);
          xmlBuilder.element('Quantity', nest: item.quantity.toString());
        });
      }
    });

    // Returned Items
    xmlBuilder.element('ReturnedItems', nest: () {
      for (var item in returnedItems) {
        xmlBuilder.element('Item', nest: () {
          xmlBuilder.element('Name', nest: item.name);
          xmlBuilder.element('Rate', nest: item.rate.toString());
          xmlBuilder.element('Barcode', nest: item.barcode);
          xmlBuilder.element('Quantity', nest: item.quantity.toString());
        });
      }
    });

    xmlBuilder.element('NetAmount', nest: netAmount.toString());
    xmlBuilder.element('TotalTax', nest: totalTax.toString());

    if (isSplit) {
      xmlBuilder.element('Cash', nest: cash.toString());
      xmlBuilder.element('Online', nest: online.toString());
    }

    if (isPos) {
      xmlBuilder.element('ModeOfPayment', nest: 'POS Machine');
    } else if (isUpi) {
      xmlBuilder.element('ModeOfPayment', nest: 'UPI');
    }

    xmlBuilder.element('Discount', nest: disc.toString());
  });

  final xmlDocument = xmlBuilder.buildFragment();

  // Now you can use xmlDocument.toString() to get the XML string.
  print(xmlDocument.toXmlString(pretty: true));
}
