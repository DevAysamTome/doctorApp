import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';

class HomeController extends GetxController {
  var searchQueryController = TextEditingController();
  var isLoading = false.obs;

  Future<QuerySnapshot<Map<String, dynamic>>> getDoctorList() async {
    var doctors = FirebaseFirestore.instance.collection('doctors').get();
    return doctors;
  }
}
