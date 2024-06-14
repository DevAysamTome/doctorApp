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
  List screenList = [
    const DoctorHomeView(),
    const AppointmentView(
      isDoctor: true,
    ),
    const SettingsView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
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
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.book), label: "Appointment"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ]),
    );
  }
}
