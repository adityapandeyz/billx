import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/database_helper.dart';
import '../models/split_bill.dart';
import '../providers/current_firm_provider.dart';

class SplitBillProvider extends ChangeNotifier {
  Exception? connectionException;
  List<SplitBill>? _splitBillList;
  List<SplitBill>? _filteredSplitBillList;
  late DatabaseHelper _databaseHelper;

  SplitBillProvider(BuildContext context) {
    _databaseHelper = DatabaseHelper.instance;
    loadSplitBills(context);
  }

  List<SplitBill>? get splitBills => _splitBillList;
  List<SplitBill>? get filteredSplitBills => _filteredSplitBillList;

  void connectionFailed(dynamic exception) {
    _splitBillList = null;
    _filteredSplitBillList = null;
    notifyListeners();

    connectionException = exception;
  }

  Future<void> loadSplitBills(BuildContext context) async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final splitBills = await _databaseHelper.getSplitBills(currentFirmId);
      _splitBillList = splitBills;
      _filteredSplitBillList = _splitBillList ?? [];
      notifyListeners();
    } catch (e) {
      connectionFailed(e);
    }
  }

  // Map<String, List<SplitBill>> groupSplitBillsByDate() {
  //   Map<String, List<SplitBill>> groupedBills = {};

  //   if (splitBills != null) {
  //     for (var splitBill in splitBills!) {
  //       String date =
  //           splitBill.createdAt.substring(0, 10); // Extract date from createdAt
  //       if (groupedBills.containsKey(date)) {
  //         groupedBills[date]!.add(splitBill);
  //       } else {
  //         groupedBills[date] = [splitBill];
  //       }
  //     }
  //   }

  //   return groupedBills;
  // }

  Future<void> deleteSplitBill(int id, context) async {
    try {
      await _databaseHelper.deleteSplitBill(id);
      await loadSplitBills(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  void filterBills(
    context,
    searchText,
  ) {
    if (splitBills != null) {
      if (searchText.isEmpty) {
        _filteredSplitBillList = List.from(_splitBillList!);
      } else {
        _filteredSplitBillList = _splitBillList!
            .where((onlineBill) =>
                onlineBill.invoice
                    .toUpperCase()
                    .contains(searchText.toString().toUpperCase()) ||
                onlineBill.netAmount
                    .toString()
                    .toUpperCase()
                    .contains(searchText.toString().toUpperCase()))
            .toList();
      }
      notifyListeners();
    }
  }

  Future<void> createSplitBill(context, SplitBill splitBill) async {
    try {
      await _databaseHelper.insertSplitBill(splitBill);

      await loadSplitBills(context);
    } catch (e) {
      connectionFailed(e);
    }
  }
}
