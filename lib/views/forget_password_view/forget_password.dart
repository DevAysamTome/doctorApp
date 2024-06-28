// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package
import 'package:test_app/consts/colors.dart'; // Custom colors from application constants

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email input
  bool _isLoading = false; // Flag to track loading state

  // Function to send password reset email
  void _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true; // Start loading state
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim()); // Send reset email
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            const EmailSentScreen(), // Navigate to EmailSentScreen on success
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Failed to send reset email')), // Show error message on failure
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  Navigator.of(context).pop(), // Back button to previous screen
            ),
            const SizedBox(height: 20),
            const Text('Forgot password',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)), // Screen title
            const SizedBox(height: 10),
            const Text(
                'Please enter your email to reset the password'), // Instruction text
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Your Email', // Email input field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _sendPasswordResetEmail, // Disable button during loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor:
                      AppColors.primaryColor, // Custom button color
                ),
                child: _isLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text(
                        'Reset Password', // Button text
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // App bar for EmailSentScreen
      body: Center(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.1), // Light blue background color
          ),
          child: const Icon(
            Icons.check,
            color: Colors.blue, // Blue check icon
            size: 50,
          ),
        ),
      ),
    );
  }
}
