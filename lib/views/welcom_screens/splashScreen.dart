// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:get/get.dart';
import 'package:test_app/views/welcom_screens/welcomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 4400), () {});
    Get.off(() =>
        const OnboardingScreen()); // Update this to navigate to your main screen
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RiveAnimation.asset(
          'assets/rocket_demo.riv',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
