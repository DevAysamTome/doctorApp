import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/controllers/home_controller.dart';
import 'package:test_app/lists.dart';
import 'package:test_app/res/components/custom_textfield.dart';
import '../../consts/consts.dart';
import '../category_details_view/category_details_view.dart';
import '../doctor_profile_view/doctor_profile_view.dart';
import '../search_view.dart';
import 'all_doctors_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> _cities = [];
  List<String> _specializations = [];
  String? _selectedCity;
  String? _selectedSpecialization;

  HomeController _controller = Get.put(HomeController());
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchSpecializations();
  }

  @override
  void dispose() {
    _searchQueryController.dispose(); // Dispose text editing controller
    super.dispose();
  }

  Future<void> _fetchCities() async {
    try {
      QuerySnapshot citySnapshot =
          await FirebaseFirestore.instance.collection('doctors').get();

      if (!mounted) return; // Check if widget is still mounted

      Set<String> uniqueCities = <String>{};
      for (var doc in citySnapshot.docs) {
        uniqueCities.add(doc['docAddress'] as String);
      }

      setState(() {
        _cities = uniqueCities.toList();
      });
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<void> _fetchSpecializations() async {
    try {
      QuerySnapshot specializationSnapshot =
          await FirebaseFirestore.instance.collection('doctors').get();

      if (!mounted) return; // Check if widget is still mounted

      Set<String> uniqueSpecializ = <String>{};
      for (var doc in specializationSnapshot.docs) {
        uniqueSpecializ.add(doc['docCategory'] as String);
      }

      setState(() {
        _specializations = uniqueSpecializ.toList();
      });
    } catch (e) {
      print('Error fetching specializations: $e');
    }
  }

  void _showAllDoctors() {
    // Navigate to the page containing all doctors
    Get.to(() => AllDoctorsView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome User"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                textController: _searchQueryController,
                hint: "Search Doctor",
                borderColor: Colors.blue, // Adjusted border color
                textColor: Colors.black, // Adjusted text color
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String?>(
                      isExpanded: true, // Expanded dropdown
                      value: _selectedCity,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("City Filter"),
                        ),
                        ..._cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String?>(
                      isExpanded: true, // Expanded dropdown
                      value: _selectedSpecialization,
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialization = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Specialty Filter"),
                        ),
                        ..._specializations.map((specialization) {
                          return DropdownMenuItem(
                            value: specialization,
                            child: Text(specialization),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      Get.to(() => SearchView(
                            searchQuery:
                                _searchQueryController.text.toLowerCase(),
                            city: _selectedCity ?? '',
                            specialization: _selectedSpecialization ?? '',
                          ));
                    },
                    icon: const Icon(Icons.search),
                    color: Colors.blue, // Adjusted icon color
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() =>
                            CategoryDetailsView(catName: iconTitleList[index]));
                      },
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            Image.asset(
                              iconList[index],
                              width: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 5),
                            AppStyle.normal(
                                title: iconTitleList[index],
                                color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: 4,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Some Doctors",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: AppSize.size18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DoctorGridView(
                controller: _controller,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: _showAllDoctors,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "View All",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorGridView extends StatelessWidget {
  final HomeController controller;

  const DoctorGridView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: controller.getDoctorList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching data'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No doctors found'),
          );
        }

        var data = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            // English value from Firestore
            String englishCategory = data[index]['docCategory'];

            // Define Arabic translations based on English values
            String arabicCategory = '';
            switch (englishCategory) {
              case 'Dentist':
                arabicCategory = 'طبيب اسنان';
                break;
              case 'Ear and throat':
                arabicCategory = 'طبيب اذن وحنجرة';
                break;
              case 'Pediatrician':
                arabicCategory = 'طبيب اطفال';
                break;
              case 'Nerves':
                arabicCategory = 'طبيب اعصاب';
                break;
              // Add more cases as needed for other categories
              default:
                arabicCategory = 'تصنيف غير معروف';
                break;
            }

            return GestureDetector(
              onTap: () {
                Get.to(() => DoctorProfileView(
                      doc: data[index],
                    ));
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppColors.bgDarkColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(8),
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        color: Colors.blue,
                        child: Image.asset(
                          AppAssets.imgSignup,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AppStyle.normal(
                        title: data[index]['docName'],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        englishCategory,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: AppSize.size16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        arabicCategory, // Display Arabic translation here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppSize.size16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: 4,
        );
      },
    );
  }
}
