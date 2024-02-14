import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/split_bill_provider.dart';
import '../widgets/custom_page.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/delete_icon_button.dart';
import '../widgets/green_add_button.dart';
import '../widgets/show_bill_details_widget.dart';
import '../utils/utils.dart';

class SplitBillsPage extends StatefulWidget {
  const SplitBillsPage({Key? key}) : super(key: key);

  @override
  _SplitBillsPageState createState() => _SplitBillsPageState();
}

class _SplitBillsPageState extends State<SplitBillsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowList = true;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  double? totalForTheDay;

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
              controller: _searchController,
              onChanged: (value) {
                splitBillProvider.filterBills(context, value);
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Consumer<SplitBillProvider>(
          builder: (context, splitBillProvider, child) {
            List billsList = splitBillProvider.filteredSplitBills!.toList();
            return splitBillProvider.splitBills == null
                ? noDataIcon()
                : isShowList
                    ? SizedBox(
                        height: 650,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              splitBillProvider.filteredSplitBills!.length,
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
                                    isPos: splitBill.onlinePaymentMode ==
                                            'POS Machine'
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
                                        color:
                                            Color.fromARGB(255, 122, 21, 189),
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
                              height: 300,
                              child: ListView.builder(
                                itemCount: billsList.length,
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
                                  final splitBill = billsList[index];
                                  // Convert createdAt string to DateTime object
                                  DateTime billDate =
                                      DateTime.parse(splitBill.createdAt);

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
                                          splitBill.invoice,
                                          splitBill.firmId,
                                          splitBill.netAmount,
                                          splitBill.totalQuantity,
                                          splitBill.totalTax,
                                          splitBill.createdAt,
                                          isCash: true,
                                          disc: splitBill.discAmount.toInt(),
                                        );
                                      },
                                      title: Row(
                                        children: [
                                          Text(
                                            'Invoice# ${splitBill.invoice.toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                              color: Color.fromARGB(
                                                  255, 122, 21, 189),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: DeleteIconButton(
                                        onConfirm: () {
                                          Provider.of<SplitBillProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteSplitBill(
                                                  splitBill.id!, context);
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
                                  '${totalForTheDay}',
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
      ],
    );
  }
}
