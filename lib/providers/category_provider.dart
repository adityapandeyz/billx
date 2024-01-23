import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/database_helper.dart';
import '../models/category.dart';
import 'current_firm_provider.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category>? filteredItemCategory;
  List<Category>? itemCategoryList;
  late DatabaseHelper databaseHelper;
  Exception? _connectionException;

  CategoryProvider(BuildContext context) {
    databaseHelper = DatabaseHelper.instance;
    loadItemCategories(context);
  }

  List<Category>? get itemCategories => itemCategoryList;

  void loadItemCategories(BuildContext context) async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final itemCategories =
          await DatabaseHelper.instance.getCategories(currentFirmId);

      itemCategoryList = itemCategories;
      filteredItemCategory = itemCategoryList ?? []; // Initialize filtered list
      notifyListeners();
    } catch (e) {
      connectionFailed(e);
    }
  }

  void connectionFailed(dynamic exception) {
    itemCategoryList = null;
    filteredItemCategory = null;
    _connectionException = exception;

    notifyListeners(); // Notify listeners of state change
  }

  Future<void> createItemCategory(Category itemCategory, context) async {
    try {
      await databaseHelper.createCategory(itemCategory);
      loadItemCategories(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> deleteItemCategory(
    Category category,
    context,
  ) async {
    try {
      await DatabaseHelper.instance.deleteCategory(category);
      loadItemCategories(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  Future<void> updateCategory(Category category, context) async {
    try {
      await databaseHelper.updateCategory(category);
      loadItemCategories(context);
    } catch (e) {
      connectionFailed(e);
    }
  }

  void filterCategories(
    BuildContext context,
    String value,
  ) {
    if (itemCategories != null) {
      if (value.isEmpty) {
        filteredItemCategory = List.from(itemCategoryList!);
      } else {
        filteredItemCategory = itemCategoryList!
            .where((category) =>
                category.name.toLowerCase().contains(
                      value.toLowerCase(),
                    ) ||
                category.categoryId.toLowerCase().contains(
                      value.toLowerCase(),
                    ))
            .toList();
      }
      notifyListeners();
    }
  }

  Future<Category?> getCategoryWithId(String categoryId, context) async {
    try {
      loadItemCategories(context);

      Category category = itemCategories!
          .firstWhere((element) => element.categoryId == categoryId);

      return category;
    } catch (e) {
      connectionFailed(e);
    }
  }
}
