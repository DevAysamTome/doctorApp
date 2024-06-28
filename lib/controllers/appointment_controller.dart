import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';

class AppointmentController extends GetxController {
  var isLoading = false.obs;
  var appDayController = TextEditingController();
  var appTimeController = TextEditingController();
  var appMobileController = TextEditingController();
  var appNameController = TextEditingController();
  var appMessageController = TextEditingController();

  bookAppointment(String docId, String docName, String userid, context) async {
    isLoading(true);
    var store = FirebaseFirestore.instance.collection('appointments').doc();
    await store.set({
      'appBy': FirebaseAuth.instance.currentUser?.uid,
      'appDay': appDayController.text,
      'appTime': appTimeController.text,
      'appMobile': appMobileController.text,
      'appName': appNameController.text,
      'appMsg': appMessageController.text,
      'appWith': docId,
      'appWithName': docName,
      'appForUser': userid,
    });

    isLoading(false);
    VxToast.show(context, msg: 'Appointment is booked successfully!');
    Get.back();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAppointment(
      bool isDoctor) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot;
        if (isDoctor) {
          // Fetch appointments where the doctor's ID matches
          querySnapshot = await FirebaseFirestore.instance
              .collection('appointments')
              .where('appWith', isEqualTo: user.uid)
              .get();
        } else {
          // Fetch appointments where the patient's ID matches
          querySnapshot = await FirebaseFirestore.instance
              .collection('appointments')
              .where('appForUser', isEqualTo: user.uid)
              .get();
        }
        return querySnapshot;
      } else {
        throw 'User not logged in';
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching appointments: $e");
      // ignore: use_rethrow_when_possible
      throw e; // Rethrow the error for the caller to handle
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();
      // You can also add any additional logic here, like updating UI or notifying users
    } catch (e) {
      // Handle any errors that occur during the cancellation process
    }
  }
}
