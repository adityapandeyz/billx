import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/barcode.dart';

import 'package:xml/xml.dart' as xml;

import '../providers/barcode_provider.dart';
import '../providers/current_firm_provider.dart';
import '../providers/items_provider.dart';
import 'bill_print_widget.dart';
import 'custom_textfield.dart';

showBillDetails(
  context,
  billsData,
  String invoiceNum,
  firmId,
  netAmount,
  totalQuantity,
  totalTax,
  String dateTime, {
  bool isSplit = false,
  int cash = 0,
  int online = 0,
  bool isUpi = false,
  bool isPos = false,
  bool isCash = false,
  int disc = 0,
}) {
  showDialog(
    context: context,
    builder: (context) {
      List billData =
          billsData!.where((element) => element.invoice == invoiceNum).toList();

      if (billData.isEmpty) {
        // Handle the case where no bill with the given ID is found
        return SizedBox(
          child: AlertDialog(
            title: const Text('Error'),
            content: Text('No Invoice found with ID: $invoiceNum'),
            actions: [
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }

      return StatefulBuilder(builder: (context, setState) {
        // Separate lists for returned and non-returned items
        List<Barcode> nonReturnedItems = [];
        List<Barcode> returnedItems = [];

        for (var currentBill in billData) {
          List<Barcode> itemsList =
              (json.decode(currentBill.items) as List).map((item) {
            return Barcode(
              itemId: item['itemId'],
              barcode: item['barcode'],
              name: item['name'],
              category: item['category'],
              size: item['size'],
              quantity: item['quantity'],
              rate: item['rate'],
              cgst: item['cgst'],
              sgst: item['sgst'],
              isBeingReturned: item['isBeingReturned'] ?? false,
            );
          }).toList();

          for (var item in itemsList) {
            if (item.isBeingReturned) {
              returnedItems.add(item);
            } else {
              nonReturnedItems.add(item);
            }
          }
        }

        return AlertDialog(
          title: const Text('Bill Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Invoice #$invoiceNum'),
                  const Spacer(),
                  Text(
                    'DateTime: ${DateFormat.yMMMEd().add_jm().format(DateTime.parse(dateTime)).toString()}',
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Non-Returned Items: ($totalQuantity)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 200,
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: nonReturnedItems.length,
                  itemBuilder: (context, index) {
                    var item = nonReturnedItems[index];
                    return ListTile(
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${item.name}, Rate: ${item.rate}',
                          ),
                          Text(
                            'Barcode: ${item.barcode}, Quantity: ${item.quantity}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Text(
                'Returned Items:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 200,
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: returnedItems.length,
                  itemBuilder: (context, index) {
                    var item = returnedItems[index];
                    return ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Name: ${item.name}, Rate: ${item.rate}',
                          ),
                          Text(
                            'Barcode: ${item.barcode}, Quantity: ${item.quantity}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Net Amount: ₹$netAmount (Excluding Return)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Total Tax: ₹${totalTax.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    isSplit
                        ? Text(
                            'Cash: ₹$cash Online: ₹$online',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 5,
                    ),
                    isPos
                        ? const Text(
                            'Mode of Payment: POS Machine',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 5,
                    ),
                    isUpi
                        ? const Text(
                            'Mode of Payment: UPI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Disc: ₹$disc',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text("Print"),
              onPressed: () {
                final firmData =
                    Provider.of<CurrentFirmProvider>(context, listen: false);
                for (var currentBill in billData) {
                  List<Barcode> itemsList =
                      (json.decode(currentBill.items) as List).map((item) {
                    return Barcode(
                      itemId: item['itemId'],
                      barcode: item['barcode'],
                      name: item['name'],
                      category: item['category'],
                      size: item['size'],
                      quantity: item['quantity'],
                      rate: item['rate'],
                      cgst: item['cgst'],
                      sgst: item['sgst'],
                      isBeingReturned: item['isBeingReturned'] ?? false,
                    );
                  }).toList();

                  List<Map<String, dynamic>> dataList =
                      itemsList.map((barcode) {
                    return {
                      'name': barcode.name,
                      'category': barcode.category,
                      'size': barcode.size,
                      'rate': barcode.rate,
                      'barcode': barcode.barcode,
                      'quantity': barcode.quantity,
                      'isBeingReturned': barcode.isBeingReturned,
                    };
                  }).toList();

                  if (isSplit == false) {
                    if (isUpi == true || isPos == true) {
                      printPdf(
                        firmData,
                        invoice: invoiceNum,
                        dateTime: DateTime.parse(dateTime),
                        totalQuantity: totalQuantity,
                        netAmount: netAmount,
                        itemsList: dataList,
                        totalCgst: totalTax / 2,
                        totalSgst: totalTax / 2,
                        totalTax: totalTax,
                        selectedModeOfPayment: isUpi ? 'UPI' : 'POS',
                        discAmount: disc,
                      );
                    } else {
                      printPdf(
                        firmData,
                        invoice: invoiceNum,
                        dateTime: DateTime.parse(dateTime),
                        totalQuantity: totalQuantity,
                        netAmount: netAmount,
                        itemsList: dataList,
                        totalCgst: totalTax / 2,
                        totalSgst: totalTax / 2,
                        totalTax: totalTax,
                        selectedModeOfPayment: 'CASH',
                        discAmount: disc,
                      );
                    }
                  } else {
                    printPdf(
                      firmData,
                      isSplit: true,
                      invoice: invoiceNum,
                      dateTime: DateTime.parse(dateTime),
                      totalQuantity: totalQuantity,
                      cashAmount: cash,
                      onlineAmount: online,
                      netAmount: netAmount,
                      itemsList: dataList,
                      totalCgst: totalTax / 2,
                      totalSgst: totalTax / 2,
                      totalTax: totalTax,
                      selectedModeOfPayment: isUpi ? 'UPI' : 'POS',
                      discAmount: disc,
                    );
                  }
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     showDialog(
            //         context: context,
            //         builder: (_) {
            //           return EditItemWindow(
            //             billdata: billData,
            //             netAmount: netAmount,
            //             itemProvider: Provider.of<ItemProvider>(
            //               context,
            //               listen: false,
            //             ),
            //             qnt: totalQuantity,
            //             invoice: invoiceNum,
            //           );
            //         });
            //   },
            //   child: const Text('Edit'),
            // ),
          ],
        );
      });
    },
  );
}

class EditItemWindow extends StatefulWidget {
  final String invoice;
  final double netAmount;

  final ItemProvider itemProvider;
  final billdata;
  final int qnt;

  EditItemWindow(
      {required this.netAmount,
      required this.itemProvider,
      required this.billdata,
      required this.qnt,
      required this.invoice});

  @override
  _EditItemWindowState createState() => _EditItemWindowState();
}

class _EditItemWindowState extends State<EditItemWindow> {
  String returnOption = 'Product Replacement';
  TextEditingController quantityController = TextEditingController();
  final TextEditingController _changeRateController = TextEditingController();

  @override
  void dispose() {
    _changeRateController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  bool isSelected = false;
  List<bool> itemSelectionStates = [];

  @override
  void initState() {
    super.initState();
    itemSelectionStates = List<bool>.filled(widget.billdata.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Bill'),
      content: SizedBox(
        height: 800,
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Warning!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Items can only be removed at this stage. Removed items will be added back to stock count.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Items(${widget.qnt})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.billdata.length,
                  itemBuilder: (context, index) {
                    var currentBill = widget.billdata[index];

                    List<Barcode> itemsList =
                        (json.decode(currentBill.items) as List)
                            .map((item) => Barcode(
                                  itemId: item['itemId'],
                                  barcode: item['barcode'],
                                  name: item['name'],
                                  category: item['category'],
                                  size: item['size'],
                                  quantity: item['quantity'],
                                  rate: item['rate'],
                                  cgst: item['cgst'],
                                  sgst: item['sgst'],
                                  isBeingReturned: false,
                                ))
                            .toList();

                    return Column(
                      children: itemsList.map((item) {
                        return Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (item.quantity > 0) {
                                    item.quantity--;
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Card(
                                color: Colors.white,
                                child: ListTile(
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Name: ${item.name}, Rate: ${item.rate}'),
                                      Text(
                                          'Barcode: ${item.barcode}, Quantity: ${item.quantity}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  item.quantity++;
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            handleAddProducts(widget.netAmount, widget.billdata);
          },
          child: const Text('Generate Bill'),
        ),
      ],
    );
  }

  void handleAddProducts(totalAmount, billData) {
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double pricePerItem =
        10.0; // Replace this with the actual price from your items
    totalAmount = quantity * pricePerItem;

    if (totalAmount > widget.netAmount) {
      print('Total amount exceeds net amount. Cannot add products.');
    } else {
      try {
        final firmData =
            Provider.of<CurrentFirmProvider>(context, listen: false);
        var barcodeModel = Provider.of<BarcodeProvider>(context, listen: false);

        if (barcodeModel.barcodes.isEmpty) {
          return;
        }

        // List<Barcode> newDataList = barcodeModel.barcodes.map((barcode) {
        //       return Barcode(
        //         itemId: '',
        //         barcode: barcode.barcode,
        //         quantity: barcode.quantity,
        //         rate: barcode.rate,
        //         cgst: barcode.cgst,
        //         sgst: barcode.sgst,
        //         category: barcode.category,
        //         size: barcode.size,
        //         name: barcode.name,
        //       );
        //     }).toList() ??
        //     [];

        // String newDataString = jsonEncode(newDataList.map((barcode) {
        //   return barcode.toJson();
        // }).toList());

        billData.map((currentBill) {
          List<Barcode> itemsList = (json.decode(currentBill.items) as List)
              .map((item) => Barcode(
                    itemId: item['itemId'],
                    barcode: item['barcode'],
                    name: item['name'],
                    category: item['category'],
                    size: item['size'],
                    quantity: item['quantity'],
                    rate: item['rate'],
                    cgst: item['cgst'],
                    sgst: item['sgst'],
                    isBeingReturned: false,
                  ))
              .toList();
        });

        List<Map<String, dynamic>> newDataList =
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
        print(newDataList.first);

        List<List<Map<String, dynamic>>> preDataList =
            (billData as List).map((currentBill) {
          List<Barcode> itemsList = (json.decode(currentBill.items) as List)
              .map((item) => Barcode(
                    itemId: item['itemId'],
                    barcode: item['barcode'],
                    name: item['name'],
                    category: item['category'],
                    size: item['size'],
                    quantity: item['quantity'],
                    rate: item['rate'],
                    cgst: item['cgst'],
                    sgst: item['sgst'],
                    isBeingReturned: false,
                  ))
              .toList();

          return itemsList.map((item) {
            return {
              'name': item.name,
              'category': item.category,
              'size': item.size,
              'rate': item.rate,
              'barcode': item.barcode,
              'quantity': item.quantity,
            };
          }).toList();
        }).toList();
      } catch (e) {
        print(e);
      }
      Navigator.pop(context);
      print('Products added successfully.');
    }
  }
}
