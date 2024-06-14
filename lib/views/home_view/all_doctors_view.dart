import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/views/doctor_profile_view/doctor_profile_view.dart';

class AllDoctorsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Doctors'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('doctors').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No doctors found'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> doctorData =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(doctorData['docName'] ?? ''),
                subtitle: Text(doctorData['docCategory'] ?? ''),
                onTap: () {
                  // Navigate to the DoctorProfileView with the doctor's document
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
