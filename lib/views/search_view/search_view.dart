import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/views/doctor_profile_view/doctor_profile_view.dart';

class SearchView extends StatelessWidget {
  final String searchQuery;
  const SearchView({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: AppStyle.bold(
            title: "Search Results", color: Colors.white, size: AppSize.size18),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('doctors').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 170,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    var doc = snapshot.data!.docs[index];
                    log(doc.data().toString());
                    return !(doc['docName'].toString().toLowerCase())
                            .contains(searchQuery.toLowerCase())
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () {
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
                                  Container(
                                    alignment: Alignment.center,
                                    color: Colors.blue,
                                    child: Image.asset(
                                      AppAssets.imgSignup,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  5.heightBox,
                                  AppStyle.normal(title: doc['docName']),
                                  VxRating(
                                    selectionColor: Colors.yellow,
                                    onRatingUpdate: (value) {},
                                    maxRating: 5,
                                    count: 5,
                                    value: double.parse(
                                        doc['docRating'].toString()),
                                    stepInt: true,
                                  ),
                                ],
                              ),
                            ));
                  }),
            );
          }
        },
      ),
    );
  }
}
