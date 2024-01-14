import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../helpers/database_helper.dart';
import '../models/barcode.dart';
import '../models/online_bill.dart';
import '../providers/current_firm_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';

class OnlineBillsPage extends StatefulWidget {
  const OnlineBillsPage({super.key});

  @override
  State<OnlineBillsPage> createState() => _OnlineBillsPageState();
}

class _OnlineBillsPageState extends State<OnlineBillsPage> {
  Exception? _connectionException;
  final TextEditingController _searchController = TextEditingController();
  List<OnlineBill>? _onlineBills;
  late DatabaseHelper _databaseHelper;

  Future<void> _loadAllBills() async {
    try {
      final onlineBills = await _databaseHelper.getOnlineBills(
          Provider.of<CurrentFirmProvider>(context, listen: false)
              .currentFirmId);

      print('Online Bills: $onlineBills');

      setState(() {
        _onlineBills = onlineBills;
      });
    } catch (e) {
      print('Error loading all bills: $e');
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
      print('Error loading bills: $e');
      _connectionFailed(e);
    }
  }

  void _connectionFailed(dynamic error) {
    setState(() {
      _onlineBills = null;

      if (error is Exception) {
        // Handle Exception type
        _connectionException = error;
      } else {
        // Handle other types of errors
        _connectionException = Exception('An error occurred: $error');
      }
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

  Future<void> _deleteOnlineBill(int id) async {
    try {
      await _databaseHelper.deleteOnlineBill(id);
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
        _onlineBills = _onlineBills!.where((onlineBill) {
          String invoice = onlineBill.invoice.toUpperCase();
          String netAmount = onlineBill.netAmount.toString().toUpperCase();

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
      title: 'Online Bills',
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
        _onlineBills == null
            ? noDataIcon()
            : SizedBox(
                height: 650,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _onlineBills!.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: actionColor,
                      margin: const EdgeInsets.all(20),
                      child: ListTile(
                        onTap: () {
                          showBillDetails(
                              _onlineBills![index].invoice,
                              _onlineBills![index].firmId,
                              _onlineBills![index].netAmount,
                              _onlineBills![index].totalQuantity,
                              _onlineBills![index].totalTax);
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
                              'Invoice# ${_onlineBills![index].invoice.toString()}',
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
                              '₹${_onlineBills![index].netAmount.toString()}',
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
                            int? billsIndex = _onlineBills![index].id;

                            setState(() {
                              _onlineBills!.remove(billsIndex);
                            });

                            _deleteOnlineBill(billsIndex!);
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
        List<OnlineBill> billData = _onlineBills!
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: billData.length,
                  itemBuilder: (context, index) {
                    OnlineBill currentBill = billData[index];

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
