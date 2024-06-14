import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/controllers/auth_controllers.dart';
import '../../controllers/home_controller.dart';
import '../../lists.dart';
import '../../res/components/custom_textfield.dart';
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

  final TextEditingController _searchQueryController = TextEditingController();
  final HomeController _controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    // Fetch cities and specializations from Firebase
    _fetchCities();
    _fetchSpecializations();
  }

  Future<void> _fetchCities() async {
    QuerySnapshot citySnapshot =
        await FirebaseFirestore.instance.collection('doctors').get();

    Set<String> uniqueCities = <String>{};
    for (var doc in citySnapshot.docs) {
      uniqueCities.add(doc['docAddress'] as String);
    }

    setState(() {
      _cities = uniqueCities.toList();
    });
  }

  Future<void> _fetchSpecializations() async {
    QuerySnapshot specializationSnapshot =
        await FirebaseFirestore.instance.collection('doctors').get();

    Set<String> uniqueSpecializ = <String>{};
    for (var doc in specializationSnapshot.docs) {
      uniqueSpecializ.add(doc['docCategory'] as String);
    }

    void setState(fn) {
      if (mounted) {
        super.setState(fn);
      }
    }

    setState(() {
      _specializations = uniqueSpecializ.toList();
    });
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
                height: 90,
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
              FutureBuilder<QuerySnapshot>(
                future: _controller.getDoctorList(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var data = snapshot.data?.docs;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
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
                            height: 200,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    color: Colors.blue,
                                    child: Image.asset(
                                      AppAssets.imgSignup,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  AppStyle.normal(
                                      title: data![index]['docName']),
                                  AppStyle.normal(
                                      title: data[index]['docCategory'],
                                      color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: data?.length,
                    );
                  }
                },
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
