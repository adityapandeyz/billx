import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/split_bill_provider.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/show_bill_details_widget.dart';
import '../utils/utils.dart';

class SplitBillsPage extends StatefulWidget {
  const SplitBillsPage({Key? key}) : super(key: key);

  @override
  _SplitBillsPageState createState() => _SplitBillsPageState();
}

class _SplitBillsPageState extends State<SplitBillsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SplitBillProvider splitBillProvider =
        Provider.of<SplitBillProvider>(context, listen: false);

    splitBillProvider.loadSplitBills(context);
    return CustomPage(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: 'Split Bills',
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
                splitBillProvider.filterBills(context, value);
              },
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Consumer<SplitBillProvider>(
          builder: (context, offlineBillProvider, child) {
            return splitBillProvider.splitBills == null
                ? noDataIcon()
                : SizedBox(
                    height: 650,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: splitBillProvider.filteredSplitBills!.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        var splitBill =
                            splitBillProvider.filteredSplitBills![index];

                        return Card(
                          color: actionColor,
                          margin: const EdgeInsets.all(20),
                          child: ListTile(
                            onTap: () {
                              showBillDetails(
                                context,
                                splitBillProvider.filteredSplitBills,
                                splitBill.invoice,
                                splitBill.firmId,
                                splitBill.netAmount,
                                splitBill.totalQuantity,
                                splitBill.totalTax,
                                splitBill.createdAt,
                                isSplit: true,
                                cash: splitBill.cashAmount.toInt(),
                                online: splitBill.onlineAmount.toInt(),
                                isPos:
                                    splitBill.onlinePaymentMode == 'POS Machine'
                                        ? true
                                        : false,
                                isUpi: splitBill.onlinePaymentMode == 'UPI'
                                    ? true
                                    : false,
                                disc: splitBill.discAmount.toInt(),
                              );
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
                                  'Invoice# ${splitBill.invoice.toString()}',
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
                                  '₹${splitBill.netAmount.toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 122, 21, 189),
                                  ),
                                ),
                                Text(
                                  '  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(splitBill.createdAt)).toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: DeleteIconButton(
                              onConfirm: () {
                                int? billsIndex = splitBill.id;
                                splitBillProvider.deleteSplitBill(
                                    billsIndex!, context);
                              },
                              onCancel: () {
                                // Handle cancel if needed
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
          },
        ),
      ],
    );
  }
}
