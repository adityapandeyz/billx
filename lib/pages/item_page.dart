// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:billx/models/category.dart';
import 'package:billx/providers/current_firm_provider.dart';
import 'package:billx/widgets/barcode_generator.dart';

import '../models/item.dart';
import '../providers/category_provider.dart';
import '../providers/items_provider.dart';
import '../utils/utils.dart';
import '../widgets/add_item_widget.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/green_add_button.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<ItemProvider>(context, listen: false).loadItems(context);
    var currentFirm = Provider.of<CurrentFirmProvider>(context, listen: false)
        .currentFirmName;

    return CustomPage(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: 'Items ',
      widget: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield(
              label: 'Search Item',
              controller:
                  TextEditingController(), // Use a new controller or initialize it somewhere.
              onChanged: (value) {
                Provider.of<ItemProvider>(context, listen: false)
                    .filterItems(context, value);
              },
            ),
            const SizedBox(
              width: 10,
            ),
            GreenButton(
              function: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const Dialog(
                      child: AddItemPopup(),
                    );
                  },
                );
              },
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Consumer<ItemProvider>(
          builder: (context, itemProvider, _) {
            final filteredItems = itemProvider.filteredItems;

            filteredItems?.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

            return (filteredItems == null || filteredItems.isEmpty)
                ? noDataIcon()
                : SizedBox(
                    height: 650,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredItems.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: actionColor,
                          margin: const EdgeInsets.all(20),
                          child: ListTile(
                            leading: const SizedBox(
                              width: 60,
                              child: Icon(
                                FontAwesomeIcons.shirt,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              filteredItems[index].name.toString(),
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
                                  'ItemId: ${filteredItems[index].itemId.toString()}',
                                ),
                                Text(
                                  'Barcode: ${filteredItems[index].barcode.toString()}',
                                ),
                                Text(
                                  'Size: ${filteredItems[index].size.toString()}',
                                ),
                                Text(
                                  'Price: ${filteredItems[index].price.toString()}',
                                ),
                                Text(
                                  'CategoryId: ${filteredItems[index].category.toString()}',
                                ),
                                Text(
                                  'Stock: ${filteredItems[index].stock.toString()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    printBarcode(
                                      itemId: filteredItems[index]
                                          .itemId
                                          .toString(),
                                      itemName:
                                          filteredItems[index].name.toString(),
                                      barcode: filteredItems[index]
                                          .barcode
                                          .toString(),
                                      rate:
                                          filteredItems[index].price.toDouble(),
                                      size:
                                          filteredItems[index].size.toString(),
                                      firmName: currentFirm,
                                    );
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.barcode,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: EditItem(
                                            itemId: filteredItems[index].itemId,
                                            itemName: filteredItems[index].name,
                                            itemBarcode:
                                                filteredItems[index].barcode,
                                            itemPrice:
                                                filteredItems[index].price,
                                            itemSize: filteredItems[index].size,
                                            categoryId:
                                                filteredItems[index].category,
                                            stock: filteredItems[index]
                                                .stock
                                                .toInt(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
          },
        ),
        const Spacer(),
      ],
    );
  }
}

class EditItem extends StatefulWidget {
  String itemId;
  String itemName;
  String itemSize;
  int itemPrice;
  String itemBarcode;
  String categoryId;
  int stock;
  EditItem({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.itemSize,
    required this.itemPrice,
    required this.itemBarcode,
    required this.categoryId,
    required this.stock,
  }) : super(key: key);

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemIdController = TextEditingController();
  TextEditingController itemSizeController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemBarcodeController = TextEditingController();
  TextEditingController itemCategoryController = TextEditingController();
  TextEditingController itemStockController = TextEditingController();

  String _selectedCategory = '';
  String firmdId = '';

  @override
  void dispose() {
    itemNameController.dispose();
    itemIdController.dispose();
    itemSizeController.dispose();
    itemPriceController.dispose();
    itemBarcodeController.dispose();
    itemCategoryController.dispose();
    itemStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    firmdId = Provider.of<CurrentFirmProvider>(context).currentFirmId;
    final itemProvider = Provider.of<ItemProvider>(context);

    return SizedBox(
      width: 600,
      height: 680,
      child: AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield(
              label: 'Name: ${widget.itemName}',
              controller: itemNameController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Item Id: ${widget.itemId}',
              controller: itemIdController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Size: ${widget.itemSize}',
              controller: itemSizeController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Price: ${widget.itemPrice}',
              controller: itemPriceController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Barcode: ${widget.itemBarcode}',
              controller: itemBarcodeController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Category Id: ${widget.categoryId}',
              controller: itemCategoryController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextfield(
              label: 'Stock: ${widget.stock}',
              controller: itemStockController,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Item? existingItem =
                    await itemProvider.getItemWithId(widget.itemId, context);

                if (existingItem != null) {
                  existingItem.name = itemNameController.text.isEmpty
                      ? existingItem.name
                      : itemNameController.text;

                  existingItem.itemId = itemIdController.text.isEmpty
                      ? existingItem.itemId
                      : itemIdController.text;

                  existingItem.size = itemSizeController.text.isEmpty
                      ? existingItem.size
                      : itemSizeController.text.toUpperCase();

                  existingItem.barcode = itemBarcodeController.text.isEmpty
                      ? existingItem.barcode
                      : itemBarcodeController.text.replaceAll(' ', '');

                  existingItem.price = itemPriceController.text.isEmpty
                      ? existingItem.price
                      : int.parse(itemPriceController.text);

                  existingItem.category = itemCategoryController.text.isEmpty
                      ? existingItem.category
                      : itemCategoryController.text;

                  existingItem.stock = itemStockController.text.isEmpty
                      ? existingItem.stock
                      : int.parse(itemStockController.text);

                  itemProvider.updateItem(existingItem, context);
                } else {
                  showDownAlert(
                      context, 'Item with ID ${widget.itemId} not found.');
                }

                Navigator.of(context).pop();
                showDownAlert(context, 'Item updated.');
              } catch (e) {
                print(e);
                return;
              }
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }
}
