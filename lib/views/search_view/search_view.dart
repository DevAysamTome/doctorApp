import 'dart:developer'; // For logging

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart'; // Importing constants for styling
import 'package:test_app/views/doctor_profile_view/doctor_profile_view.dart'; // Importing DoctorProfileView

class SearchView extends StatelessWidget {
  final String searchQuery; // The search query entered by the user
  const SearchView({super.key,  required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: AppStyle.bold(
          title: "Search Results",
          color: Colors.white,
          size: AppSize.size18,
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .where('docName', isGreaterThanOrEqualTo: searchQuery)
            .where('docName', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, show a loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // If there's an error fetching data, display an error message
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // If no data is found or the result is empty, display a message
            return const Center(
              child: Text("No doctors found"),
            );
          } else {
            // If data is successfully fetched, display the search results
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 170,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var doc = snapshot.data!.docs[index]; // Current document
                  
                  // Logging document data for debugging purposes
                  log(doc.data().toString());
                  
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the DoctorProfileView when a doctor is tapped
                      Get.to(() => DoctorProfileView(
                        doc: doc,
                      ));
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.bgDarkColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      height: 100,
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Displaying doctor's image
                          Container(
                            alignment: Alignment.center,
                            color: Colors.blue,
                            child: Image.asset(
                              AppAssets.imgSignup,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Displaying doctor's name
                          AppStyle.normal(title: doc['docName']),
                          // Displaying doctor's rating using VxRating widget
                          VxRating(
                            selectionColor: Colors.yellow,
                            onRatingUpdate: (value) {},
                            maxRating: 5,
                            count: 5,
                            value: double.parse(doc['docRating'].toString()),
                            stepInt: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
