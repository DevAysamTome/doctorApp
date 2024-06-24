import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/consts/fonts.dart';
import 'package:test_app/consts/images.dart';
import 'package:test_app/consts/strings.dart';
import 'package:test_app/controllers/auth_controllers.dart';
import 'package:test_app/res/components/custom_button.dart';
import 'package:test_app/views/signup_view/phoneOTP.dart';
import 'package:intl/intl.dart';

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateOfBirthController = TextEditingController();

  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.imgSignup,
                  width: 220,
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.signupNow,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSize.size18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppStrings.fullname,
                        ),
                        controller: controller.fullnameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Full Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppStrings.email,
                        ),
                        controller: controller.emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is required';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppStrings.password,
                        ),
                        controller: controller.passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Address',
                        ),
                        controller: controller.addressController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _dateOfBirthController,
                        decoration: InputDecoration(
                          hintText: 'Date of Birth',
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Date of Birth is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Gender',
                        ),
                        items: ['Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          controller.gender.value = newValue!;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Gender is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        buttonText: AppStrings.signup,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            bool emailExists = await checkEmailExists(
                                controller.emailController.text);
                            if (emailExists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Email already exists')),
                              );
                            } else {
                              // Navigate to PhoneOTPVerification screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PhoneOTPVerification(
                                    fullname:
                                        controller.fullnameController.text,
                                    email: controller.emailController.text,
                                    password:
                                        controller.passwordController.text,
                                    address: controller.addressController.text,
                                    dateOfBirth: _dateOfBirthController.text,
                                    gender: controller.gender.value,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.alreadyHaveAccount),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Text(
                              AppStrings.login,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
