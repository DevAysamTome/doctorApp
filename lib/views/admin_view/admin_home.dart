import 'package:flutter/material.dart';

class AdminHomeView extends StatelessWidget {
  final int numAppointments;
  final int numDoctors;
  final int numPatients;

  const AdminHomeView({
    super.key,
    required this.numAppointments,
    required this.numDoctors,
    required this.numPatients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Admin Control Panel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Number of Appointments: $numAppointments',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Number of Doctors: $numDoctors',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Number of Patients: $numPatients',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}
