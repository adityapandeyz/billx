import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../helpers/database_helper.dart';
import '../models/barcode.dart';
import '../models/offline_bill.dart';
import '../providers/current_firm_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';

class OfflineBillsPage extends StatefulWidget {
  const OfflineBillsPage({super.key});

  @override
  State<OfflineBillsPage> createState() => _OfflineBillsPageState();
}

class _OfflineBillsPageState extends State<OfflineBillsPage> {
  Exception? _connectionException;
  final TextEditingController _searchController = TextEditingController();
  List<OfflineBill>? _offlineBills;
  late DatabaseHelper _databaseHelper;

  Future<void> _loadAllBills() async {
    try {
      final offlineBills = await _databaseHelper.getOfflineBills(
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId);
      setState(() {
        _offlineBills = offlineBills;
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  Future<void> _loadBills() async {
    try {
      if (_searchController.text.isEmpty) {
        await _loadAllBills();
      } else {
        _filterBills();
      }
    } catch (e) {
      _connectionFailed(e);
    }
  }

  void _connectionFailed(dynamic exception) {
    setState(() {
      _offlineBills = null;
      _connectionException = exception;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper.instance;

    _loadBills();
  }

  Future<void> _deleteOfflineBill(id) async {
    try {
      await _databaseHelper.deleteOfflineBill(id);
      await _loadBills();
    } catch (e) {
      _connectionFailed(e);
    }
  }

  void _filterBills() {
    String searchText = _searchController.text.toUpperCase();

    setState(() {
      if (searchText.isEmpty) {
        // If search text is empty, load all bills
        _loadAllBills();
      } else {
        _offlineBills = _offlineBills!.where((offlineBill) {
          String invoice = offlineBill.invoice.toUpperCase();
          String netAmount = offlineBill.netAmount.toString().toUpperCase();

          final searchTerms = searchText.split(' ');

          // Check if any of the search terms is present in either billId, invoice, or netAmount
          return searchTerms.every(
              (term) => invoice.contains(term) || netAmount.contains(term));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: 'Offline Bills',
      widget: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield(
              label: 'Search Bill',
              controller: _searchController,
              onChanged: (value) {
                _filterBills(); // Call the function to filter bills when the search text changes
              },
            ),

            // const SizedBox(
            //   width: 10,
            // ),
            // GreenAddButton(
            //   function: () {
            //     addBill();
            //   },
            // )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        _offlineBills == null
            ? noDataIcon()
            : SizedBox(
                height: 650,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _offlineBills!.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: actionColor,
                      margin: const EdgeInsets.all(20),
                      child: ListTile(
                        onTap: () {
                          showBillDetails(
                              _offlineBills![index].invoice,
                              _offlineBills![index].firmId,
                              _offlineBills![index].netAmount,
                              _offlineBills![index].totalQuantity,
                              _offlineBills![index].totalTax);
                        },
                        leading: const SizedBox(
                          width: 60,
                          child: Icon(
                            FontAwesomeIcons.stickyNote,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              'Invoice# ${_offlineBills![index].invoice.toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '₹${_offlineBills![index].netAmount.toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 122, 21, 189),
                              ),
                            ),
                          ],
                        ),
                        // subtitle: Column(
                        //   mainAxisSize: MainAxisSize.min,
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       'Invoice# ${_bills![index].invoice.toString()}',
                        //     ),
                        //   ],
                        // ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            var billsIndex = _offlineBills![index];

                            setState(() {
                              _offlineBills!.remove(billsIndex);
                            });

                            _deleteOfflineBill(billsIndex.id);
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

  showBillDetails(
      String invoiceNum, firmId, netAmount, totalQuantity, totalTax) {
    showDialog(
      context: context,
      builder: (context) {
        List<OfflineBill> billData = _offlineBills!
            .where((element) => element.invoice == invoiceNum)
            .toList();

        if (billData.isEmpty) {
          // Handle the case where no bill with the given ID is found
          return AlertDialog(
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
          );
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
                  Text('Invoice #: $invoiceNum'),
                  // Add more details as needed
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Items:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 400,
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: billData.length,
                  itemBuilder: (context, index) {
                    OfflineBill currentBill = billData[index];

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
                                ))
                            .toList();
                    return Column(
                      children: itemsList.map((item) {
                        return ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Barcode: ${item.barcode}, Quantity: ${item.quantity}',
                              ),
                              // Add more details as needed
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text(
                    'Total Quantity: $totalQuantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        'Net Amount: $netAmount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' Total Tax: $totalTax',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
