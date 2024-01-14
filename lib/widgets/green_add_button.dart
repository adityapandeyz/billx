import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GreenAddButton extends StatelessWidget {
  final VoidCallback function;

  const GreenAddButton({
    super.key,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      child: IconButton(
        onPressed: function,
        icon: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
