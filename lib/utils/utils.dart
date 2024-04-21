import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';

const backgroundColor = Color.fromARGB(255, 0, 0, 0);
const primaryColor = Color.fromARGB(94, 68, 137, 255);
const secondaryColor = Color.fromARGB(33, 158, 158, 158);
const lightGreyText = Color.fromARGB(255, 39, 39, 39);
const actionColor = Color.fromARGB(255, 229, 115, 115);

noDataIcon() {
  return const Center(
    child: Icon(
      Icons.cancel,
      color: Color.fromARGB(176, 50, 49, 48),
      size: 56,
    ),
  );
}

showDownAlert(context, text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text.toString()),
    ),
  );
}

showAlert(BuildContext context, text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Alert!!!"),
        content: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text(
              "OK",
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

String hashPassword(String password) {
  final encodedPassword = utf8.encode(password);
  return sha256.convert(encodedPassword).toString();
}
