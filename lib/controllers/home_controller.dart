import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';

class HomeController extends GetxController {
  // Controller for search query input field
  var searchQueryController = TextEditingController();

  // Observable to track loading state
  var isLoading = false.obs;

  // Method to fetch the list of doctors from Firestore
  Future<QuerySnapshot<Map<String, dynamic>>> getDoctorList() async {
    // Get the list of doctors from the 'doctors' collection in Firestore
    var doctors = FirebaseFirestore.instance.collection('doctors').get();
    return doctors;
  }
}
