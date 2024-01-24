import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/offline_bill_provider.dart';

import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/show_bill_details_widget.dart';

class OfflineBillsPage extends StatelessWidget {
  const OfflineBillsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<OfflineBillProvider>(context, listen: false)
        .loadOfflineBills(context);

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
              onChanged: (value) {
                Provider.of<OfflineBillProvider>(context, listen: false)
                    .filterBills(context, value);
              },
              controller: TextEditingController(),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Consumer<OfflineBillProvider>(
          builder: (context, offlineBillProvider, child) {
            return offlineBillProvider.offlineBills == null
                ? noDataIcon()
                : SizedBox(
                    height: 650,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          offlineBillProvider.filteredOfflineBills!.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final offlineBill =
                            offlineBillProvider.filteredOfflineBills![index];
                        return Card(
                          color: actionColor,
                          margin: const EdgeInsets.all(20),
                          child: ListTile(
                            onTap: () {
                              showBillDetails(
                                context,
                                offlineBillProvider.filteredOfflineBillList,
                                offlineBill.invoice,
                                offlineBill.firmId,
                                offlineBill.netAmount,
                                offlineBill.totalQuantity,
                                offlineBill.totalTax,
                                offlineBill.createdAt,
                                isCash: true,
                                disc: offlineBill.discAmount.toInt(),
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
                                  'Invoice# ${offlineBill.invoice.toString()}',
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
                                  '₹${offlineBill.netAmount.toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 122, 21, 189),
                                  ),
                                ),
                                Text(
                                  '  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(offlineBill.createdAt)).toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: DeleteIconButton(
                              onConfirm: () {
                                Provider.of<OfflineBillProvider>(context,
                                        listen: false)
                                    .deleteOfflineBill(
                                        offlineBill.id!, context);
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
        const Spacer(),
      ],
    );
  }
}
