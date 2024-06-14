import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/consts/colors.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({Key? key}) : super(key: key);

  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  bool _isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final doctorsQuery =
          await FirebaseFirestore.instance.collection('doctors').get();
      setState(() {
        _doctors = doctorsQuery.docs;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Doctor List',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildDoctorList(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDoctorList() {
    return ListView.builder(
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              doctor['docName'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(doctor['docCategory'] ?? ''),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _confirmDeleteDoctor(context, doctor);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteDoctor(BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> doctor) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text(
              "Are you sure you want to delete this doctor and all associated appointments?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, do not delete
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes, delete
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      _deleteDoctorAndAppointments(doctor, context);
    }
  }

  Future<void> _deleteDoctorAndAppointments(
      QueryDocumentSnapshot<Map<String, dynamic>> doctor,
      BuildContext context) async {
    try {
      // Delete all appointments associated with the doctor
      final appointmentsQuery = await FirebaseFirestore.instance
          .collection('appointments')
          .where('appWith', isEqualTo: doctor.id)
          .get();

      for (final appointment in appointmentsQuery.docs) {
        await appointment.reference.delete();
      }

      // Delete the doctor
      await doctor.reference.delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Doctor and associated appointments deleted')),
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting doctor: $error')),
      );
    }
  }
}
