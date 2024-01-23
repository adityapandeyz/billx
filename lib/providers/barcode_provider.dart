import 'package:flutter/material.dart';
import '../models/barcode.dart';

class BarcodeProvider extends ChangeNotifier {
  final List<Barcode> _barcodes = [];

  double discAmount = 0.0;
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

  double calculateTotalSumOfRates() {
    double totalSum = 0;

    for (var barcode in barcodes) {
      if (!barcode.isBeingReturned) {
        totalSum += barcode.rate * barcode.quantity;
      }
    }

    return (totalSum - discAmount);
  }

  double calculateTotalSumOfRatesForReturn() {
    double totalReturnSum = 0;

    for (var barcode in barcodes) {
      if (barcode.isBeingReturned) {
        totalReturnSum += barcode.rate * barcode.quantity;
      }
    }

    return totalReturnSum;
  }

  int calculateTotalQuantity() {
    int totalQuantity = 0;

    for (var barcode in barcodes) {
      if (!barcode.isBeingReturned) {
        totalQuantity += barcode.quantity;
      }
    }

    return totalQuantity;
  }

  int calculateTotalReturnQuantity() {
    int totalReturnQuantity = 0;

    for (var barcode in barcodes) {
      if (barcode.isBeingReturned) {
        totalReturnQuantity += barcode.quantity;
      }
    }

    return totalReturnQuantity;
  }

  GstTotals calculateGstForAll() {
    GstTotals gstTotals = GstTotals();

    for (var barcode in barcodes) {
      if (!barcode.isBeingReturned) {
        double gstRate = determineGstRate(barcode.rate);

        // Calculate exclusive GST amount
        double gstAmountExclusive = (barcode.rate * gstRate) / 100;

        // Calculate inclusive GST amount
        double gstAmountInclusive = gstAmountExclusive / (1 + gstRate / 100);

        // Calculate inclusive rate
        double inclusiveRate = barcode.rate + gstAmountInclusive;

        // Calculate CGST and SGST based on inclusive rate
        barcode.cgst = gstAmountInclusive / 2;
        barcode.sgst = gstAmountInclusive / 2;

        // Update totals
        gstTotals.totalCgst += barcode.cgst * barcode.quantity;
        gstTotals.totalSgst += barcode.sgst * barcode.quantity;
        gstTotals.totalTax += gstAmountInclusive * barcode.quantity;
      }
    }

    return gstTotals;
  }

  double determineGstRate(int rate) {
    if (rate <= 1000) {
      return 5.0; // 5% GST for rate not exceeding Rs. 1000
    } else {
      return 12.0; // 12% GST for rate exceeding Rs. 1000
    }
  }
}

class GstTotals {
  double totalCgst = 0;
  double totalSgst = 0;
  double totalTax = 0;
}
