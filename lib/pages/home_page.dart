import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/current_firm_provider.dart';
import '../widgets/custom_square.dart';

import '../providers/items_provider.dart';
import '../providers/offline_bill_provider.dart';
import '../providers/online_bill_provider.dart';
import '../providers/split_bill_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Provider.of<OfflineBillProvider>(context, listen: false)
        .loadOfflineBills(context);

    Provider.of<OnlineBillProvider>(context, listen: false)
        .loadOnBills(context);

    Provider.of<SplitBillProvider>(context, listen: false)
        .loadSplitBills(context);

    Provider.of<ItemProvider>(context, listen: false).loadItems(context);

    Provider.of<CategoryProvider>(context, listen: false)
        .loadItemCategories(context);

    return Consumer<CurrentFirmProvider>(
        builder: (context, currentFirm, child) {
      return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, top: 8, bottom: 8, right: 0),
            child: Image.asset('assets/logo/billx.png'),
          ),
          title: const Text('BillX'),
          actions: [
            Text(
              '${currentFirm.currentFirmName} (${currentFirm.currentFirmId})',
            ),
            const Text('   /'),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/firms',
                  (route) => false,
                );
              },
              child: const Text('Change Firm'),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
                height: 200,
                child: Image(
                  fit: BoxFit.cover,
                  image: AssetImage(
                      'assets/images/ishant-mishra-Ha4GZKWINdw-unsplash.jpg'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomSquare(
                    icons: FontAwesomeIcons.plus,
                    title: 'Create New Bill',
                    ontap: () {
                      Navigator.pushNamed(context, '/create_bill');
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  CustomSquare(
                    icons: FontAwesomeIcons.boxArchive,
                    title: 'Categories',
                    ontap: () {
                      Navigator.pushNamed(context, '/category');
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  CustomSquare(
                    icons: FontAwesomeIcons.tshirt,
                    title: 'Items',
                    ontap: () {
                      Navigator.pushNamed(context, '/items');
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomSquare(
                    icons: FontAwesomeIcons.scissors,
                    title: 'Splited Bills',
                    ontap: () {
                      Navigator.pushNamed(context, '/split_bills');
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  CustomSquare(
                    icons: FontAwesomeIcons.googlePay,
                    title: 'Online Bills',
                    ontap: () {
                      Navigator.pushNamed(context, '/on_bills');
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  CustomSquare(
                    icons: FontAwesomeIcons.moneyBills,
                    title: 'Offline Bills',
                    ontap: () {
                      Navigator.pushNamed(context, '/off_bills');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
