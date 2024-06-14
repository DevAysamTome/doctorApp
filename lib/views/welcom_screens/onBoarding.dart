import 'package:flutter/material.dart';
import 'package:test_app/views/login_view/login_view.dart'; // Import the home screen

class OnboardingScreen extends StatelessWidget {
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
            SizedBox(height: 20),
            // Onboarding Title
            Text(
              'Find the Right Doctor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Onboarding Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Book appointments with ease and find the best doctors near you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 30),
            // Continue Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()), // Navigate to the home screen
                );
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
