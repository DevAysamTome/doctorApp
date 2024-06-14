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
  const SettingsView({Key? key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(SettingsController());
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: AppStyle.normal(
            title: "Settings", size: AppSize.size18, color: Colors.white),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
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
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordForm(),
                                ),
                              );
                            } else if (index == 1) {
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
                            settingsListIcons[index],
                            color: Colors.blue,
                          ),
                          title: AppStyle.bold(title: settingsList[index]),
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
