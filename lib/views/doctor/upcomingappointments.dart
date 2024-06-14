import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpcomingAppointments extends StatefulWidget {
  UpcomingAppointments({Key? key}) : super(key: key);

  @override
  _UpcomingAppointmentsState createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch appointments from Firestore for the current doctor
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('appointments')
                .where('appWith', isEqualTo: user.uid)
                .get();

        setState(() {
          appointments = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Upcoming Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        appointments.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No upcoming appointments yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  // Extract appointment data
                  String appointmentName = appointments[index]['appName'];
                  String appointmentTime = appointments[index]['appTime'];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '$appointmentName - $appointmentTime',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
