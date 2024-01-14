import 'package:barcode_widget/barcode_widget.dart' as bar;

import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../helpers/database_helper.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../providers/current_firm_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/green_add_button.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Item>? _item;
  Exception? _connectionException;
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryCodeController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemSizeController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemBarcodeController = TextEditingController();
  String itemId = "";

  String? _barcode;
  late bool visible;

  List<Category>? _itemCategory;

  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper.instance;
    _loadItems();
    _loadItemCategories();
  }

  List<Item>? _filteredItem;

  Future<void> _loadItems() async {
    try {
      final items = await _databaseHelper.getAllItems(
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId);
      setState(() {
        _item = items;
        _filteredItem = _item; // Initialize filtered list
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  void _connectionFailed(dynamic exception) {
    setState(() {
      _itemCategory = null;
      _item = null;

      _connectionException = exception;
    });
  }

  @override
  void dispose() {
    itemNameController.dispose();
    itemSizeController.dispose();
    itemPriceController.dispose();
    itemBarcodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadItemCategories() async {
    try {
      final itemCategories = await DatabaseHelper.instance.getCategories(
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId);
      setState(() {
        _itemCategory = itemCategories;
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _createItem(Item item) async {
    try {
      await DatabaseHelper.instance.insertItem(item);
      await _loadItems();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _deleteItem(Item item) async {
    try {
      await DatabaseHelper.instance.deleteItem(item);
      await _loadItems();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmId =
        Provider.of<CurrentFirmProvider>(context, listen: false).currentFirmId;

    return CustomPage(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: 'Items',
      widget: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield(
              label: 'Search Item',
              controller: _searchController,
              onChanged: (value) {
                // Update the filtered list based on the search input
                setState(() {
                  _filteredItem = _item!
                      .where((item) =>
                          item.name
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item.itemId
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item.barcode
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item.size
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item.price
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item.category
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            const SizedBox(
              width: 10,
            ),
            GreenAddButton(
              function: () {
                addItem(firmId);
              },
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        _item == null
            ? noDataIcon()
            : SizedBox(
                height: 650,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredItem!.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: actionColor,
                      margin: const EdgeInsets.all(20),
                      child: ListTile(
                        // onTap: () {
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (_) => AddItemPage(
                        //         categoryName: _item![index].name.toString(),
                        //         categoryCode: _item![index].id.toString(),
                        //         // firmId: firmInfo!.toString()
                        //       ),
                        //     ),
                        //   );
                        // },
                        leading: const SizedBox(
                          width: 60,
                          child: Icon(
                            FontAwesomeIcons.shirt,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          _filteredItem![index].name.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ItemId: ${_filteredItem![index].itemId.toString()}',
                            ),
                            Text(
                              'Barcode: ${_filteredItem![index].barcode.toString()}',
                            ),
                            Text(
                              'Size: ${_filteredItem![index].size.toString()}',
                            ),
                            Text(
                              'Price: ${_filteredItem![index].price.toString()}',
                            ),
                            Text(
                              'CategoryId: ${_filteredItem![index].category.toString()}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            var itemIndex = _filteredItem![index];

                            setState(() {
                              _filteredItem!.remove(itemIndex);
                            });

                            _deleteItem(itemIndex);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
        const Spacer(),
      ],
    );
  }

  bool _barcodeExistsAlertShown = false;

  String shortenText(String text) {
    List<String> words = text.split(' ');

    // Extract the first letter of each word
    List<String> firstLetters = words.map((word) => word[0]).toList();

    // Join the first letters to form the shortened text
    String shortenedText = firstLetters.join('');

    return shortenedText;
  }

  void addItem(String firmId) {
    String selectedCategoryCode = _itemCategory?.isNotEmpty ?? false
        ? _itemCategory!.first.categoryId
        : '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                VisibilityDetector(
                  onVisibilityChanged: (VisibilityInfo info) {
                    visible = info.visibleFraction > 0;
                  },
                  key: const Key('visible-detector-key'),
                  child: BarcodeKeyboardListener(
                    bufferDuration: const Duration(milliseconds: 200),
                    onBarcodeScanned: (barcode) {
                      if (!visible) return;
                      print(barcode);
                      setState(() {
                        _barcode = barcode;
                      });
                    },
                    child: _barcode != null || _barcode.toString().isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _barcode == null
                                    ? 'SCAN BARCODE'
                                    : 'BARCODE: $_barcode',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              bar.BarcodeWidget(
                                color: Colors.white,
                                barcode: bar.Barcode.code128(),
                                height: 100,
                                width: 200,
                                data: _barcode.toString(),
                                errorBuilder: (context, error) =>
                                    Center(child: Text(error)),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextfield(
                                label: 'Item Name',
                                autoFocus: false,
                                controller: itemNameController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextfield(
                                label: 'Item Size',
                                autoFocus: false,
                                controller: itemSizeController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextfield(
                                label: 'Price(₹)',
                                autoFocus: false,
                                controller: itemPriceController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Category: '),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  DropdownButton<String>(
                                    value: selectedCategoryCode,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategoryCode = newValue ?? '';
                                      });
                                    },
                                    items: _itemCategory == null
                                        ? []
                                        : _itemCategory!.map((item) {
                                            return DropdownMenuItem<String>(
                                              value: item
                                                  .categoryId, // Ensure this matches the type of selectedCategoryCode
                                              child: Text(item.name),
                                            );
                                          }).toList(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : Text(
                            'Scan Barcode',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                  ),
                ),

                // CustomTextfield(
                //   label: 'Barcode (Optional)',
                //   autoFocus: true,
                //   controller: itemBarcodeController,
                // ),
                // const SizedBox(
                //   height: 20,
                // ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  setState;
                  Navigator.pop(context);
                  clearInputs();
                },
              ),
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () async {
                  uploadItemData(selectedCategoryCode, firmId);
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _checkBarcodeExists(String barcode) {
    if (!_barcodeExistsAlertShown &&
        _item != null &&
        _item!.any((item) => item.barcode == barcode)) {
      showAlert(context, 'Barcode already exists in the database.');
      _barcodeExistsAlertShown = true;
    }
  }

  void uploadItemData(String categoryCode, String firmId) async {
    if (inputsAreEmpty()) {
      showAlert(context, 'Empty fields!');
      return;
    }

    if (_barcode != null) {
      _checkBarcodeExists(_barcode!);
    }

    double? itemBasePrice = double.tryParse(itemPriceController.text);

    if (itemBasePrice == null) {
      showAlert(context, 'Base price must be a valid double or int value.');
      return;
    }

    itemId = '$categoryCode${(_item!.isEmpty ? 0 : _item!.last.id!) + 1}';

    try {
      var item = Item(
        name: itemNameController.text,
        itemId: itemId,
        firmId: firmId,
        category: categoryCode,
        size: itemSizeController.text.toUpperCase(),
        barcode: itemBarcodeController.text.isEmpty
            ? _barcode?.toUpperCase() ?? ''
            : itemBarcodeController.text,
        price: int.parse(itemPriceController.text),
      );

      if (_barcode != null) {
        item.barcode = _barcode!.toUpperCase();
      }

      if (!_barcodeExistsAlertShown) {
        if (_barcode != null &&
            _item!.any((existingItem) => existingItem.barcode == _barcode)) {
          showAlert(context, 'Barcode already exists in the database.');
          _barcodeExistsAlertShown = true;
        } else {
          _item!.add(item);
          _createItem(item);
          clearInputs();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      showAlert(context, e.toString());
    }
  }

  bool inputsAreEmpty() {
    return itemNameController.text.isEmpty ||
        itemPriceController.text.isEmpty ||
        itemSizeController.text.isEmpty;
  }

  void clearInputs() {
    itemNameController.clear();
    itemBarcodeController.clear();
    itemSizeController.clear();
    itemPriceController.clear();
    _barcode = null;
  }
}
