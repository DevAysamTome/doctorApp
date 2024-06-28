// Import necessary packages
// ignore_for_file: library_private_types_in_public_api, avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../consts/colors.dart';

class PatientList extends StatefulWidget {
  const PatientList({super.key});

  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  List<Map<String, dynamic>> patients = []; // List to store patient data

  @override
  void initState() {
    super.initState();
    _fetchPatients(); // Fetch patients when the widget initializes
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

        // Fetch patient details using their IDs from the 'user' collection
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
                          // Navigate to patient details page when tapped
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
                            child: Text(patientName[
                                0]), // Display first letter of patient's name
                          ),
                          title: Text(patientName), // Display patient's name
                          trailing: const Icon(Icons
                              .arrow_forward_ios), // Arrow icon for navigation indication
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
  final Map<String, dynamic> patientData; // Data of the selected patient

  const PatientDetailsPage({super.key, required this.patientData});

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
                    backgroundImage: NetworkImage(patientData[
                            'profileImageUrl'] ??
                        'https://via.placeholder.com/150'), // Display patient's profile image or placeholder if not available
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    patientData['name'] ??
                        'Unknown', // Display patient's name or 'Unknown' if not available
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.phone,
                    'Phone',
                    patientData['phone'] ??
                        'Unknown'), // Display patient's phone number or 'Unknown' if not available
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.email,
                    'Email',
                    patientData['email'] ??
                        'Unknown'), // Display patient's email or 'Unknown' if not available
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.home,
                    'Address',
                    patientData['address'] ??
                        'Unknown'), // Display patient's address or 'Unknown' if not available
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.cake,
                    'Date of Birth',
                    patientData['dob'] ??
                        'Unknown'), // Display patient's date of birth or 'Unknown' if not available
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.person,
                    'Gender',
                    patientData['gender'] ??
                        'Unknown'), // Display patient's gender or 'Unknown' if not available
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
        Icon(icon,
            color: AppColors.primaryColor), // Icon for the information category
        const SizedBox(width: 10),
        Text(
          '$label: ', // Label for the information category
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value, // Value of the information category
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
