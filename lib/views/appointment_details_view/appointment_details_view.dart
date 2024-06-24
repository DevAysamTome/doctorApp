import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/colors.dart';
import '../../controllers/appointment_controller.dart';

class AppointmentDetailsView extends StatelessWidget {
  final DocumentSnapshot doc;

  const AppointmentDetailsView({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AppointmentController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          doc['appWithName'],
          style: const TextStyle(
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
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    Icons.calendar_today, "Appointment Day", doc['appDay']),
                const SizedBox(height: 10),
                _buildDetailRow(
                    Icons.access_time, "Appointment Time", doc['appTime']),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.phone, "Mobile Number", doc['appMobile']),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.person, "Full Name", doc['appName']),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.message, "Message", doc['appMsg']),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    bool confirmCancellation = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Cancel Appointment"),
                        content: const Text(
                            "Are you sure you want to cancel this appointment?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                  false); // Return false when cancel button is pressed
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                  true); // Return true when yes button is pressed
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    );

                    if (confirmCancellation == true) {
                      await controller.cancelAppointment(doc.id);
                      Get.back(); // Go back to previous screen after cancellation
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Cancel Appointment",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 24),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
