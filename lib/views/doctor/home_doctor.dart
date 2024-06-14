import 'package:flutter/material.dart';
import 'package:test_app/views/settings_view/settings_view.dart';
import '../../consts/colors.dart';
import '../appointment_view/appointment_view.dart';
import 'doctor_home_view.dart';

class HomeDoctor extends StatefulWidget {
  const HomeDoctor({super.key});

  @override
  State<HomeDoctor> createState() => _HomeDoctorState();
}

class _HomeDoctorState extends State<HomeDoctor> {
  int selectedIndex = 0;
  List screenList = [
    const DoctorHomeScreen(),
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
        backgroundColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
