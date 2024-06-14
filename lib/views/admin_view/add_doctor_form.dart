import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/consts/colors.dart';

class AddDoctorForm extends StatefulWidget {
  const AddDoctorForm({Key? key});

  @override
  _AddDoctorFormState createState() => _AddDoctorFormState();
}

class _AddDoctorFormState extends State<AddDoctorForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  String? _selectedCity;
  String? _selectedSpecialty;

  final List<String> cities = ['Tulkarm', 'Jenin', 'Nablus', 'Ramallah'];
  final List<String> specialties = [
    'Dentist',
    'Ear and throat',
    'Pediatrician',
    'Nerves'
  ];

  Future<void> _addDoctor() async {
    try {
      // Step 1: Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Step 2: Add doctor details to Firestore
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .set({
        'docName': _nameController.text,
        'docEmail': _emailController.text,
        'docAddress': _selectedCity,
        'docCategory': _selectedSpecialty,
        'docPhone': _phoneController.text,
        'docDesc': _descController.text,
        'docid': userCredential.user!.uid,
        'docLat': _latController.text,
        'docLong': _longController.text,
        'docRatign': 0
      });

      // Clear the text fields after adding the doctor
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _descController.clear();
      _latController.clear();
      _longController.clear();
      _selectedCity = null;
      _selectedSpecialty = null;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Doctor added successfully'),
      ));
    } catch (e) {
      print('Error adding doctor: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add doctor. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Doctor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Text(
              'Select City',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              onChanged: (newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Specialty',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              onChanged: (newValue) {
                setState(() {
                  _selectedSpecialty = newValue;
                });
              },
              items: specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _latController,
              decoration: InputDecoration(
                labelText: 'Lat for Clinic',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _longController,
              decoration: InputDecoration(
                labelText: 'Long for Clinic',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.1, // Flexible height
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addDoctor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add Doctor',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
