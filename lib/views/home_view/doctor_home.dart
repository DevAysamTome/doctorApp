import 'package:flutter/material.dart';
import 'package:test_app/views/home_view/doctor_home_view.dart';

import '../appointment_view/appointment_view.dart';
import '../settings_view/settings_view.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  bool isDoctor = true;
  int selectedIndex = 0;
  List<Widget> screenList = [
    const DoctorHomeView(), // Home view for doctor
    const AppointmentView(isDoctor: true), // Appointment view for doctor
    const SettingsView(), // Settings view
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList.elementAt(selectedIndex), // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        // Bottom navigation bar for navigation between screens
        unselectedItemColor: Colors.white.withOpacity(0.5),
        selectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          color: Colors.white,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.blue,
        ),
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex, // Index of the currently selected screen
        onTap: (value) {
          setState(() {
            selectedIndex = value; // Update selected index when tab is tapped
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"), // Home tab
          BottomNavigationBarItem(
              icon: Icon(Icons.book), label: "Appointment"), // Appointment tab
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"), // Settings tab
        ],
      ),
    );
  }
}
