import 'dart:convert';

import 'package:billx/providers/current_firm_provider.dart';
import 'package:billx/widgets/custom_button.dart';
import 'package:billx/widgets/custom_textfield.dart';
import 'package:billx/widgets/return_bill_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/barcode.dart';
import '../providers/barcode_provider.dart';
import '../providers/items_provider.dart';
import 'add_item_bill.dart';

showBillDetails(
  context,
  _billsData,
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
}) {
  showDialog(
    context: context,
    builder: (context) {
      List billData = _billsData!
          .where((element) => element.invoice == invoiceNum)
          .toList();

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
                    'DateTime: ${DateFormat('hh:m EEE dd-MM-yyyy').format(DateTime.parse(dateTime)).toString()}',
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
                      'Total Tax: ₹$totalTax',
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
                    isUpi
                        ? const Text(
                            'Mode of Payment: UPI',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      });
    },
  );
}


// class ReturnItemWindow extends StatefulWidget {
//   final String invoice;
//   final double netAmount;

//   final ItemProvider itemProvider;
//   final billdata;
//   final int qnt;

//   ReturnItemWindow(
//       {required this.netAmount,
//       required this.itemProvider,
//       required this.billdata,
//       required this.qnt,
//       required this.invoice});

//   @override
//   _ReturnItemWindowState createState() => _ReturnItemWindowState();
// }

// class _ReturnItemWindowState extends State<ReturnItemWindow> {
//   String returnOption = 'Product Replacement';
//   TextEditingController quantityController = TextEditingController();
//   final TextEditingController _changeRateController = TextEditingController();

//   @override
//   void dispose() {
//     _changeRateController.dispose();
//     quantityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Return Item'),
//       content: SizedBox(
//         height: 800,
//         width: 600,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Items to be Replaced: (${widget.qnt})',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(
//                 width: 400,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: widget.billdata.length,
//                   itemBuilder: (context, index) {
//                     var currentBill = widget.billdata[index];

//                     List<Barcode> itemsList =
//                         (json.decode(currentBill.items) as List)
//                             .map((item) => Barcode(
//                                   itemId: item['itemId'],
//                                   barcode: item['barcode'],
//                                   name: item['name'],
//                                   category: item['category'],
//                                   size: item['size'],
//                                   quantity: item['quantity'],
//                                   rate: item['rate'],
//                                   cgst: item['cgst'],
//                                   sgst: item['sgst'],
//                                   isBeingReturned: false,
//                                 ))
//                             .toList();

//                     return Column(
//                       children: itemsList.map((item) {
//                         return ListTile(
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Name: ${item.name}, Rate: ${item.rate}',
//                               ),
//                               Text(
//                                 'Barcode: ${item.barcode}, Quantity: ${item.quantity}',
//                               ),
//                               // Add more details as needed
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ),
//               Consumer<BarcodeProvider>(
//                 builder: (context, barcodeModel, child) {
//                   return Column(
//                     children: [
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const Text(
//                             'Items being replaced from:',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               showItemListDailog(barcodeModel, context);
//                             },
//                             icon: const Icon(
//                               FontAwesomeIcons.plus,
//                               color: Colors.green,
//                             ),
//                           )
//                         ],
//                       ),
//                       Card(
//                         elevation: 6,
//                         child: SizedBox(
//                           width: 800,
//                           height: 400,
//                           child: ListView.builder(
//                             physics: const BouncingScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: barcodeModel.barcodes.length,
//                             itemBuilder: (context, int index) {
//                               final existingItem = barcodeModel.barcodes[index];
//                               final itemBarcode = existingItem.barcode;
//                               int itemPrice = existingItem.rate;
//                               return ListTile(
//                                 title: Text(existingItem.name),
//                                 subtitle: Text(
//                                   'ItemId: ${existingItem.itemId}, Category: ${existingItem.category}\nSize: ${existingItem.size}, Barcode: $itemBarcode ',
//                                   style: const TextStyle(fontSize: 12),
//                                 ),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Text(
//                                           'MRP: ',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                         TextButton(
//                                           onPressed: () {
//                                             showDialog<void>(
//                                               context: context,
//                                               barrierDismissible:
//                                                   false, // user must tap button!
//                                               builder: (BuildContext context) {
//                                                 return AlertDialog(
//                                                   // <-- SEE HERE
//                                                   title: Text(
//                                                       'Change Rate (${existingItem.name})'),
//                                                   content:
//                                                       SingleChildScrollView(
//                                                     child: ListBody(
//                                                       children: <Widget>[
//                                                         CustomTextfield(
//                                                           label:
//                                                               '₹${existingItem.rate}',
//                                                           controller:
//                                                               _changeRateController,
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   actions: <Widget>[
//                                                     TextButton(
//                                                       child:
//                                                           const Text('Cancel'),
//                                                       onPressed: () {
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                     ),
//                                                     ElevatedButton(
//                                                       child:
//                                                           const Text('Change'),
//                                                       onPressed: () {
//                                                         try {
//                                                           existingItem.rate =
//                                                               int.parse(
//                                                                   _changeRateController
//                                                                       .text);
//                                                           setState(() {});
//                                                         } catch (e) {
//                                                           print(e);
//                                                         }
//                                                         _changeRateController
//                                                             .clear();
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                     ),
//                                                   ],
//                                                 );
//                                               },
//                                             );
//                                           },
//                                           child: Text(
//                                             '₹${existingItem.rate}',
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           width: 20,
//                                         ),
//                                         Text(
//                                           '${existingItem.quantity}',
//                                           style: const TextStyle(
//                                             fontSize: 19,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           width: 20,
//                                         ),
//                                         Text(
//                                           '₹${existingItem.quantity * itemPrice}',
//                                           style: const TextStyle(
//                                             color: Colors.green,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(
//                                             FontAwesomeIcons.minus,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () {
//                                             // If the checkbox is unselected, decrement the quantity
//                                             final existingItem = barcodeModel
//                                                 .barcodes
//                                                 .firstWhere(
//                                               (i) => i.barcode == itemBarcode,
//                                               orElse: () => Barcode(
//                                                 itemId: '',
//                                                 barcode: '',
//                                                 quantity: 0,
//                                                 rate: 0,
//                                                 cgst: 0,
//                                                 sgst: 0,
//                                                 category: '',
//                                                 size: '',
//                                                 name: '',
//                                                 isBeingReturned: false,
//                                               ),
//                                             );

//                                             if (existingItem.quantity > 0) {
//                                               existingItem.quantity--;

//                                               // If the quantity becomes 0, remove the item from the list
//                                               if (existingItem.quantity == 0) {
//                                                 barcodeModel
//                                                     .removeItem(existingItem);
//                                               }

//                                               barcodeModel.updateQuantity(
//                                                   existingItem,
//                                                   existingItem.quantity);
//                                               setState(() {});
//                                             }
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         children: [
//                           const Text(
//                             'Total Items: ',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             barcodeModel.calculateTotalQuantity().toString(),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 21,
//                             ),
//                           ),
//                           const Spacer(),
//                           Text(
//                             'Net Amount: ₹',
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             barcodeModel.calculateTotalSumOfRates().toString(),
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 21,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             '${widget.netAmount}',
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 21,
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '  -  ',
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 21,
//                                   color: Colors.orange),
//                             ),
//                           ),
//                           Text(
//                             barcodeModel.calculateTotalSumOfRates().toString(),
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 21,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '  =   ',
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 21,
//                                   color: Colors.orange),
//                             ),
//                           ),
//                           Text(
//                             '${widget.netAmount - barcodeModel.calculateTotalSumOfRates()}',
//                             style: GoogleFonts.poppins(
//                               textStyle: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 28,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             handleAddProducts(widget.netAmount, widget.billdata);
//           },
//           child: const Text('Generate Bill'),
//         ),
//       ],
//     );
//   }

//   void handleAddProducts(totalAmount, billData) {
//     int quantity = int.tryParse(quantityController.text) ?? 0;
//     double pricePerItem =
//         10.0; // Replace this with the actual price from your items
//     totalAmount = quantity * pricePerItem;

//     if (totalAmount > widget.netAmount) {
//       print('Total amount exceeds net amount. Cannot add products.');
//     } else {
//       try {
//         final firmData =
//             Provider.of<CurrentFirmProvider>(context, listen: false);
//         var barcodeModel = Provider.of<BarcodeProvider>(context, listen: false);

//         if (barcodeModel.barcodes.isEmpty) {
//           return;
//         }

//         // List<Barcode> newDataList = barcodeModel.barcodes.map((barcode) {
//         //       return Barcode(
//         //         itemId: '',
//         //         barcode: barcode.barcode,
//         //         quantity: barcode.quantity,
//         //         rate: barcode.rate,
//         //         cgst: barcode.cgst,
//         //         sgst: barcode.sgst,
//         //         category: barcode.category,
//         //         size: barcode.size,
//         //         name: barcode.name,
//         //       );
//         //     }).toList() ??
//         //     [];

//         // String newDataString = jsonEncode(newDataList.map((barcode) {
//         //   return barcode.toJson();
//         // }).toList());

//         billData.map((currentBill) {
//           List<Barcode> itemsList = (json.decode(currentBill.items) as List)
//               .map((item) => Barcode(
//                     itemId: item['itemId'],
//                     barcode: item['barcode'],
//                     name: item['name'],
//                     category: item['category'],
//                     size: item['size'],
//                     quantity: item['quantity'],
//                     rate: item['rate'],
//                     cgst: item['cgst'],
//                     sgst: item['sgst'],
//                   ))
//               .toList();
//         });

//         List<Map<String, dynamic>> newDataList =
//             barcodeModel.barcodes.map((barcode) {
//           return {
//             'name': barcode.name,
//             'category': barcode.category,
//             'size': barcode.size,
//             'rate': barcode.rate,
//             'barcode': barcode.barcode,
//             'quantity': barcode.quantity,
//           };
//         }).toList();
//         print(newDataList.first);

//         List<List<Map<String, dynamic>>> preDataList =
//             (billData as List).map((currentBill) {
//           List<Barcode> itemsList = (json.decode(currentBill.items) as List)
//               .map((item) => Barcode(
//                     itemId: item['itemId'],
//                     barcode: item['barcode'],
//                     name: item['name'],
//                     category: item['category'],
//                     size: item['size'],
//                     quantity: item['quantity'],
//                     rate: item['rate'],
//                     cgst: item['cgst'],
//                     sgst: item['sgst'],
//                   ))
//               .toList();

//           return itemsList.map((item) {
//             return {
//               'name': item.name,
//               'category': item.category,
//               'size': item.size,
//               'rate': item.rate,
//               'barcode': item.barcode,
//               'quantity': item.quantity,
//             };
//           }).toList();
//         }).toList();

//         printReturnBillPdf(
//           firmData,
//           invoice: widget.invoice,
//           dateTime: DateTime.now(),
//           previousItemsList: preDataList,
//           newItemsList: newDataList,
//           previousNetAmount: widget.netAmount,
//           previousItemQty: widget.qnt,
//           newNetAmount: barcodeModel.calculateTotalSumOfRates(),
//           gstDetails: barcodeModel.calculateGstForAll(),
//         );
//       } catch (e) {
//         print(e);
//       }
//       Navigator.pop(context);
//       print('Products added successfully.');
//     }
//   }
// }
