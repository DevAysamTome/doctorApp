// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:test_app/views/login_view/login_view.dart'; // Import the home screen

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Onboarding Image
            Image.asset(
              'assets/images/onboarding_image.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            // Onboarding Title
            const Text(
              'Find the Right Doctor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Onboarding Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Book appointments with ease and find the best doctors near you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Continue Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()), // Navigate to the home screen
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
