import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  final Function onConfirm;
  final Function onCancel;

  const DeleteIconButton(
      {super.key, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.black,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete this item?"),
              actions: [
                TextButton(
                  onPressed: () {
                    onCancel();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
