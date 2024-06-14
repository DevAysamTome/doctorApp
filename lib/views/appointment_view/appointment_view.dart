import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../consts/consts.dart';
import '../../controllers/appointment_controller.dart';
import '../appointment_details_view/appointment_details_view.dart';

class AppointmentView extends StatelessWidget {
  final bool isDoctor;

  const AppointmentView({Key? key, required this.isDoctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AppointmentController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Appointments",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: controller.getAppointment(isDoctor),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else {
            var data = snapshot.data?.docs;
            if (data == null || data.isEmpty) {
              return const Center(
                child: Text(
                  'No appointments found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      onTap: () {
                        Get.to(() => AppointmentDetailsView(doc: data[index]));
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Image.asset(AppAssets.imgSignup),
                      ),
                      title: Text(
                        !isDoctor
                            ? data[index]['appWithName']
                            : data[index]['appName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "${data[index]['appDay']} - ${data[index]['appTime']}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.teal.shade400,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
