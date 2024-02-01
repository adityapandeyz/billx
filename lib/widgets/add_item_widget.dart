import 'package:billx/providers/items_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart' as bar;
import 'package:visibility_detector/visibility_detector.dart';

import '../models/item.dart';
import '../providers/current_firm_provider.dart';
import '../providers/category_provider.dart'; // Import CategoryProvider
import '../utils/utils.dart';
import 'custom_textfield.dart';

class AddItemPopup extends StatelessWidget {
  const AddItemPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 600,
      width: 600,
      child: AddItemWidget(),
    );
  }
}

class AddItemWidget extends StatefulWidget {
  const AddItemWidget({super.key});

  @override
  _AddItemWidgetState createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  bool _barcodeExistsAlertShown = false;
  String? _barcode;
  late bool visible;
  var barcodeWithNoSpace = '';

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemSizeController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemBarcodeController = TextEditingController();
  TextEditingController itemStockController = TextEditingController();

  String _selectedCategory = '';

  @override
  void dispose() {
    itemNameController.dispose();
    itemSizeController.dispose();
    itemPriceController.dispose();
    itemBarcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    categoryProvider.loadItemCategories(context);
    final firmId =
        Provider.of<CurrentFirmProvider>(context, listen: false).currentFirmId;

    return AlertDialog(
      title: const Text('Add Item'),
      content: _buildDialogContent(context, itemProvider, categoryProvider),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
            _clearInputs();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // background (button) color
            foregroundColor: Colors.white, // foreground (text) color
          ),
          onPressed: () async {
            await _uploadItemData(itemProvider, categoryProvider, firmId);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }

  void _loadItemCategories(CategoryProvider categoryProvider) async {
    try {
      categoryProvider.loadItemCategories(context);
      // setState(() {
      //   _selectedCategory =
      //       categoryProvider.itemCategories?.first.categoryId ?? '';
      // });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Widget _buildDialogContent(BuildContext context, ItemProvider itemProvider,
      CategoryProvider categoryProvider) {
    if (categoryProvider.itemCategories == null) {
      _loadItemCategories(categoryProvider);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // _buildBarcodeSection(context),

        CustomTextfield(
          label: 'Item Name',
          autoFocus: true,
          controller: itemNameController,
        ),
        const SizedBox(
          height: 10,
        ),
        CustomTextfield(
          label: 'Item Size',
          controller: itemSizeController,
        ),
        const SizedBox(
          height: 10,
        ),
        CustomTextfield(
          label: 'Price(₹)',
          controller: itemPriceController,
        ),
        const SizedBox(
          height: 10,
        ),
        CustomTextfield(
          label: 'Price(₹)',
          controller: itemStockController,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Category: '),
            const SizedBox(
              width: 20,
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue ?? '';
                });
              },
              items: categoryProvider.itemCategories == null
                  ? []
                  : categoryProvider.itemCategories!.map(
                      (item) {
                        return DropdownMenuItem<String>(
                          value: item.categoryId,
                          child: Text('${item.name} (${item.categoryId})'),
                        );
                      },
                    ).toList(),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        CustomTextfield(
          label: 'Barcode',
          controller: itemBarcodeController,
        ),
      ],
    );
  }

  // Widget _buildBarcodeSection(BuildContext context) {
  //   return VisibilityDetector(
  //     onVisibilityChanged: (VisibilityInfo info) {
  //       visible = info.visibleFraction > 0;
  //     },
  //     key: const Key('visible-detector-key'),
  //     child: BarcodeKeyboardListener(
  //       bufferDuration: const Duration(milliseconds: 200),
  //       onBarcodeScanned: (barcode) {
  //         if (!visible) return;
  //         setState(() {
  //           _barcode = barcode.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  //         });
  //       },
  //       child: _barcode != null || _barcode.toString().isNotEmpty
  //           ? Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: <Widget>[
  //                 Text(
  //                   _barcode == null ? 'SCAN BARCODE' : 'BARCODE: ${_barcode!}',
  //                   style: Theme.of(context).textTheme.headlineSmall,
  //                 ),
  //                 bar.BarcodeWidget(
  //                   color: Colors.black,
  //                   barcode: bar.Barcode.code128(),
  //                   height: 100,
  //                   width: 200,
  //                   data: _barcode.toString(),
  //                   errorBuilder: (context, error) =>
  //                       Center(child: Text(error)),
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //               ],
  //             )
  //           : Text(
  //               'Scan Barcode',
  //               style: Theme.of(context).textTheme.headlineSmall,
  //             ),
  //     ),
  //   );
  // }

  Future<void> _uploadItemData(ItemProvider itemProvider,
      CategoryProvider categoryProvider, String firmId) async {
    if (_inputsAreEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base price must be a valid double or int value.'),
        ),
      );
      return;
    }

    double? itemBasePrice = double.tryParse(itemPriceController.text);

    if (itemBasePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base price must be a valid double or int value.'),
        ),
      );

      return;
    }

    await itemProvider
        .loadItems(context); // Ensure that the item list is loaded

    final itemId =
        await itemProvider.getNextItemId(_selectedCategory ?? '', context);

    try {
      // if (itemBarcodeController.text.isEmpty ||
      //     itemNameController.text.isEmpty ||
      //     itemSizeController.text.isEmpty ||
      //     itemPriceController.text.isEmpty) {
      //   return;
      // }

      var item = Item(
        name: itemNameController.text,
        itemId: itemId,
        firmId: firmId,
        category: _selectedCategory,
        size: itemSizeController.text.toUpperCase(),
        barcode: itemBarcodeController.text
            .replaceAll(RegExp(r'\s+'), '')
            .toUpperCase(),
        price: int.parse(itemPriceController.text),
        stock: int.parse(
          itemStockController.text,
        ),
      );

      // if (_barcode != null) {
      //   item.barcode = _barcode!.toUpperCase();
      // } else {
      //   return;
      // }

      if (itemProvider.items!.any((existingItem) =>
          existingItem.barcode == itemBarcodeController.text)) {
        _clearInputs();
        Navigator.of(context).pop();

        _showBarcodeAlert();
      } else {
        itemProvider.createItem(item, context);
        _clearInputs();
        Navigator.of(context).pop();
      }
    } catch (e) {
      Navigator.of(context).pop();
      showAlert(context, e.toString());
    }
  }

  void _connectionFailed(dynamic exception) {
    // Handle connection failure
  }

  void _showBarcodeAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Item already exists in the database.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearInputs();
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }

  bool _inputsAreEmpty() {
    return itemNameController.text.isEmpty ||
        itemPriceController.text.isEmpty ||
        itemBarcodeController.text.isEmpty ||
        itemSizeController.text.isEmpty;
  }

  void _clearInputs() {
    itemNameController.clear();
    itemBarcodeController.clear();
    itemSizeController.clear();
    itemPriceController.clear();
    _barcode = null;
  }
}
