import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/colors.dart';
import 'package:test_app/res/components/waiting_screen.dart';
import 'package:test_app/views/login.dart';
import 'DoctorListPage.dart';
import 'PatientListPage.dart';
import 'add_doctor_form.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  int _numAppointments = 0;
  int _numDoctors = 0;
  int _numPatients = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch number of appointments
      final appointmentQuery =
          await FirebaseFirestore.instance.collection('appointments').get();
      _numAppointments = appointmentQuery.docs.length;

      // Fetch number of doctors
      final doctorQuery =
          await FirebaseFirestore.instance.collection('doctors').get();
      _numDoctors = doctorQuery.docs.length;

      // Fetch number of patients
      final userQuery =
          await FirebaseFirestore.instance.collection('user').get();
      _numPatients = userQuery.docs.length;

      // Update the UI
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error, e.g., show a message to the user
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screenList = [
      _buildAdminHomeView(),
      const AddDoctorForm(),
      const DoctorListPage(),
      PatientListPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Control Panel',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        centerTitle: true, // Remove back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut(); // Sign out
              Get.to(const WaitingScreen()); // Navigate to login view
            },
          ),
        ],
      ),
      body: screenList.isNotEmpty
          ? IndexedStack(
              index: _selectedIndex,
              children: screenList,
            )
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            label: 'Admin Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: Colors.blue,
            ),
            label: 'Add Doctor',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              color: Colors.blue,
            ),
            label: 'Doctor List',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            label: 'Patient List',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildAdminHomeView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildStatisticCard(
            icon: Icons.event,
            title: 'Number of Appointments',
            value: _numAppointments.toString(),
          ),
          const SizedBox(height: 20),
          _buildStatisticCard(
            icon: Icons.people,
            title: 'Number of Doctors',
            value: _numDoctors.toString(),
          ),
          const SizedBox(height: 20),
          _buildStatisticCard(
            icon: Icons.people_outline,
            title: 'Number of Patients',
            value: _numPatients.toString(),
          ),
          const SizedBox(height: 40),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 40,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
