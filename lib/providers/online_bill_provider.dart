import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/database_helper.dart';
import '../models/online_bill.dart';
import 'current_firm_provider.dart';

class OnlineBillProvider extends ChangeNotifier {
  Exception? connectionException;
  List<OnlineBill>? onlineBillList;
  List<OnlineBill>? filteredOnlineBillList;
  late DatabaseHelper databaseHelper;

  OnlineBillProvider(BuildContext context) {
    databaseHelper = DatabaseHelper.instance;
  }

  List<OnlineBill>? get onlineBills => onlineBillList;
  List<OnlineBill>? get filteredOnlineBills => filteredOnlineBillList;

  void connectionFailed(dynamic exception) {
    onlineBillList = null;
    filteredOnlineBillList = null;
    notifyListeners();

    connectionException = exception;
  }

  Future<void> loadOnBills(BuildContext context) async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final onlineBills = await databaseHelper.getOnlineBills(currentFirmId);
      onlineBillList = onlineBills;
      filteredOnlineBillList = onlineBillList ?? [];
      notifyListeners();
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> deleteOnlineBill(int id, context) async {
    try {
      await databaseHelper.deleteOnlineBill(id);
      await loadOnBills(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> createOnlineBill(context, OnlineBill onlineBill) async {
    try {
      await databaseHelper.insertOnlineBill(onlineBill);
      await loadOnBills(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  void filterBills(
    context,
    searchText,
  ) {
    if (onlineBills != null) {
      if (searchText.isEmpty) {
        filteredOnlineBillList = List.from(onlineBillList!);
      } else {
        filteredOnlineBillList = onlineBillList!
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
}
