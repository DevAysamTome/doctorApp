import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Map<String, dynamic>? doctorData;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('doctors')
                .doc(user.uid)
                .get();
        setState(() {
          doctorData = snapshot.data();
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching doctor data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const CircleAvatar(
          radius: 30,
          // Add a profile picture asset or fetch from doctorData
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (doctorData != null) ...[
              Text(
                'Welcome, ${doctorData?['docName']}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Have a nice day!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ] else ...[
              // Placeholder widgets when data is loading
              const CircularProgressIndicator(), // You can replace this with any loading indicator
            ],
          ],
        ),
      ],
    );
  }
}
