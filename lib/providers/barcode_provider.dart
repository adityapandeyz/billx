import 'package:flutter/material.dart';
import '../models/barcode.dart';

class BarcodeProvider extends ChangeNotifier {
  final List<Barcode> _barcodes = [];

  List<Barcode> get barcodes => _barcodes;

  void addItem(Barcode barcode) {
    _barcodes.add(barcode);

    notifyListeners();
  }

  void removeItem(Barcode barcode) {
    _barcodes.remove(barcode);
    // calculateGstForAll();
    notifyListeners();
  }

  void updateQuantity(Barcode barcode, int newQuantity) {
    final index = barcodes.indexWhere((e) => e.barcode == barcode.barcode);

    if (index != -1) {
      barcodes[index].quantity = newQuantity;
      notifyListeners(); // Notify listeners when data changes
    }
  }

  GstTotals calculateGstForAll() {
    GstTotals gstTotals = GstTotals();

    for (var barcode in _barcodes) {
      // Assuming barcode.rate is used to determine CGST and SGST, update as needed
      if (barcode.rate < 1000) {
        barcode.cgst = barcode.rate * 0.025 * barcode.quantity; // 2.5%
        barcode.sgst = barcode.rate * 0.025 * barcode.quantity; // 2.5%
      } else {
        barcode.cgst = barcode.rate * 0.06 * barcode.quantity; // 6%
        barcode.sgst = barcode.rate * 0.06 * barcode.quantity; // 6%
      }

      gstTotals.totalCgst += barcode.cgst;
      gstTotals.totalSgst += barcode.sgst;
    }

    gstTotals.totalTax = gstTotals.totalCgst + gstTotals.totalSgst;

    return gstTotals;
  }
}

class GstTotals {
  double totalCgst = 0;
  double totalSgst = 0;
  double totalTax = 0;
}
