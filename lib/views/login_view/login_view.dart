import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/views/forget_password_view/forget_password.dart';
import 'package:test_app/views/login.dart';
import '../../consts/fonts.dart';
import '../../consts/images.dart';
import '../../consts/strings.dart';
import '../../controllers/auth_controllers.dart';
import '../../res/components/custom_button.dart';
import '../../res/components/custom_textfield.dart';
import '../admin_view/admin_view.dart';
import '../doctor/home_doctor.dart';
import '../home_view/doctor_home_view.dart';
import '../home_view/home.dart';
import '../signup_view/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  var isDoctor = false;

  Future<bool> _isDoctorByEmail(String email) async {
    final doctorsCollection = FirebaseFirestore.instance.collection('doctors');
    final querySnapshot =
        await doctorsCollection.where('docEmail', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  bool isHidden = true;

  void togglePasswordView() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  void showNoDoctorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content:
              const Text("There is no doctor with this data, please try again"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showNoPatientDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text(
              "There is no patient with this data, please try again"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
                  AppAssets.imgDoctor,
                  width: 400,
                ),
                const SizedBox(height: 10),
                AppStyle.bold(
                    title: AppStrings.welcomeBack,
                    size: AppSize.size34,
                    weight: FontWeight.w800),
                AppStyle.normal(
                    title: AppStrings.weAreExcited, size: AppSize.size18),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Form(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.passwordController,
                        obscureText: isHidden,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffix: IconButton(
                            onPressed: togglePasswordView,
                            icon: Icon(
                              !isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        value: isDoctor,
                        onChanged: (newValue) {
                          if (controller.emailController.text.isNotEmpty ||
                              controller.passwordController.text.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Alert"),
                                  content: const Text(
                                      "Please clear email and password fields before changing the sign-in type."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              isDoctor = newValue;
                            });
                          }
                        },
                        title: Text(
                            "Sign in as a ${isDoctor ? 'doctor' : 'patient'}"),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Get.offAll(() => ForgotPasswordScreen());
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppStrings.forgetPassword,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        buttonText: AppStrings.login,
                        onTap: () async {
                          try {
                            // ignore: unused_local_variable
                            final credential =
                                await _auth.signInWithEmailAndPassword(
                              email: controller.emailController.text,
                              password: controller.passwordController.text,
                            );
                            // Check if the user is trying to sign in as a doctor with a patient email
                            if (isDoctor &&
                                !(await _isDoctorByEmail(
                                    controller.emailController.text))) {
                              Get.to(() => const LoginView());
                              showNoDoctorDialog();
                              return;
                            }
                            // Check if the user is trying to sign in as a patient with a doctor email
                            else if (!isDoctor &&
                                (await _isDoctorByEmail(
                                    controller.emailController.text))) {
                              Get.to(() => const LoginView());
                              showNoPatientDialog();
                              return;
                            }
                            // Proceed with regular login if no errors are found
                            if (isDoctor) {
                              Get.to(() => const HomeDoctor());
                            } else {
                              Get.to(() => Home(isDoctor: isDoctor));
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              Get.snackbar(
                                  "Error", "No user found with this email.",
                                  snackPosition: SnackPosition.BOTTOM);
                            } else if (e.code == 'wrong-password') {
                              Get.snackbar("Error", "Wrong password provided.",
                                  snackPosition: SnackPosition.BOTTOM);
                            } else {
                              Get.snackbar("Error", e.message!,
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          } catch (e) {
                            Get.snackbar(
                                "Error", "An unexpected error occurred.",
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.dontHaveAccount),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const SignupView());
                            },
                            child: AppStyle.bold(title: AppStrings.signup),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // Navigate to the admin login page
                          // Replace AdminLoginView with your actual admin login page
                          Get.to(() => LoginScreen());
                        },
                        child: const Text("Sign in as an admin"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
