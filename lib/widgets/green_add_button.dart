import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GreenButton extends StatelessWidget {
  final VoidCallback function;
  final IconData icon;

  const GreenButton({
    super.key,
    required this.function,
    this.icon = FontAwesomeIcons.plus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      child: IconButton(
        onPressed: function,
        icon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
