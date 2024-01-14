import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../helpers/database_helper.dart';
import '../models/barcode.dart';
import '../models/item.dart';
import '../models/offline_bill.dart';
import '../models/online_bill.dart';
import '../providers/barcode_provider.dart';
import '../providers/current_firm_provider.dart';
import '../utils/utils.dart';
import '../widgets/bill_print_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';

import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class CreateNewBillPage extends StatefulWidget {
  const CreateNewBillPage({super.key});

  @override
  State<CreateNewBillPage> createState() => _CreateNewBillPageState();
}

class _CreateNewBillPageState extends State<CreateNewBillPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, TextEditingController> quantityControllers = {};

  int invoiceNum = 0;
  int totalBasePrice = 0;
  int totalItems = 0;

  String? _barcode;
  late bool visible;
  List<Item> _item = [];
  List<OfflineBill>? _offlineBills;
  List<OnlineBill>? _onlineBills;
  Exception? _connectionException;
  Future<List<Item>>? _itemsFuture;
  DatabaseHelper? _databaseHelper;
  final FocusNode _dummyNode = FocusNode();

  Future<void> _loadOffBills() async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final offlineBillsFuture =
          await _databaseHelper!.getOfflineBills(currentFirmId);
      final List<OfflineBill> offlineBills = offlineBillsFuture;

      setState(() {
        _offlineBills = offlineBills; // Check for null here
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _loadOnBills() async {
    try {
      final currentFirmId =
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId;

      final onlineBillsFuture =
          await _databaseHelper!.getOnlineBills(currentFirmId);
      final List<OnlineBill> onlineBills = onlineBillsFuture;

      setState(() {
        _onlineBills = onlineBills;
      });
    } catch (e) {
      print('Error loading all bills: $e');
      _connectionFailed(e);
    }
  }

  Future<void> _createOnlineBill(OnlineBill onlineBill) async {
    try {
      // Use DatabaseHelper to insert online bill into the database
      await _databaseHelper!.insertOnlineBill(onlineBill);
      await _loadOnBills(); // Reload bills after creating online bill
      await _loadOffBills();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _createOfflineBill(OfflineBill offlineBill) async {
    try {
      // Use DatabaseHelper to insert offline bill into the database
      await _databaseHelper?.insertOfflineBill(offlineBill);
      await _loadOnBills(); // Reload bills after creating offline bill
      await _loadOffBills();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _loadItems() async {
    try {
      final items = await _databaseHelper?.getAllItems(
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId);
      setState(() {
        _item = items!;
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  void _connectionFailed(dynamic exception) {
    setState(() {
      _offlineBills = null;
      _onlineBills = null;
      _item = [];

      _connectionException = exception is Exception ? exception : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _dummyNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _databaseHelper = DatabaseHelper.instance;

      if (_databaseHelper != null) {
        await _loadItems();
        await _loadOnBills();
        await _loadOffBills();

        invoiceNum = _item.length + 1;
      } else {
        print("Database helper is not initialized");
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dummyNode.dispose();

    super.dispose();
  }

  bool isScanningBarcode = false;

  String shortenText(String text) {
    List<String> words = text.split(' ');

    // Extract the first letter of each word
    List<String> firstLetters = words.map((word) => word[0]).toList();

    // Join the first letters to form the shortened text
    String shortenedText = firstLetters.join('');

    return shortenedText;
  }

  void _showItemListDailog(BarcodeProvider barcodeModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                  controller: _searchController,
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
                    itemCount: _item.length,
                    itemBuilder: (context, int index) {
                      final itemId = _item[index].itemId;
                      final item = _item[index];
                      final existingItem = barcodeModel.barcodes.firstWhere(
                        (i) => i.barcode == item.barcode,
                        orElse: () => Barcode(
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

                      final searchText = _searchController.text.toLowerCase();
                      final itemName = _item![index].name.toLowerCase();
                      final itemCategory = _item![index].category.toLowerCase();

                      if (!itemName.contains(searchText.toString()) &&
                          !_item![index]
                              .barcode
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
                                      itemId: '',
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
                                totalItems += 1;
                                totalBasePrice += item.price.toInt();
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

                                  totalItems -= 1;

                                  // Only subtract the item price if the quantity is greater than 0
                                  if (existingItem.quantity > 0) {
                                    totalBasePrice -= item.price.toInt();
                                  } else {
                                    // If quantity becomes 0, subtract the item price from totalBasePrice
                                    totalBasePrice -= item.price.toInt();
                                  }

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

  @override
  Widget build(BuildContext context) {
    ;
    final firmData = Provider.of<CurrentFirmProvider>(context, listen: false);

    return _onlineBills != null
        ? Consumer<BarcodeProvider>(builder: (context, barcodeModel, child) {
            var invoice =
                '${firmData.currentFirmId}IV${_onlineBills == null ? 0 : (_onlineBills!.isNotEmpty ? _onlineBills!.last.id! : 0) + 1}';

            bool isVisible = WidgetsBinding.instance.renderView.attached;
            return RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event.runtimeType == RawKeyUpEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  // Perform any specific action you want on Enter key press
                  print('Enter key pressed!');
                }
              },
              child: CustomPage(
                onClose: () {
                  barcodeModel.barcodes.clear();
                  totalBasePrice = 0;
                  totalItems = 0;
                  Navigator.of(context).pop();
                },
                title: 'Create New Bill',
                widget: [
                  Row(
                    children: [
                      Text(
                        'Invoice# ${invoice}',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'Items',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _showItemListDailog(barcodeModel);
                          _loadItems();
                        },
                        icon: const Icon(FontAwesomeIcons.plus),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // SizedBox(
                  //   width: 800,
                  //   height: 300,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: _item!.length,
                  //     itemBuilder: (context, int index) {
                  //       final item = _item![index];
                  //       final itemBarcode = item.barcode;

                  //       int itemPrice = int.parse(item.price.toString());

                  //       final existingItem = barcodeModel.barcodes.firstWhere(
                  //         (item) => item.barcode == itemBarcode,
                  //         orElse: () => Barcode(
                  //           itemId: '',
                  //           quantity: 0,
                  //           barcode: '',
                  //           rate: 0,
                  //           cgst: 0,
                  //           sgst: 0,
                  //           category: '',
                  //           size: '',
                  //           name: '',
                  //         ),
                  //       );

                  //       return VisibilityDetector(
                  //         onVisibilityChanged: (VisibilityInfo info) {
                  //           visible = info.visibleFraction > 0;
                  //         },
                  //         key: Key(
                  //           'visible-detector-key-$index',
                  //         ), // Unique key for each item
                  //         child: BarcodeKeyboardListener(
                  //           useKeyDownEvent: true,
                  //           bufferDuration: const Duration(milliseconds: 200),
                  //           onBarcodeScanned: (barcode) {
                  //             if (!visible || barcode != itemBarcode) {
                  //               return;
                  //             }
                  //             final existingItem = barcodeModel.barcodes.firstWhere(
                  //               (item) => item.barcode == barcode,
                  //               orElse: () => Barcode(
                  //                 itemId: '',
                  //                 quantity: 0,
                  //                 barcode: '',
                  //                 rate: 0,
                  //                 cgst: 0,
                  //                 sgst: 0,
                  //                 category: '',
                  //                 size: '',
                  //                 name: '',
                  //               ),
                  //             );

                  //             setState(() {
                  //               _barcode = barcode;

                  //               if (existingItem.quantity == 0) {
                  //                 barcodeModel.addItem(
                  //                   Barcode(
                  //                     itemId: '',
                  //                     barcode: barcode,
                  //                     quantity: 1,
                  //                     rate: itemPrice.toInt(),
                  //                     cgst: 0,
                  //                     sgst: 0,
                  //                     category: item.category,
                  //                     size: item.size,
                  //                     name: item.name,
                  //                   ),
                  //                 );
                  //                 totalItems += 1;
                  //                 totalBasePrice += itemPrice.toInt();
                  //               } else {
                  //                 existingItem.quantity++;
                  //                 totalItems += 1;
                  //                 totalBasePrice += itemPrice.toInt();
                  //                 barcodeModel.updateQuantity(
                  //                     existingItem, existingItem.quantity);
                  //               }
                  //             });
                  //           },
                  //           child: const ListTile(),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  // BarcodeKeyboardListener(
                  //   useKeyDownEvent: true,
                  //   bufferDuration: const Duration(milliseconds: 200),
                  //   onBarcodeScanned: (barcode) {
                  //     setState(() {
                  //       _barcode = barcode;

                  //       // Check if the scanned barcode matches any item in _item
                  //       final matchingItem = _item.firstWhere(
                  //         (item) => item.barcode == _barcode,
                  //         orElse: () => Item(
                  //             name: '',
                  //             itemId: '',
                  //             size: '',
                  //             barcode: '',
                  //             price: 0,
                  //             category: '',
                  //             firmId: ''),
                  //       );

                  //       if (isVisible && matchingItem != null) {
                  //         // If a matching item is found, update the list or do your logic here
                  //         final existingItem = barcodeModel.barcodes.firstWhere(
                  //           (item) => item.barcode == _barcode,
                  //           orElse: () => Barcode(
                  //             itemId: '',
                  //             quantity: 0,
                  //             barcode: '',
                  //             rate: 0,
                  //             cgst: 0,
                  //             sgst: 0,
                  //             category: '',
                  //             size: '',
                  //             name: '',
                  //           ),
                  //         );

                  //         if (existingItem.quantity == 0) {
                  //           barcodeModel.addItem(
                  //             Barcode(
                  //               itemId: matchingItem.itemId,
                  //               barcode: _barcode!,
                  //               quantity: 1,
                  //               rate: matchingItem.price.toInt(),
                  //               cgst: 0,
                  //               sgst: 0,
                  //               category: matchingItem.category,
                  //               size: matchingItem.size,
                  //               name: matchingItem.name,
                  //             ),
                  //           );
                  //           totalItems += 1;
                  //           totalBasePrice += matchingItem.price.toInt();
                  //         } else {
                  //           existingItem.quantity++;
                  //           totalItems += 1;
                  //           totalBasePrice += matchingItem.price.toInt();
                  //           barcodeModel.updateQuantity(
                  //               existingItem, existingItem.quantity);
                  //         }
                  //       }
                  //     });
                  //   },
                  //   child: Container(
                  //       // Your UI code here, if any
                  //       ),
                  // ),
                  BarcodeKeyboardListener(
                    useKeyDownEvent: true,
                    bufferDuration: const Duration(milliseconds: 200),
                    onBarcodeScanned: (barcode) {
                      setState(() {
                        _barcode = barcode;

                        // Check if the scanned barcode exists in the _item list
                        late Item matchingItem;
                        bool isMatched = false;

                        for (var item in _item) {
                          if (item.barcode == _barcode) {
                            matchingItem = item;
                            isMatched = true;
                            break;
                          }
                        }

                        if (isMatched == false) {
                          return;
                        }
                        if (isVisible &&
                            matchingItem != null &&
                            matchingItem.barcode.isNotEmpty) {
                          // If a matching item is found, update the list or do your logic here
                          final existingItem = barcodeModel.barcodes.firstWhere(
                            (item) => item.barcode == _barcode,
                            orElse: () => Barcode(
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
                                itemId: matchingItem.itemId,
                                barcode: _barcode!,
                                quantity: 1,
                                rate: matchingItem.price.toInt(),
                                cgst: 0,
                                sgst: 0,
                                category: matchingItem.category,
                                size: matchingItem.size,
                                name: matchingItem.name,
                              ),
                            );
                            print(matchingItem.itemId);
                            totalItems += 1;
                            totalBasePrice += matchingItem.price.toInt();
                          } else {
                            existingItem.quantity++;
                            totalItems += 1;
                            totalBasePrice += matchingItem.price.toInt();
                            barcodeModel.updateQuantity(
                                existingItem, existingItem.quantity);
                          }
                        } else {
                          // Item not found in the database, show alert or handle it accordingly
                          showAlert(context,
                              'Item with barcode $_barcode not found.');
                        }
                      });
                    },
                    child: Container(
                        // Your UI code here, if any
                        ),
                  ),

                  SizedBox(
                    width: 800,
                    height: 400,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: barcodeModel.barcodes.length,
                      itemBuilder: (context, int index) {
                        final existingItem = barcodeModel.barcodes[index];
                        final itemBarcode = existingItem.barcode;
                        int itemPrice = existingItem.rate;
                        return ListTile(
                          title: Text(existingItem.name),
                          subtitle: Text(
                            'ItemId: ${existingItem.itemId}, Category: ${existingItem.category}\nSize: ${existingItem.size}, Barcode: $itemBarcode ',
                            style: const TextStyle(fontSize: 12),
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
                                    '₹$itemPrice',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    '${existingItem.quantity}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    '₹${existingItem.quantity * itemPrice}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Text(
                        'Total Items: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        totalItems.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Net Amount: ₹',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '$totalBasePrice',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Text(
                            'For Item > Rs.1000 => CGST(2.5%) + SGST(2.5%)',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            'For Item < Rs.1000 => CGST(6%) + SGST(6%)',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            'Total SGST: ${barcodeModel.calculateGstForAll().totalSgst}, Total CGST: ${barcodeModel.calculateGstForAll().totalCgst}',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            'Total Tax: ${barcodeModel.calculateGstForAll().totalTax}',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                          width: 160,
                          text: 'Clear',
                          onTap: () {
                            barcodeModel.barcodes.clear();
                            totalBasePrice = 0;
                            totalItems = 0;
                            setState(() {});
                          }),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomButton(
                        width: 160,
                        text: 'Cash',
                        onTap: () => handlePayment(true, barcodeModel),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomButton(
                        width: 160,
                        text: "Online",
                        onTap: () => handlePayment(false, barcodeModel),
                      ),
                    ],
                  ),
                ],
              ),
            );
          })
        : Scaffold(
            appBar: AppBar(
              title: const Text('Database Error!!!'),
            ),
            body: Center(
              child: noDataIcon(),
            ),
          );
  }

  void handlePayment(bool isCash, BarcodeProvider barcodeModel) async {
    try {
      if (totalItems == 0) {
        return;
      }

      List<Barcode> barcodeDataList = barcodeModel.barcodes.map((barcode) {
            return Barcode(
              itemId: '',
              barcode: barcode.barcode,
              quantity: barcode.quantity,
              rate: barcode.rate,
              cgst: barcode.cgst,
              sgst: barcode.sgst,
              category: barcode.category,
              size: barcode.size,
              name: barcode.name,
            );
          }).toList() ??
          [];
      String barcodeDataString = jsonEncode(barcodeDataList.map((barcode) {
        return barcode.toJson();
      }).toList());

      final firmData = Provider.of<CurrentFirmProvider>(context, listen: false);
      if (!isCash) {
        List<Map<String, dynamic>> dataList =
            barcodeModel.barcodes.map((barcode) {
          return {
            'name': barcode.name,
            'category': barcode.category,
            'size': barcode.size,
            'rate': barcode.rate,
            'barcode': barcode.barcode,
            'quantity': barcode.quantity,
          };
        }).toList();
        String? selectedPaymentMethod = await showPaymentMethodDialog(context);

        // Update mode of payment based on user selection
        String modeOfPayment = selectedPaymentMethod!;

        var invoiceOn =
            '${firmData.currentFirmId}IV${_onlineBills == null ? 0 : (_onlineBills!.isNotEmpty ? _onlineBills!.last.id! : 0) + 1}';

        var onBill = OnlineBill(
          firmId: firmData.currentFirmId,
          createdAt: DateTime.now().toIso8601String(),
          invoice: invoiceOn,
          items: barcodeDataString,
          netAmount: totalBasePrice.toDouble(),
          totalTax: barcodeModel.calculateGstForAll().totalTax,
          modeOfPayment: modeOfPayment.toString(),
          totalQuantity: totalItems,
        );

        _onlineBills!.add(onBill);
        _createOnlineBill(onBill);

        printPdf(
          firmData,
          invoice: invoiceOn,
          dateTime: DateTime.now(),
          totalQuantity: totalItems,
          netAmount: totalBasePrice,
          itemsList: dataList,
          gstDetails: barcodeModel.calculateGstForAll(),
          selectedModeOfPayment: modeOfPayment,
        );
      }
      if (isCash) {
        var invoiceOff =
            '${firmData.currentFirmId}V${_offlineBills!.isNotEmpty ? _offlineBills!.last.id! : 0 + 1}';
        var offBill = OfflineBill(
          firmId: firmData.currentFirmId,
          createdAt: DateTime.now().toIso8601String(),
          invoice: invoiceOff,
          items: barcodeDataString,
          netAmount: totalBasePrice.toDouble(),
          totalTax: barcodeModel.calculateGstForAll().totalTax,
          modeOfPayment: 'Cash',
          totalQuantity: totalItems,
        );

        _offlineBills!.add(offBill);
        _createOfflineBill(offBill);
      }

      barcodeModel.barcodes.clear();
      totalBasePrice = 0;
      totalItems = 0;
      Navigator.of(context).pop();
    } catch (e) {
      showAlert(
        context,
        'Error generating bill: $e',
      );
    }
  }

  Future<String?> showPaymentMethodDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('POS Machine'),
                child: const Text('POS Machine'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('UPI'),
                child: const Text('UPI'),
              ),
            ],
          ),
        );
      },
    );
  }
}
