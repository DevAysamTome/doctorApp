import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../consts/consts.dart';
import 'doctor_profile_view/doctor_profile_view.dart';

class SearchView extends StatelessWidget {
  final String searchQuery;
  final String city;
  final String specialization;

  const SearchView({
    required this.searchQuery,
    required this.city,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('doctors');

    if (city.isNotEmpty) {
      query = query.where('docAddress', isEqualTo: city);
    }
    if (specialization.isNotEmpty) {
      query = query.where('docCategory', isEqualTo: specialization);
    }

    if (searchQuery.isNotEmpty) {
      String? searchQueryLowerCase = searchQuery.toString().capitalize;
      query =
          query.where('docName', isGreaterThanOrEqualTo: searchQueryLowerCase);
      query = query.where('docName', isLessThan: '${searchQueryLowerCase}z');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Results"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var data = snapshot.data?.docs;

            if (data == null || data.isEmpty) {
              return const Center(child: Text('No results found.'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data[index]['docName']),
                  subtitle: Text(data[index]['docCategory']),
                  onTap: () {
                    Get.to(() => DoctorProfileView(
                          doc: data[index],
                        ));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
