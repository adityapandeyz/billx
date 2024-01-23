// import 'package:billx/widgets/custom_page.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../models/fabric.dart';
// import '../widgets/custom_textfield.dart';
// import '../widgets/green_add_button.dart';

// class CustomFabricPage extends StatelessWidget {
//   const CustomFabricPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Custom Fabric'),
//       ),
//       body: Stack(
//         children: [
//           Image.network(
//             'https://images.unsplash.com/photo-1486622923572-7a7e18acf192?q=80&w=2040&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
//             width: double.infinity,
//             height: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           Center(
//             child: SizedBox(
//               height: 800,
//               width: 1200,
//               child: Card(
//                 child: Column(
//                   children: [
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CustomTextfield(
//                           label: 'Search Custom Farbric',
//                           controller:
//                               TextEditingController(), // Use a new controller or initialize it somewhere.
//                           onChanged: (value) {},
//                         ),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         GreenAddButton(
//                           function: () {
//                             _showFabricDetailsPopup(context);
//                           },
//                         )
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     GridView.count(
//                       primary: false,
//                       shrinkWrap: true,
//                       padding: const EdgeInsets.all(20),
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       crossAxisCount: 5,
//                       children: <Widget>[
//                         InkWell(
//                           onTap: () {},
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             color: Colors.teal[100],
//                             child: const Center(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         "30",
//                                         style: TextStyle(
//                                           color: Colors.red,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                       Text(
//                                         "/30 M",
//                                         style: TextStyle(),
//                                       ),
//                                     ],
//                                   ),
//                                   Text("Pant Pc "),
//                                   Text(
//                                     "Raymond",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text("(Cotton)"),
//                                   Text(
//                                     "₹ 500/M",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFabricDetailsPopup(BuildContext context) {
//     Fabric newFabric = Fabric(
//         totalStock: 0.0,
//         totalStockSold: 0,
//         fabricType: '',
//         name: '',
//         fabricId: '',
//         pricePerUnit: 40,
//         manufacturer: '',
//         firmId: '');

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add Fabric Details'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration:
//                     const InputDecoration(labelText: 'Total Stock (In M)'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   newFabric.totalStock = double.parse(value);
//                 },
//               ),
//               TextField(
//                 decoration:
//                     const InputDecoration(labelText: 'Total Stock Sold (In M)'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   newFabric.totalStockSold = double.parse(value);
//                 },
//               ),
//               TextField(
//                 decoration: const InputDecoration(labelText: 'Fabric Name'),
//                 onChanged: (value) {
//                   newFabric.name = value;
//                 },
//               ),
//               TextField(
//                 decoration: const InputDecoration(labelText: 'Cloth Type'),
//                 onChanged: (value) {
//                   newFabric.fabricType = value;
//                 },
//               ),
//               TextField(
//                 decoration: const InputDecoration(labelText: 'Price Per Meter'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   newFabric.pricePerUnit = double.parse(value);
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Handle saving fabric details here
//                 print('Fabric details saved: $newFabric');
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
