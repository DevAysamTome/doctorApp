import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  bool isDoctor = false;
  @override
  Future<void> onInit() async {
    isDoctor = await checkUserRole();
    getData = isDoctor ? getDoctorData() : getUserData();
    super.onInit();
  }

  var isLoading = false.obs;
  var currentUser = FirebaseAuth.instance.currentUser;
  var username = ''.obs;
  var email = ''.obs;
  Future? getData;

  Future<bool> checkUserRole() async {
    // Check if the current user exists and fetch user data
    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .doc(currentUser!.uid)
              .get();
      if (userSnapshot.exists) {
        return false; // User exists in 'user' collection
      } else {
        return true; // User does not exist in 'user' collection, assumed to be a doctor
      }
    } else {
      return false; // Default to user role if no user is logged in
    }
  }

  getUserData() async {
    isLoading(true);
    DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
        .instance
        .collection('user')
        .doc(currentUser!.uid)
        .get();
    var userData = user.data();
    username.value = userData!['name'] ?? "";
    email.value = currentUser!.email ?? '';
    isLoading(false);
  }

  getDoctorData() async {
    isLoading(true);
    DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
        .instance
        .collection('doctors')
        .doc(currentUser!.uid)
        .get();
    var userData = user.data();
    username.value = userData!['docName'] ?? "";
    email.value = currentUser!.email ?? '';
    isLoading(false);
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await currentUser!.updatePassword(newPassword);
      // Display success message or navigate to success view
      Get.snackbar("Success", "Password changed successfully");
    } catch (error) {
      // Display error message to user
      Get.snackbar("Error", "Failed to change password");
    }
  }
}
