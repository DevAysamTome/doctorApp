import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/views/doctor_profile_view/doctor_profile_view.dart';

class AllDoctorsView extends StatelessWidget {
  const AllDoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Doctors'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        // Fetching the collection of 'doctors' from Firestore
        future: FirebaseFirestore.instance.collection('doctors').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // While data is loading, display a progress indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there's an error, display an error message
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If no data is available or no documents are found, display a message
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No doctors found'));
          }
          // Once data is available, build a ListView of doctors
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // Extract data from each document
              Map<String, dynamic> doctorData =
                  document.data() as Map<String, dynamic>;
              // Display each doctor as a ListTile
              return ListTile(
                title: Text(doctorData['docName'] ?? ''),
                subtitle: Text(doctorData['docCategory'] ?? ''),
                onTap: () {
                  // Navigate to the DoctorProfileView with the selected doctor's document
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfileView(doc: document),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
