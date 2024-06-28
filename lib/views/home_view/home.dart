// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:test_app/views/appointment_view/appointment_view.dart';
import 'package:test_app/views/category_view/category_view.dart';
import 'package:test_app/views/home_view/doctor_home_view.dart';
import 'package:test_app/views/home_view/home_view.dart';
import 'package:test_app/views/home_view/map/map_screen.dart';
import 'package:test_app/views/settings_view/settings_view.dart';

class Home extends StatefulWidget {
  final bool isDoctor;

  const Home({super.key, required this.isDoctor});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  // List of screens for non-doctor users
  List<Widget> screenList = [
    const HomeView(),              // Home screen
    const AppointmentView(isDoctor: false),  // Appointments screen
    const MapScreen(),             // Explore screen
    const CategoryView(),          // Specialties screen
    const SettingsView(),          // Settings screen
  ];

  // List of screens for doctor users
  List<Widget> doctorList = [
    const DoctorHomeView(),        // Doctor home screen
    const AppointmentView(isDoctor: true),   // Doctor appointments screen
    const CategoryView(),          // Specialties screen
    const SettingsView(),          // Settings screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.isDoctor ? doctorList[selectedIndex] : screenList[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.blue),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Appointment"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Specialties"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
