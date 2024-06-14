// Import necessary package for navigation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/consts/colors.dart';

class PatientList extends StatefulWidget {
  const PatientList({Key? key}) : super(key: key);

  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch appointments from Firestore for the current doctor
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('appointments')
                .where('appWith', isEqualTo: user.uid)
                .get();

        List<String> patientIds = querySnapshot.docs
            .map((doc) => doc['appForUser'] as String)
            .toList();

        // Fetch patient details using their IDs
        QuerySnapshot<Map<String, dynamic>> patientSnapshot =
            await FirebaseFirestore.instance
                .collection('user')
                .where(FieldPath.documentId, whereIn: patientIds)
                .get();

        setState(() {
          patients = patientSnapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print("Error fetching patients: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Patients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          patients.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No patients yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SizedBox(
                  height: 300, // Adjust the height as needed
                  child: ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patientName = patients[index]['name'] ?? 'Unknown';

                      return GestureDetector(
                        onTap: () {
                          // Navigate to patient details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailsPage(
                                patientData: patients[index],
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(patientName[0]),
                          ),
                          title: Text(patientName),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class PatientDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientDetailsPage({Key? key, required this.patientData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Patient Details',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        patientData['profileImageUrl'] ??
                            'https://via.placeholder.com/150'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    patientData['name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.phone, 'Phone', patientData['phone'] ?? 'Unknown'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.email, 'Email', patientData['email'] ?? 'Unknown'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.home, 'Address', patientData['address'] ?? 'Unknown'),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.cake, 'Date of Birth',
                    patientData['dob'] ?? 'Unknown'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.person, 'Gender', patientData['gender'] ?? 'Unknown'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
