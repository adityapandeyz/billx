// import 'package:billx/pages/custom_fabric_page.dart';
import 'package:billx/pages/splash_screen.dart';
import 'package:billx/pages/split_bills_page.dart';
import 'package:billx/providers/category_provider.dart';
import 'package:billx/providers/offline_bill_provider.dart';
import 'package:billx/providers/online_bill_provider.dart';
import 'package:billx/providers/split_bill_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/database_helper.dart';
import 'pages/category_page.dart';
import 'pages/create_new_bill_page.dart';
import 'pages/firms_page.dart';
import 'pages/home_page.dart';
import 'pages/item_page.dart';
import 'pages/offline_bills_page.dart';
import 'pages/online_bills_page.dart';
import 'providers/barcode_provider.dart';
import 'providers/current_firm_provider.dart';
import 'providers/items_provider.dart';

late SharedPreferences sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  sharedPreferences = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CurrentFirmProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BarcodeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ItemProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => OnlineBillProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => OfflineBillProvider(context),
        ),
        ChangeNotifierProvider(
          create: (_) => SplitBillProvider(context),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BillX',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color.fromARGB(94, 68, 137, 255),
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.getFont('Lato'),
            bodyMedium: GoogleFonts.getFont('Lato'),
            bodySmall: GoogleFonts.getFont('Lato'),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color.fromARGB(255, 0, 0, 0),
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
            ),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.getFont(
              'Lato',
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/firms': (context) => const FirmsPage(),
          '/home': (context) => const HomePage(),
          '/category': (context) => const CategoryPage(),
          '/items': (context) => const ItemPage(),
          // '/custom_fabric': (context) => const CustomFabricPage(),
          '/create_bill': (context) => const CreateNewBillPage(),
          '/on_bills': (context) => const OnlineBillsPage(),
          '/off_bills': (context) => const OfflineBillsPage(),
          '/split_bills': (context) => const SplitBillsPage(),
          '/splash': (context) => const SplashScreen(),
        },
      ),
    );
  }
}
