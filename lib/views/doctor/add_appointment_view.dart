import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/consts/colors.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  @override
  _DoctorAppointmentScreenState createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> selectedTimes = [];
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
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? doctorId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
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
            Text(
              'Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              tileColor: Colors.grey.shade200,
              title: Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select Time Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: selectedTimes.contains(time),
                  selectedColor: AppColors.primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTimes.add(time);
                      } else {
                        selectedTimes.remove(time);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAppointments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
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
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    List<Map<String, dynamic>> appointments = selectedTimes.map((time) {
      return {'date': date, 'time': time, 'booked': false};
    }).toList();

    await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('appointments')
        .doc(date)
        .set({'appointments_available': FieldValue.arrayUnion(appointments)},
            SetOptions(merge: true));

    setState(() {
      selectedTimes.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointments saved successfully')));
  }
}
