
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
              title: "Appointments", color: Colors.white, size: AppSize.size18),
          actions: [
            IconButton(
                onPressed: () {
                  AuthController().signout();
                },
                icon: const Icon(Icons.power_settings_new_rounded)),
          ],
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: controller.getAppointment(isDoctor),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
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
                              doc: data[index],
                            ));
                      },
                      leading: CircleAvatar(
                        child: Image.asset(AppAssets.imgSignup),
                      ),
                      title: AppStyle.bold(
                          title: data![index]
                              [!isDoctor ? 'appWithName' : 'appName']),
                      subtitle: AppStyle.normal(
                          title:
                              "${data[index]['appDay']} - ${data[index]['appTime']}",
                          color: AppColors.textColor.withOpacity(0.5)),
                    );
                  },
                ),
              );
            }
          },
        ));
  }
}
