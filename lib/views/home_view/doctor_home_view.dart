import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/controllers/appointment_controller.dart';
import 'package:test_app/controllers/auth_controllers.dart';
import 'package:test_app/views/appointment_details_view/appointment_details_view.dart';

class DoctorHomeView extends StatelessWidget {
  final bool isDoctor;

  const DoctorHomeView({super.key, this.isDoctor = false});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AppointmentController());

    return Scaffold(
      appBar: AppBar(
        title: AppStyle.bold(
          title: "Appointments",
          color: Colors.white,
          size: AppSize.size18,
        ),
        actions: [
          IconButton(
            onPressed: () {
              AuthController()
                  .signout(); // Log out when the power button is pressed
            },
            icon: const Icon(Icons.power_settings_new_rounded),
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: controller
            .getAppointment(isDoctor), // Fetch appointments based on user type
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Display loading indicator while waiting for data
            );
          } else {
            var data = snapshot.data?.docs;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: data?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Get.to(() => AppointmentDetailsView(
                            doc: data[
                                index], // Navigate to appointment details view
                          ));
                    },
                    leading: CircleAvatar(
                      child: Image.asset(
                          AppAssets.imgSignup), // Display avatar image
                    ),
                    title: AppStyle.bold(
                      title: data![index][!isDoctor
                          ? 'appWithName'
                          : 'appName'], // Display patient or doctor's name based on user type
                    ),
                    subtitle: AppStyle.normal(
                      title:
                          "${data[index]['appDay']} - ${data[index]['appTime']}", // Display appointment day and time
                      color: AppColors.textColor.withOpacity(0.5),
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
