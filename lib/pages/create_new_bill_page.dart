import 'dart:convert';

import 'package:billx/models/split_bill.dart';
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
import '../providers/items_provider.dart';
import '../providers/offline_bill_provider.dart';
import '../providers/online_bill_provider.dart';
import '../providers/split_bill_provider.dart';
import '../utils/utils.dart';
import '../widgets/add_item_bill.dart';
import '../widgets/add_item_widget.dart';
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
  Map<String, TextEditingController> quantityControllers = {};
  final TextEditingController _changeRateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  int invoiceNum = 0;
  // int totalBasePrice = 0;
  // int totalItems = 0;

  String? _barcode;
  late bool visible;

  @override
  void dispose() {
    _changeRateController.dispose();
    _discountController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final firmData = Provider.of<CurrentFirmProvider>(context, listen: false);
    ItemProvider itemProvider =
        Provider.of<ItemProvider>(context, listen: false);
    itemProvider.loadItems(context);

    SplitBillProvider splitBillProvider =
        Provider.of<SplitBillProvider>(context, listen: false);

    splitBillProvider.loadSplitBills(context);

    OnlineBillProvider onlineBillProvider =
        Provider.of<OnlineBillProvider>(context, listen: false);
    onlineBillProvider.loadOnBills(context);

    Provider.of<OfflineBillProvider>(context, listen: false)
        .loadOfflineBills(context);

    return Consumer<BarcodeProvider>(builder: (context, barcodeModel, child) {
      var invoice =
          '${firmData.currentFirmId}IV${onlineBillProvider.onlineBills?.last != null ? (onlineBillProvider.onlineBillList!.last.id!) : 0 + 1}';

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
            barcodeModel.discAmount = 0.0;
            // totalBasePrice = 0;
            // totalItems = 0;
            Navigator.of(context).pop();
          },
          title: 'Create New Bill',
          widget: [
            Row(
              children: [
                Text(
                  'Invoice# $invoice',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      'Disc: ${barcodeModel.discAmount}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.edit),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('AlertDialog Title'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    CustomTextfield(
                                      label: 'Discount Amount ₹',
                                      controller: _discountController,
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    if (_discountController.text.isEmpty) {
                                      return;
                                    }

                                    setState(() {
                                      barcodeModel.discAmount = double.parse(
                                          _discountController.text);
                                    });

                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
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
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const Dialog(
                          child: AddItemPopup(),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // background (button) color
                    foregroundColor: Colors.white, // foreground (text) color
                  ),
                  child: const Text('Add New Item'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showItemListDailog(barcodeModel, context);
                  },
                  icon: const Icon(FontAwesomeIcons.plus),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            BarcodeKeyboardListener(
              useKeyDownEvent: true,
              bufferDuration: const Duration(milliseconds: 200),
              onBarcodeScanned: (barcode) {
                setState(() {
                  _barcode =
                      barcode.replaceAll(RegExp(r'\s+'), '').toUpperCase();

                  // Check if the scanned barcode exists in the itemProvider.itemList! list
                  late Item matchingItem;
                  bool isMatched = false;

                  for (var item in itemProvider.itemList!) {
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
                      (item) => item.barcode == _barcode!,
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
                      // totalItems += 1;
                      // totalBasePrice += matchingItem.price.toInt();
                    } else {
                      existingItem.quantity++;
                      // totalItems += 1;
                      // totalBasePrice += matchingItem.price.toInt();
                      barcodeModel.updateQuantity(
                          existingItem, existingItem.quantity);
                    }
                  } else {
                    // Item not found in the database, show alert or handle it accordingly
                    showAlert(
                        context, 'Item with barcode $_barcode not found.');
                  }
                });
              },
              child: Container(
                  // Your UI code here, if any
                  ),
            ),
            Card(
              elevation: 6,
              child: SizedBox(
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
                      tileColor: existingItem.isBeingReturned == true
                          ? const Color.fromARGB(255, 255, 167, 167)
                          : Colors.white,
                      onTap: () {
                        existingItem.isBeingReturned == true
                            ? existingItem.isBeingReturned = false
                            : existingItem.isBeingReturned = true;
                        setState(() {});
                      },
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
                              TextButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible:
                                        false, // user must tap button!
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        // <-- SEE HERE
                                        title: Text(
                                            'Change Rate (${existingItem.name})'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              CustomTextfield(
                                                label: '₹${existingItem.rate}',
                                                controller:
                                                    _changeRateController,
                                              )
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text('Change'),
                                            onPressed: () {
                                              try {
                                                existingItem.rate = int.parse(
                                                    _changeRateController.text);
                                                setState(() {});
                                              } catch (e) {
                                                print(e);
                                              }
                                              _changeRateController.clear();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  '₹${existingItem.rate}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                '${existingItem.quantity}',
                                style: const TextStyle(
                                  fontSize: 19,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                '₹${existingItem.quantity * itemPrice}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.minus,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  final existingItem =
                                      barcodeModel.barcodes.firstWhere(
                                    (i) => i.barcode == itemBarcode,
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

                                    barcodeModel.updateQuantity(
                                        existingItem, existingItem.quantity);
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                  barcodeModel.calculateTotalQuantity().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 21,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
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
                      barcodeModel.calculateTotalSumOfRates().toString(),
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
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text(
                  'Return Qty: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  barcodeModel.calculateTotalReturnQuantity().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
                Text(
                  'Return Item Value: ₹',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  barcodeModel.calculateTotalSumOfRatesForReturn().toString(),
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.red,
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
                      'Total SGST: ${barcodeModel.calculateGstForAll().totalSgst.toStringAsFixed(2)}, Total CGST: ${barcodeModel.calculateGstForAll().totalCgst.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Total Tax: ${barcodeModel.calculateGstForAll().totalTax.toStringAsFixed(2)}',
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
                    text: 'Split',
                    onTap: () =>
                        handlePayment(PaymentType.split, barcodeModel)),
                const SizedBox(
                  width: 10,
                ),
                CustomButton(
                  width: 160,
                  text: 'Cash',
                  onTap: () => handlePayment(PaymentType.cash, barcodeModel),
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomButton(
                  width: 160,
                  text: "Online",
                  onTap: () => handlePayment(PaymentType.online, barcodeModel),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  var selectedPaymentType = PaymentType.cash;

  void handlePayment(selectedPaymentType, BarcodeProvider barcodeModel) async {
    try {
      if (barcodeModel.barcodes.isEmpty) {
        return;
      }
      final onlineBillProvider =
          Provider.of<OnlineBillProvider>(context, listen: false);
      final offlineBillProvider =
          Provider.of<OfflineBillProvider>(context, listen: false);
      final splitBillProvider =
          Provider.of<SplitBillProvider>(context, listen: false);

      List<Barcode> barcodeDataList = barcodeModel.barcodes.map((barcode) {
            return Barcode(
              isBeingReturned: barcode.isBeingReturned,
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
      List<Map<String, dynamic>> dataList =
          barcodeModel.barcodes.map((barcode) {
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
      if (selectedPaymentType == PaymentType.online) {
        String? selectedPaymentMethod = await showPaymentMethodDialog(context);

        // Update mode of payment based on user selection
        String modeOfPayment = selectedPaymentMethod!;

        var invoiceOn =
            '${firmData.currentFirmId}iv${onlineBillProvider.onlineBillList!.isNotEmpty ? (onlineBillProvider.onlineBillList!.last.id!) : 0 + 1}';

        var onBill = OnlineBill(
          discAmount: barcodeModel.discAmount,
          firmId: firmData.currentFirmId,
          createdAt: DateTime.now().toIso8601String(),
          invoice: invoiceOn,
          items: barcodeDataString,
          netAmount: barcodeModel.calculateTotalSumOfRates().toDouble(),
          totalTax: barcodeModel.calculateGstForAll().totalTax,
          modeOfPayment: modeOfPayment.toString(),
          totalQuantity: barcodeModel.calculateTotalQuantity().toInt(),
        );

        onlineBillProvider.createOnlineBill(context, onBill);

        printPdf(
          firmData,
          invoice: invoiceOn,
          dateTime: DateTime.now(),
          totalQuantity: barcodeModel.calculateTotalQuantity().toInt(),
          netAmount: barcodeModel.calculateTotalSumOfRates().toDouble(),
          itemsList: dataList,
          gstDetails: barcodeModel.calculateGstForAll(),
          selectedModeOfPayment: modeOfPayment,
          discAmount: barcodeModel.discAmount,
        );
      }
      if (selectedPaymentType == PaymentType.cash) {
        offlineBillProvider.loadOfflineBills(context);
        var invoiceOff =
            '${firmData.currentFirmId}v${offlineBillProvider.offlineBillList!.isNotEmpty ? (offlineBillProvider.offlineBillList!.last.id!) : 0 + 1}';
        var offBill = OfflineBill(
          discAmount: barcodeModel.discAmount,
          firmId: firmData.currentFirmId,
          createdAt: DateTime.now().toIso8601String(),
          invoice: invoiceOff,
          items: barcodeDataString,
          netAmount: barcodeModel.calculateTotalSumOfRates().toDouble(),
          totalTax: barcodeModel.calculateGstForAll().totalTax,
          modeOfPayment: 'Cash',
          totalQuantity: barcodeModel.calculateTotalQuantity().toInt(),
        );

        offlineBillProvider.createOfflineBill(context, offBill);

        printPdf(
          firmData,
          invoice: invoiceOff,
          dateTime: DateTime.now(),
          totalQuantity: barcodeModel.calculateTotalQuantity().toInt(),
          netAmount: barcodeModel.calculateTotalSumOfRates().toDouble(),
          itemsList: dataList,
          gstDetails: barcodeModel.calculateGstForAll(),
          selectedModeOfPayment: 'Cash',
          discAmount: barcodeModel.discAmount,
        );
      }

      if (selectedPaymentType == PaymentType.split) {
        Map<String, dynamic>? paymentAmounts = await showPaymentAmountDialog();

        if (paymentAmounts != null) {
          double? cashAmount = paymentAmounts['cashAmount'];
          double? onlineAmount = paymentAmounts['onlineAmount'];
          String? _onlinePaymentMode = paymentAmounts['onlinePaymentMode'];

          var invoiceOn =
              '${firmData.currentFirmId}vi${splitBillProvider.splitBills!.isNotEmpty ? splitBillProvider.splitBills!.last.id : 0 + 1}';

          var splitBill = SplitBill(
            discAmount: barcodeModel.discAmount,
            firmId: firmData.currentFirmId,
            createdAt: DateTime.now().toIso8601String(),
            invoice: invoiceOn,
            items: barcodeDataString,
            cashAmount: double.parse(cashAmount.toString()),
            onlineAmount: double.parse(onlineAmount.toString()),
            netAmount: barcodeModel.calculateTotalSumOfRates().toDouble(),
            totalTax: barcodeModel.calculateGstForAll().totalTax,
            onlinePaymentMode: _onlinePaymentMode!,
            totalQuantity: barcodeModel.calculateTotalQuantity().toInt(),
          );

          splitBillProvider.createSplitBill(context, splitBill);

          printPdf(
            firmData,
            isSplit: true,
            invoice: invoiceOn,
            dateTime: DateTime.now(),
            totalQuantity: barcodeModel.calculateTotalQuantity().toInt(),
            cashAmount: cashAmount,
            onlineAmount: onlineAmount,
            netAmount: barcodeModel.calculateTotalSumOfRates().toDouble(),
            itemsList: dataList,
            gstDetails: barcodeModel.calculateGstForAll(),
            selectedModeOfPayment: _onlinePaymentMode,
            discAmount: barcodeModel.discAmount,
          );
        }
      }
      barcodeModel.barcodes.clear();
      barcodeModel.discAmount = 0.0;

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

  Future<Map<String, dynamic>?> showPaymentAmountDialog() async {
    TextEditingController? cashController = TextEditingController();
    TextEditingController? onlineController = TextEditingController();
    String? selectedOnlinePaymentMode;

    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Payment Amounts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cashController,
                decoration: const InputDecoration(labelText: 'Cash Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: onlineController,
                decoration: const InputDecoration(labelText: 'Online Amount'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedOnlinePaymentMode,
                onChanged: (value) {
                  selectedOnlinePaymentMode = value;
                },
                items: ['UPI', 'POS Machine']
                    .map((mode) => DropdownMenuItem<String>(
                          value: mode,
                          child: Text(mode),
                        ))
                    .toList(),
                hint: const Text('Select Online Payment Mode'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without submitting
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Get entered amounts and mode
                double cashAmount =
                    double.tryParse(cashController?.text ?? '0') ?? 0;
                double onlineAmount =
                    double.tryParse(onlineController?.text ?? '0') ?? 0;

                // Calculate total amount
                double totalAmount = cashAmount + onlineAmount;

                // Get totalBasePrice (replace with your actual value)

                // Check if total amount is within acceptable range
                if (totalAmount ==
                    Provider.of<BarcodeProvider>(context)
                        .calculateTotalSumOfRates()
                        .toDouble()) {
                  // If it's equal, submit the values
                  Navigator.of(context).pop({
                    'cashAmount': cashAmount,
                    'onlineAmount': onlineAmount,
                    'onlinePaymentMode': selectedOnlinePaymentMode,
                  });
                } else {
                  // Show an error message or handle the validation accordingly
                  // For example, you can display a snackbar with an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Total amount must be equal to ${Provider.of<BarcodeProvider>(context).calculateTotalSumOfRates().toDouble()}'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

enum PaymentType { cash, online, split }
