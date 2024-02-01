import 'package:flutter/material.dart'; // Add this import
import 'package:provider/provider.dart';
import '../helpers/database_helper.dart';
import '../models/item.dart';
import 'current_firm_provider.dart';

class ItemProvider extends ChangeNotifier {
  List<Item>? itemList;
  List<Item>? filteredItemList;
  late DatabaseHelper databaseHelper;
  Exception? connectionException;

  // Add a constructor to receive the context
  ItemProvider(BuildContext context) {
    databaseHelper = DatabaseHelper.instance;
    loadItems(context);
  }

  List<Item>? get items => itemList;
  List<Item>? get filteredItems => filteredItemList;

  Future<void> loadItems(BuildContext context) async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final items = await databaseHelper.getAllItems(currentFirmId);

      itemList = items;
      filteredItemList = itemList ?? [];
      notifyListeners();
    } catch (e) {
      connectionFailed(e);
    }
  }

  void connectionFailed(dynamic exception) {
    itemList = null;
    filteredItemList = null;
    notifyListeners();

    connectionException = exception;
  }

  Future<void> deleteItem(Item item, context) async {
    try {
      await databaseHelper.deleteItem(item);
      await loadItems(context); // Pass context here
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> createItem(Item item, context) async {
    try {
      await databaseHelper.insertItem(item);
      await loadItems(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> updateItem(Item item, context) async {
    try {
      await databaseHelper.updateItem(item);
      await loadItems(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  void filterItems(BuildContext context, String value) {
    if (itemList != null) {
      if (value.isEmpty) {
        // If search text is empty, display all items
        filteredItemList = List.from(itemList!);
      } else {
        filteredItemList = itemList!
            .where((item) =>
                item.name.toLowerCase().contains(value.toLowerCase()) ||
                item.itemId.toLowerCase().contains(value.toLowerCase()) ||
                item.barcode.toLowerCase().contains(value.toLowerCase()) ||
                item.size.toLowerCase().contains(value.toLowerCase()) ||
                item.price
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                item.category.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }

      notifyListeners();
    }
  }

  Future<String> getNextItemId(String categoryCode, context) async {
    try {
      await loadItems(context); // Load all items
      if (items == null) {
        return '${categoryCode}t1'; // If no items exist, start with 1
      }

      int itemCount =
          items!.where((item) => item.category == categoryCode).length;

      int nextSequence = itemCount + 1;

      return '${categoryCode}t${nextSequence}';
    } catch (e) {
      connectionFailed(e);
      return ''; // Handle error, return a default value or throw an exception
    }
  }

  Future<Item?> getItemWithId(String itemId, context) async {
    try {
      await loadItems(context);

      Item item = items!.firstWhere((item) => item.itemId == itemId);
      return item;
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> subtractStock(
      String barcode, int quantityToSubtract, context) async {
    try {
      Item item = items!.firstWhere((item) => item.barcode == barcode);

      item.stock -= quantityToSubtract;

      await databaseHelper.updateItem(item);

      await loadItems(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> addStock(String barcode, int quantityToAdd, context) async {
    try {
      Item item = items!.firstWhere((item) => item.barcode == barcode);

      item.stock += quantityToAdd;

      await databaseHelper.updateItem(item);

      await loadItems(context);
    } catch (e) {
      connectionFailed(e);
    }
  }
}
