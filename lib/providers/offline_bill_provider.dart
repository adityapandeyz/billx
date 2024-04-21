import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/database_helper.dart';
import '../models/offline_bill.dart';
import '../providers/current_firm_provider.dart';

class OfflineBillProvider extends ChangeNotifier {
  Exception? connectionException;
  List<OfflineBill>? offlineBillList;
  List<OfflineBill>? filteredOfflineBillList;
  late DatabaseHelper databaseHelper;

  OfflineBillProvider(BuildContext context) {
    databaseHelper = DatabaseHelper.instance;
  }

  List<OfflineBill>? get offlineBills => offlineBillList;
  List<OfflineBill>? get filteredOfflineBills => filteredOfflineBillList;

  void connectionFailed(dynamic exception) {
    offlineBillList = null;
    filteredOfflineBillList = null;
    notifyListeners();

    connectionException = exception;
  }

  Future<void> loadOfflineBills(BuildContext context) async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final offlineBills = await databaseHelper.getOfflineBills(currentFirmId);
      offlineBillList = offlineBills;
      filteredOfflineBillList = offlineBillList ?? [];
      notifyListeners();
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> deleteOfflineBill(int id, context) async {
    try {
      await databaseHelper.deleteOfflineBill(id);
      await loadOfflineBills(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> createOfflineBill(context, OfflineBill offlineBill) async {
    try {
      await databaseHelper.insertOfflineBill(offlineBill);
      loadOfflineBills(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  void filterBills(
    context,
    searchText,
  ) {
    if (offlineBills != null) {
      if (searchText.isEmpty) {
        filteredOfflineBillList = List.from(offlineBillList!);
      } else {
        filteredOfflineBillList = offlineBillList!
            .where((offlineBill) =>
                offlineBill.invoice
                    .toString()
                    .toUpperCase()
                    .contains(searchText.toString().toUpperCase()) ||
                offlineBill.netAmount
                    .toString()
                    .toUpperCase()
                    .contains(searchText.toString().toUpperCase()))
            .toList();
      }
      notifyListeners();
    }
  }
}
