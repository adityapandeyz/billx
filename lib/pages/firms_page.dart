import 'package:billx/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/firm.dart';
import '../providers/current_firm_provider.dart';
import '../utils/utils.dart';
import '../widgets/custom_square.dart';
import '../widgets/custom_textfield.dart';

class FirmsPage extends StatefulWidget {
  const FirmsPage({super.key});

  @override
  State<FirmsPage> createState() => _FirmsPageState();
}

class _FirmsPageState extends State<FirmsPage> {
  // List<Firm>? _firms;
  Exception? _connectionException;

  TextEditingController firmNameController = TextEditingController();
  TextEditingController firmIdController = TextEditingController();
  TextEditingController firmGSTINContoller = TextEditingController();
  TextEditingController firmAddressController = TextEditingController();
  TextEditingController firmPhoneNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  @override
  void dispose() {
    firmNameController.dispose();
    firmIdController.dispose();
    firmGSTINContoller.dispose();
    firmAddressController.dispose();
    firmPhoneNoController.dispose();
    passwordController.dispose();
    loginPasswordController.clear();

    super.dispose();
  }

  void _connectionFailed(dynamic exception) {
    setState(() {
      // _firms = null;
      _connectionException = exception;
    });
  }

  List<Firm> _firms = [];

  Future<void> _loadFirms() async {
    try {
      final List<Map<String, dynamic>> firmData =
          await DatabaseHelper.instance.getAllFirms();
      final List<Firm> firms =
          firmData.map((map) => Firm.fromJson(map)).toList();

      setState(() {
        _firms = firms;
      });
    } catch (e) {
      _connectionFailed(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFirms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, top: 8, bottom: 8, right: 0),
            child: Image.asset('assets/logo/billx.png')),
        title: const Text('Select or Add a Firm'),
        actions: [
          IconButton(
              onPressed: () => _loadFirms(),
              icon: const Icon(
                FontAwesomeIcons.redo,
              ))
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
              height: 100,
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/ishant-mishra-Ha4GZKWINdw-unsplash.jpg',
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _firms == null
                ? noDataIcon()
                : SizedBox(
                    height: 400,
                    width: 600,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: _firms.length,
                      itemBuilder: (context, int index) {
                        return CustomSquare(
                          icons: Icons.home_work,
                          title: _firms[index].name,
                          ontap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Enter Password'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomTextfield(
                                        label: 'Password',
                                        controller: loginPasswordController,
                                        isPass: true,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        loginPasswordController.clear();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text("Submit"),
                                      onPressed: () async {
                                        Navigator.pop(context);

                                        // Check if entered password matches the firm's password
                                        String enteredPassword =
                                            loginPasswordController.text.trim();
                                        if (_firms[index].password ==
                                            enteredPassword) {
                                          Provider.of<CurrentFirmProvider>(
                                                  context,
                                                  listen: false)
                                              .setCurrentFirm(
                                            firmName: _firms[index].name,
                                            firmId: _firms[index].firmId,
                                            gstin: _firms[index].gstin,
                                            phone: _firms[index].phone,
                                            address: _firms[index].address,
                                          );
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/home',
                                            (route) => false,
                                          );
                                          loginPasswordController.clear();
                                        } else {
                                          loginPasswordController.clear();

                                          showAlert(
                                              context, 'Incorrect password.');
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ))
          ],
        ),
      ),
      floatingActionButton: _firms == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                addFirm(context);
              },
              child: const Icon(
                FontAwesomeIcons.plus,
              ),
            ),
    );
  }

  addFirm(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Firm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextfield(
                label: 'Name',
                controller: firmNameController,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'GSTIN',
                controller: firmGSTINContoller,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Phone No.',
                controller: firmPhoneNoController,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Address',
                controller: firmAddressController,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Password',
                controller: passwordController,
                isPass: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
              ),
              onPressed: () {
                Navigator.pop(context);
                firmAddressController.clear();
                firmNameController.clear();
                firmGSTINContoller.clear();
                firmPhoneNoController.clear();
                passwordController.clear();
                firmIdController.clear();
              },
            ),
            ElevatedButton(
              child: const Text(
                "Add",
              ),
              onPressed: () async {
                Navigator.pop(context);

                if (firmNameController.text.isEmpty ||
                    firmAddressController.text.isEmpty ||
                    firmGSTINContoller.text.isEmpty ||
                    firmPhoneNoController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  return;
                }

                String shortenText(String text) {
                  List<String> words = text.split(' ');

                  // Extract the first letter of each word
                  List<String> firstLetters =
                      words.map((word) => word[0]).toList();

                  // Join the first letters to form the shortened text
                  String shortenedText = firstLetters.join('');

                  return shortenedText;
                }

                try {
                  String firmId =
                      '${shortenText(firmNameController.text).toUpperCase().replaceAll(' ', '')}${_firms.isNotEmpty ? _firms.last.id : 1 + 1}';

                  if (!context.mounted) return;

                  int result = await DatabaseHelper.instance.createFirm(
                    firmName: firmNameController.text.trim(),
                    firmId: firmId.toUpperCase().trim(),
                    gstin: firmGSTINContoller.text.toUpperCase().trim(),
                    phone: firmPhoneNoController.text.trim(),
                    address: firmAddressController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (result > 0) {
                    showAlert(context, 'Firm added to database.');
                  } else {
                    showAlert(context, 'Some error occurred!!!');
                  }
                } catch (e) {
                  showAlert(
                    context,
                    e.toString(),
                  );

                  return;
                }

                firmAddressController.clear();
                firmNameController.clear();
                firmGSTINContoller.clear();
                firmPhoneNoController.clear();
                passwordController.clear();
                firmIdController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}



//  String firmId =
//                       '${shortenText(firmNameController.text).toUpperCase().replaceAll(' ', '')}${_firms!.length + 1}';

//                   final firm = await db.query(
//                     'firms',
//                     where:
//                         'name = ? AND password = ? AND firmdId = ? AND gstin = ? AND phone = ? AND address = ?',
//                     whereArgs: [
//                       Firm(
//                           name: firmNameController.text.trim(),
//                           firmId: firmId.toUpperCase().trim(),
//                           gstin: firmGSTINContoller.text.toUpperCase().trim(),
//                           phone: firmPhoneNoController.text.trim(),
//                           address: firmAddressController.text.trim(),
//                           password: passwordController.text.trim()),
//                     ],
//                   );
//                   if (!context.mounted) return;

//                   if (firm.isNotEmpty) {
//                     showAlert(context, 'Welcome.');
//                   }