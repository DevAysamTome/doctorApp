import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/views/appointment_view/appointment_view.dart';
import 'package:test_app/views/doctor/pateintList.dart';
import 'package:test_app/views/doctor/searchbar.dart';
import 'package:test_app/views/doctor/upcomingappointments.dart';
import 'package:test_app/views/settings_view/settings_view.dart';
import 'add_appointment_view.dart';
import 'header.dart';
import 'home_doctor.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int selectedIndex = 0;
  List screenList = [
    const HomeDoctor(),
    const AppointmentView(
      isDoctor: true,
    ),
    const SettingsView(),
  ];

  Future<Map<String, dynamic>> getDoctorData() async {
    // Assuming you have a collection 'doctors' and a document with the doctor's ID
    String doctorId = 'doctorId'; // Replace with the actual doctor ID
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>; // Casting the data to a map
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppStyle.bold(title: "Doctor Profile", color: Colors.white),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.heightBox,
              const Header(),
              20.heightBox,
              const SearchBars(),
              20.heightBox,
              const UpcomingAppointments(),
              20.heightBox,
              const SizedBox(height: 10),
              20.heightBox,
              const PatientList(),
              20.heightBox,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorAppointmentScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
