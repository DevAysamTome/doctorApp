// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/consts/colors.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<DocumentSnapshot> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  // Fetch patients data from Firestore
  Future<void> _fetchPatients() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      setState(() {
        patients = querySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient List',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? const Center(
                  child: Text(
                    'No patients found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient =
                        patients[index].data() as Map<String, dynamic>;
                    final patientName = patient['name'] ?? 'Unknown';
                    final patientEmail = patient['email'] ?? 'No email';
                    final profileImageUrl = patient['profileImageUrl'] ??
                        'https://via.placeholder.com/150';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl),
                          radius: 30,
                        ),
                        title: Text(
                          patientName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(patientEmail),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigate to patient details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PatientDetailsPage(patientData: patient),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class PatientDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const PatientDetailsPage({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                          'https://via.placeholder.com/150',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    patientData['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                    patientData['dateOfBirth'] ?? 'Unknown'),
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

  // Helper method to build an information row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
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
