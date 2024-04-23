import 'package:billx/models/offline_bill.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/offline_bill_provider.dart';

import '../utils/utils.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/green_add_button.dart';
import '../widgets/show_bill_details_widget.dart';

class OfflineBillsPage extends StatefulWidget {
  const OfflineBillsPage({Key? key}) : super(key: key);

  @override
  State<OfflineBillsPage> createState() => _OfflineBillsPageState();
}

class _OfflineBillsPageState extends State<OfflineBillsPage> {
  bool isShowList = true;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  double? totalForTheDay;

  List<OfflineBill> billsForSelectedDate = [];

  @override
  void initState() {
    super.initState();
    Provider.of<OfflineBillProvider>(context, listen: false)
        .loadOfflineBills(context);
    updateBillsForSelectedDate();
  }

  void updateBillsForSelectedDate() {
    final billsList = Provider.of<OfflineBillProvider>(context, listen: false)
        .offlineBillList;
    billsForSelectedDate = billsList!.where((bill) {
      DateTime billDate = DateTime.parse(bill.createdAt);
      return isSameDay(billDate, selectedDate);
    }).toList();

    totalForTheDay = billsForSelectedDate.fold(
      0,
      (previousValue, bill) => previousValue! + bill.netAmount,
    );
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
            Row(
              children: [
                GreenButton(
                  icon: isShowList
                      ? FontAwesomeIcons.database
                      : FontAwesomeIcons.dochub,
                  function: () {
                    setState(() {});
                    isShowList = !isShowList;
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
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
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Consumer<OfflineBillProvider>(
          builder: (context, offlineBillProvider, child) {
            List billsList = offlineBillProvider.filteredOfflineBills!.toList();

            return offlineBillProvider.offlineBills == null
                ? noDataIcon()
                : isShowList
                    ? SizedBox(
                        height: 650,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: billsList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final offlineBill = billsList[index];
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
                                        color:
                                            Color.fromARGB(255, 122, 21, 189),
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
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TableCalendar(
                              calendarFormat: CalendarFormat.month,
                              pageAnimationEnabled: false,
                              calendarBuilders: const CalendarBuilders(),
                              startingDayOfWeek: StartingDayOfWeek.sunday,
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Month'
                              },
                              selectedDayPredicate: (day) {
                                return isSameDay(selectedDate, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  selectedDate = selectedDay;
                                  focusedDate = focusedDay;
                                  updateBillsForSelectedDate();
                                });
                              },
                              eventLoader: (date) {
                                return billsList
                                        .where((bill) => isSameDay(
                                            DateTime.parse(bill.createdAt),
                                            date))
                                        .isNotEmpty
                                    ? [true]
                                    : [];
                              },
                              focusedDay: focusedDate,
                              firstDay: DateTime(2024),
                              lastDay: DateTime(2050),
                            ),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                itemCount: billsForSelectedDate.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  totalForTheDay =
                                      billsList.fold(0, (previousValue, bill) {
                                    // Convert createdAt string to DateTime object
                                    DateTime billDate =
                                        DateTime.parse(bill.createdAt);

                                    // Extract day, month, and year components
                                    int billDay = billDate.day;
                                    int billMonth = billDate.month;
                                    int billYear = billDate.year;

                                    // Extract selectedDate components
                                    int selectedDay = selectedDate.day;
                                    int selectedMonth = selectedDate.month;
                                    int selectedYear = selectedDate.year;

                                    // If the bill matches the selected date, add its netAmount to the total
                                    if (billDay == selectedDay &&
                                        billMonth == selectedMonth &&
                                        billYear == selectedYear) {
                                      return previousValue! + bill.netAmount;
                                    }
                                    return previousValue;
                                  });
                                  final offlineBill =
                                      billsForSelectedDate[index];
                                  // Convert createdAt string to DateTime object
                                  DateTime billDate =
                                      DateTime.parse(offlineBill.createdAt);

                                  // Extract day, month, and year components
                                  int billDay = billDate.day;
                                  int billMonth = billDate.month;
                                  int billYear = billDate.year;

                                  // Extract selectedDate components
                                  int selectedDay = selectedDate.day;
                                  int selectedMonth = selectedDate.month;
                                  int selectedYear = selectedDate.year;

                                  // Check if the bill matches the selectedDate
                                  if (billDay == selectedDay &&
                                      billMonth == selectedMonth &&
                                      billYear == selectedYear) {
                                    return ListTile(
                                      onTap: () {
                                        showBillDetails(
                                          context,
                                          billsList,
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
                                      title: Row(
                                        children: [
                                          Text(
                                            'Invoice# ${offlineBill.invoice.toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                              color: Color.fromARGB(
                                                  255, 122, 21, 189),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: DeleteIconButton(
                                        onConfirm: () {
                                          Provider.of<OfflineBillProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteOfflineBill(
                                                  offlineBill.id!, context);
                                          updateBillsForSelectedDate();
                                        },
                                        onCancel: () {
                                          // Handle cancel if needed
                                        },
                                      ),
                                    );
                                  } else {
                                    return const SizedBox
                                        .shrink(); // Return an empty SizedBox if the bill doesn't match the selectedDate
                                  }
                                },
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total For The Day: ',
                                  style: GoogleFonts.lato(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 16,
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  '$totalForTheDay',
                                  style: GoogleFonts.lato(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
          },
        ),
        const Spacer(),
      ],
    );
  }
}
