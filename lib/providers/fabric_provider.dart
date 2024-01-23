// import 'package:billx/helpers/database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../models/fabric.dart';
// import 'current_firm_provider.dart';

// class FabricProvider extends ChangeNotifier {
//   List<Fabric>? fabricList;
//   late DatabaseHelper databaseHelper;

//   Exception? connectionException;

//   FabricProvider(BuildContext context) {
//     databaseHelper = DatabaseHelper.instance;
//     loadFabrics(context);
//   }

//   List<Fabric>? get fabrics => fabricList;

//   Future<void> loadFabrics(BuildContext context) async {
//     try {
//       final currentFirmId =
//           Provider.of<CurrentFirmProvider>(context, listen: false)
//               .currentFirmId;

//       final fabrics = await databaseHelper.getAllFabrics(currentFirmId);

//       fabricList = fabrics;
//       notifyListeners();
//     } catch (e) {
//       connectionFailed(e);
//     }
//   }

//   void connectionFailed(dynamic exception) {
//     fabricList = null;
//     notifyListeners();
//     connectionException = exception;
//   }

//   Future<void> createFabric(Fabric fabric, context) async {
//     try {
//       await databaseHelper.insertFabric(fabric);
//       await loadFabrics(context);
//     } catch (e) {
//       connectionFailed(e);
//     }
//   }
// }
