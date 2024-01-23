import 'package:flutter/material.dart';

class CustomSquare extends StatelessWidget {
  final IconData icons;
  final String title;
  final VoidCallback ontap;
  const CustomSquare({
    super.key,
    required this.icons,
    required this.title,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 200,
        width: 200,
        padding: const EdgeInsets.all(8),
        color: Colors.red[300],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            Icon(
              icons,
              size: 50,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
