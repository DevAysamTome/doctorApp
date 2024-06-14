import 'package:flutter/material.dart';
import 'package:test_app/views/doctor/pateintList.dart';
import 'package:test_app/views/settings_view/settings_view.dart';

import 'doctor_home_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
     const DoctorHomeScreen(), // Replace Header() with your home screen widget
    PatientList(), // Replace PatientList() with your patients screen widget
    const SettingsView(), // Replace SettingsScreen() with your settings screen widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
