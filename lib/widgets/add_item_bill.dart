import 'package:billx/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/barcode.dart';
import '../providers/barcode_provider.dart';
import '../providers/items_provider.dart';

void showItemListDailog(BarcodeProvider barcodeModel, context) {
  ItemProvider itemProvider = Provider.of<ItemProvider>(context, listen: false);
  itemProvider.loadItems(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        final TextEditingController searchController = TextEditingController();

        return AlertDialog(
          title: Row(
            children: [
              const Text('Select Items'),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  FontAwesomeIcons.close,
                ),
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextfield(
                label: 'Search Items',
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 600,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: itemProvider.itemList!.length,
                  itemBuilder: (context, int index) {
                    itemProvider.itemList!.sort((a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    final itemId = itemProvider.itemList![index].itemId;
                    final item = itemProvider.itemList![index];
                    final existingItem = barcodeModel.barcodes.firstWhere(
                      (i) => i.barcode == item.barcode,
                      orElse: () => Barcode(
                        isBeingReturned: false,
                        itemId: '',
                        quantity: 0,
                        barcode: '',
                        rate: 0,
                        cgst: 0,
                        sgst: 0,
                        category: '',
                        size: '',
                        name: '',
                      ),
                    );

                    final searchText = searchController.text.toLowerCase();
                    final itemName =
                        itemProvider.itemList![index].name.toLowerCase();
                    final itemCategory =
                        itemProvider.itemList![index].category.toLowerCase();

                    if (!itemName.contains(searchText.toString()) &&
                        !itemProvider.itemList![index].barcode
                            .toLowerCase()
                            .contains(searchText) &&
                        !itemCategory.contains(searchText.toString())) {
                      return Container(); // Return an empty container if item doesn't match the search
                    }

                    // double itemPrice = parse(item.price.toString());
                    return ListTile(
                      title: Text("${item.name}  (${item.itemId})"),
                      subtitle: Text(
                        'Category: ${item.category}, Size: ${item.size}, Barcode: ${item.barcode} ',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'MRP: ',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '₹${item.price}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.plus),
                            onPressed: () {
                              // If the checkbox is selected, check if the item is already in the list
                              final existingItem =
                                  barcodeModel.barcodes.firstWhere(
                                (i) => i.barcode == item.barcode,
                                orElse: () => Barcode(
                                  isBeingReturned: false,
                                  itemId: '',
                                  quantity: 0,
                                  barcode: '',
                                  rate: 0,
                                  cgst: 0,
                                  sgst: 0,
                                  category: '',
                                  size: '',
                                  name: '',
                                ),
                              );

                              if (existingItem.quantity == 0) {
                                barcodeModel.addItem(
                                  Barcode(
                                    isBeingReturned: false,
                                    itemId: itemId,
                                    barcode: item.barcode,
                                    quantity: 1,
                                    rate: item.price,
                                    cgst: 0,
                                    sgst: 0,
                                    category: item.category,
                                    size: item.size,
                                    name: item.name,
                                  ),
                                );
                                // totalBasePrice += itemPrice;
                              } else {
                                existingItem.quantity++;
                                // totalBasePrice += itemPrice;
                              }

                              setState(() {});
                              // totalItems += 1;
                              // totalBasePrice += item.price.toInt();
                              barcodeModel.updateQuantity(
                                  existingItem, existingItem.quantity);
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${existingItem.quantity}',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.minus),
                            onPressed: () {
                              // If the checkbox is unselected, decrement the quantity
                              final existingItem =
                                  barcodeModel.barcodes.firstWhere(
                                (i) => i.barcode == item.barcode,
                                orElse: () => Barcode(
                                  isBeingReturned: false,
                                  itemId: '',
                                  barcode: '',
                                  quantity: 0,
                                  rate: 0,
                                  cgst: 0,
                                  sgst: 0,
                                  category: '',
                                  size: '',
                                  name: '',
                                ),
                              );

                              if (existingItem.quantity > 0) {
                                existingItem.quantity--;

                                // If the quantity becomes 0, remove the item from the list
                                if (existingItem.quantity == 0) {
                                  barcodeModel.removeItem(existingItem);
                                }

                                // totalItems -= 1;

                                // // Only subtract the item price if the quantity is greater than 0
                                // if (existingItem.quantity > 0) {
                                //   totalBasePrice -= item.price.toInt();
                                // } else {
                                //   // If quantity becomes 0, subtract the item price from totalBasePrice
                                //   totalBasePrice -= item.price.toInt();
                                // }

                                barcodeModel.updateQuantity(
                                    existingItem, existingItem.quantity);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      });
    },
  );
}
