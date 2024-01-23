import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:billx/pages/firms_page.dart';
import 'package:billx/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 2000,
      splash: Scaffold(
        body: Center(
          child: Card(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Image.asset('assets/logo/billx.png'),
            ),
          ),
        ),
      ),
      nextScreen: const FirmsPage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.leftToRightWithFade,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
