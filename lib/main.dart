import 'package:billx/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/database_helper.dart';
import 'pages/category_page.dart';
import 'pages/create_new_bill_page.dart';
import 'pages/firms_page.dart';
import 'pages/home_page.dart';
import 'pages/items_page.dart';
import 'pages/offline_bills_page.dart';
import 'pages/online_bills_page.dart';
import 'providers/barcode_provider.dart';
import 'providers/current_firm_provider.dart';

/// create a reference for the sqlite database that
/// we can refer to in other parts of the app
late SharedPreferences sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize the database
  await DatabaseHelper.instance.database;

//innitialize shared preference
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BillX',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
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
                color: Colors.white,
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
          '/create_bill': (context) => const CreateNewBillPage(),
          '/on_bills': (context) => const OnlineBillsPage(),
          '/off_bills': (context) => const OfflineBillsPage(),
          '/splash': (context) => const SplashScreen(),
        },
      ),
    );
  }
}
