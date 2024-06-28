// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/consts/colors.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  _DoctorAppointmentScreenState createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  DateTime selectedDate =
      DateTime.now(); // Initial selected date is set to current date
  List<String> selectedTimes = []; // List to store selected time slots
  final List<String> timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '03:00 PM',
    '03:30 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
  ]; // List of available time slots

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? doctorId = FirebaseAuth
      .instance.currentUser?.uid; // Current authenticated doctor's ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Add Appointments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.grey.shade200,
              title: Text("${selectedDate.toLocal()}"
                  .split(' ')[0]), // Display selected date
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                ); // Show date picker dialog

                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate =
                        pickedDate; // Update selected date if changed
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Time Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: selectedTimes
                      .contains(time), // Check if time slot is selected
                  selectedColor: AppColors.primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTimes.add(time); // Add selected time slot
                      } else {
                        selectedTimes.remove(time); // Remove selected time slot
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAppointments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Appointments',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAppointments() async {
    String date =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"; // Format selected date

    List<Map<String, dynamic>> appointments = selectedTimes.map((time) {
      return {'date': date, 'time': time, 'booked': false};
    }).toList(); // Create list of appointment maps with selected date, time, and initial booked status

    await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('appointments')
        .doc(date)
        .set(
            {'appointments_available': FieldValue.arrayUnion(appointments)},
            SetOptions(
                merge:
                    true)); // Save appointments to Firestore under doctor's collection

    setState(() {
      selectedTimes.clear(); // Clear selected times after saving
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointments saved successfully')));
  }
}
