import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/fonts.dart';
import 'package:test_app/consts/images.dart';
import 'package:test_app/controllers/auth_controllers.dart';
import 'package:test_app/controllers/settings_controller.dart';
import 'package:test_app/lists.dart';
import 'package:test_app/views/login_view/login_view.dart';

import 'change_password.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SettingsController to manage state
    var controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: AppStyle.normal(
          title: "Settings",
          size: AppSize.size18,
          color: Colors.white,
        ),
      ),
      body: Obx(
        // Observe changes in isLoading state from SettingsController
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // User info ListTile
                  ListTile(
                    leading:
                        CircleAvatar(child: Image.asset(AppAssets.imgSignup)),
                    title: AppStyle.bold(title: controller.username.value),
                    subtitle: AppStyle.normal(title: controller.email.value),
                  ),
                  const Divider(),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: settingsList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            // Handle list item taps
                            if (index == 0) {
                              // Navigate to ChangePasswordForm screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangePasswordForm(),
                                ),
                              );
                            } else if (index == 1) {
                              // Sign out user and navigate to LoginView screen
                              AuthController().signout();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginView(),
                                ),
                              );
                            }
                          },
                          leading: Icon(
                            settingsListIcons[index], // Icon for the list item
                            color: Colors.blue,
                          ),
                          title: AppStyle.bold(
                              title: settingsList[
                                  index]), // Title of the list item
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
