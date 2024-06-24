import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/lists.dart';
import 'package:test_app/views/category_details_view/category_details_view.dart';

class CategoryView extends StatefulWidget {
  CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  int _numSpeicalPediatrician = 0;
  int _numSpeicalNerves = 0;
  int _numSpeicalDentist = 0;
  int _numSpeicalEar = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final counts = await Future.wait([
        _fetchCategoryCount('Pediatrician'),
        _fetchCategoryCount('Nerves'),
        _fetchCategoryCount('Dentist'),
        _fetchCategoryCount('Ear and throat'),
      ]);

      setState(() {
        _numSpeicalPediatrician = counts[0];
        _numSpeicalNerves = counts[1];
        _numSpeicalDentist = counts[2];
        _numSpeicalEar = counts[3];
      });
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error, e.g., show a message to the user
    }
  }

  Future<int> _fetchCategoryCount(String category) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('docCategory', isEqualTo: category)
        .get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final categoryCounts = {
      'Pediatrician': _numSpeicalPediatrician,
      'Nerves': _numSpeicalNerves,
      'Dentist': _numSpeicalDentist,
      'Ear and throat': _numSpeicalEar,
    };

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: AppStyle.normal(
            title: "Specialties", size: AppSize.size18, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 170),
          itemCount: iconList.length,
          itemBuilder: (BuildContext context, int index) {
            String category = iconTitleList[index];
            int count = categoryCounts[category] ?? 0;

            return GestureDetector(
              onTap: () {
                Get.to(() => CategoryDetailsView(
                      catName: category,
                    ));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        iconList[index],
                        width: 60,
                        color: Colors.white,
                      ),
                    ),
                    30.heightBox,
                    AppStyle.bold(
                        title: category,
                        color: Colors.white,
                        size: AppSize.size16),
                    AppStyle.normal(
                        title: "$count specialities",
                        color: Colors.white.withOpacity(0.5),
                        size: AppSize.size12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
