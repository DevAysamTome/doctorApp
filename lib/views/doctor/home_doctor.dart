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
  int selectedIndex = 0; // Index of the currently selected screen
  List screenList = [
    const DoctorHomeScreen(), // Home screen for the doctor
    const AppointmentView(
      isDoctor: true,
    ), // Appointment view specific for the doctor
    const SettingsView(), // Settings view
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList.elementAt(selectedIndex), // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors
            .primaryColor, // Background color of the bottom navigation bar
        type: BottomNavigationBarType
            .fixed, // Fixed type to show all items without shifting
        fixedColor: Colors.white, // Selected item's icon color
        currentIndex: selectedIndex, // Current index of the selected item
        onTap: (value) {
          setState(() {
            selectedIndex =
                value; // Update the selected index when an item is tapped
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Home icon
            label: 'Home', // Text label for the home item
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Person icon (appointment)
            label: 'Appointment', // Text label for the appointment item
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Settings icon
            label: 'Settings', // Text label for the settings item
          ),
        ],
      ),
    );
  }
}
