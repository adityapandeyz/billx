import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool isPass;
  final bool autoFocus;
  final void Function(String)? onChanged;

  const CustomTextfield({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.isPass = false,
    this.onChanged,
    this.autoFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 440,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        autofocus: autoFocus,
        obscureText: isPass,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
