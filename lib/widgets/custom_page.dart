import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomPage extends StatelessWidget {
  final String title;
  final List<Widget> widget;
  final double boxheight;
  final VoidCallback onClose;

  const CustomPage({
    super.key,
    required this.title,
    required this.widget,
    this.boxheight = 800,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    FocusManager.instance.rootScope.onKey = null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            return;
          },
          iconSize: 150, // Adjust the size as needed
          icon: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, top: 3, bottom: 3, right: 0),
            child: Image.asset('assets/logo/billx.png'),
          ),
        ),
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              onClose();
            },
            icon: const Icon(
              FontAwesomeIcons.close,
              color: Colors.red,
              size: 38,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/IMG_20231229_154156336.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            // height: screenWidth < MediaQuery.of(context).size.width
            //     ? MediaQuery.of(context).size.height * 1
            //     : MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
          ),
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.8, // Adjust the multiplier as needed
              width: 600,
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(21.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: widget,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
