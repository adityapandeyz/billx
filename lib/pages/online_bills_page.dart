import 'package:billx/providers/online_bill_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/show_bill_details_widget.dart';

class OnlineBillsPage extends StatelessWidget {
  const OnlineBillsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<OnlineBillProvider>(context, listen: false)
        .loadOnBills(context);

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
              onChanged: (value) {
                Provider.of<OnlineBillProvider>(context, listen: false)
                    .filterBills(context, value);
              },
              controller: TextEditingController(),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Consumer<OnlineBillProvider>(
          builder: (context, onlineBillProvider, child) {
            return onlineBillProvider.onlineBills == null
                ? noDataIcon()
                : SizedBox(
                    height: 650,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: onlineBillProvider.filteredOnlineBills!.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final onlineBill =
                            onlineBillProvider.filteredOnlineBills![index];
                        return Card(
                          color: actionColor,
                          margin: const EdgeInsets.all(20),
                          child: ListTile(
                            onTap: () {
                              showBillDetails(
                                context,
                                onlineBillProvider.filteredOnlineBillList,
                                onlineBill.invoice,
                                onlineBill.firmId,
                                onlineBill.netAmount,
                                onlineBill.totalQuantity,
                                onlineBill.totalTax,
                                onlineBill.createdAt,
                                isPos: onlineBill.modeOfPayment == 'POS Machine'
                                    ? true
                                    : false,
                                isUpi: onlineBill.modeOfPayment == 'UPI'
                                    ? true
                                    : false,
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
                                  'Invoice# ${onlineBill.invoice.toString()}',
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
                                  '₹${onlineBill.netAmount.toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 122, 21, 189),
                                  ),
                                ),
                                Text(
                                  '  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(onlineBill.createdAt)).toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: DeleteIconButton(
                              onConfirm: () {
                                Provider.of<OnlineBillProvider>(context,
                                        listen: false)
                                    .deleteOnlineBill(onlineBill.id!, context);
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
