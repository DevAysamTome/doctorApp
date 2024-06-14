import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/views/appointment_view/appointment_view.dart';
import 'package:test_app/views/category_view/category_view.dart';
import 'package:test_app/views/home_view/doctor_home_view.dart';
import 'package:test_app/views/home_view/home_view.dart';
import 'package:test_app/views/home_view/map/map_screen.dart';
import 'package:test_app/views/settings_view/settings_view.dart';

class Home extends StatefulWidget {
  final bool isDoctor;

  const Home({Key? key, required this.isDoctor}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  List screenList = [
    HomeView(),
    const AppointmentView(
      isDoctor: false,
    ),
    MapScreen(),
    CategoryView(),
    const SettingsView(),
  ];
  List DoctorList = [
    DoctorHomeView(),
    const AppointmentView(
      isDoctor: true,
    ),
    CategoryView(),
    const SettingsView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !widget.isDoctor
          ? screenList.elementAt(selectedIndex)
          : DoctorList.elementAt(selectedIndex),
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
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Explore"),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: "Specialties"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ]),
    );
  }
}
