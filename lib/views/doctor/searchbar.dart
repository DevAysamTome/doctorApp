// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchBars extends StatefulWidget {
  const SearchBars({super.key});

  @override
  _SearchBarsState createState() => _SearchBarsState();
}

class _SearchBarsState extends State<SearchBars> {
  String searchText = '';
  List<Map<String, dynamic>> searchResults = [];
  bool showResults = false;

  void _search(String value, String doctorId) async {
    setState(() {
      searchText = value;
    });
    if (value.isNotEmpty) {
      try {
        // Search appointments for the current doctor
        QuerySnapshot<Map<String, dynamic>> appointmentSnapshot =
            await FirebaseFirestore.instance
                .collection('appointments')
                .where('appWith', isEqualTo: doctorId)
                .get();

        // Filter appointments based on patient name
        List<Map<String, dynamic>> filteredAppointments = appointmentSnapshot
            .docs
            .map((doc) => doc.data())
            .where((appointment) => appointment['appName']
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()))
            .toList();

        setState(() {
          searchResults = filteredAppointments;
          showResults = true;
        });
      } catch (e) {
        print("Error searching: $e");
      }
    } else {
      setState(() {
        searchResults = [];
        showResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 80,
              child: TextField(
                onChanged: (value) {
                  // Call search function when text changes
                  _search(value, FirebaseAuth.instance.currentUser!.uid);
                },
                decoration: const InputDecoration(
                  hintText: 'Search patients',
                ),
              ),
            ),
            SizedBox(
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SearchResultsBottomSheet(
                          searchResults: searchResults,
                          showResults: showResults);
                    },
                  );
                },
                icon: const Icon(Icons.search),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SearchResultsBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final bool showResults;

  const SearchResultsBottomSheet(
      {super.key, required this.searchResults, required this.showResults});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search Results'),
          const SizedBox(height: 16.0),
          if (showResults)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  String patientName = searchResults[index]['appName'];
                  return ListTile(
                    title: Text(patientName),
                  );
                },
              ),
            )
          else
            const Text('No patients found.'),
        ],
      ),
    );
  }
}
