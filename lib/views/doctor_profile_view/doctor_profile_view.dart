import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:test_app/consts/consts.dart';
import 'package:test_app/views/book_appointment_view/book_appointment_view.dart';
import 'package:test_app/res/components/custom_button.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DoctorProfileView extends StatefulWidget {
  final DocumentSnapshot doc;

  const DoctorProfileView({super.key, required this.doc});

  @override
  _DoctorProfileViewState createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  var isLoading = false.obs;
  var currentUser = FirebaseAuth.instance.currentUser;
  double? rating;
  TextEditingController feedbackController = TextEditingController();
  List<Map<String, dynamic>> feedbackList = [];

  @override
  void initState() {
    super.initState();
    fetchRating();
    fetchFeedback();
  }

  Future<void> fetchRating() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doc['docid'])
        .get();
    setState(() {
      rating = double.parse(docSnapshot['docRating'].toString());
    });
  }

  Future<void> fetchFeedback() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doc['docid'])
        .collection('ratings')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      feedbackList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> updateRating(double newRating, String feedback) async {
    final user = currentUser;
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doc['docid'])
        .collection('ratings')
        .doc(user!.uid)
        .set({
      'rating': newRating,
      'feedback': feedback,
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    double updatedRating = await calculateNewAverageRating();
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doc['docid'])
        .update({'docRating': updatedRating});

    fetchFeedback();
    setState(() {
      rating = updatedRating;
    });
  }

  Future<double> calculateNewAverageRating() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doc['docid'])
        .collection('ratings')
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += doc['rating'];
    }
    return total / snapshot.docs.length;
  }

  void showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rate Doctor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    this.rating = rating;
                  });
                },
              ),
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  hintText: "Leave a feedback",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Submit"),
              onPressed: () {
                updateRating(rating!, feedbackController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkColor,
      appBar: AppBar(
        title: AppStyle.bold(
          title: "Doctor Details",
          color: Colors.white,
          size: AppSize.size18,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(AppAssets.imgSignup),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppStyle.bold(
                            title: widget.doc['docName'],
                            color: AppColors.textColor,
                            size: AppSize.size14,
                          ),
                          AppStyle.bold(
                            title: widget.doc['docCategory'],
                            color: AppColors.textColor.withOpacity(0.5),
                            size: AppSize.size12,
                          ),
                          Spacer(),
                          RatingBarIndicator(
                            rating: rating ?? 0.0,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                          TextButton(
                            onPressed: showRatingDialog,
                            child: Text(
                              "Rate Doctor",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: AppStyle.bold(
                        title: "Phone Number",
                        color: AppColors.textColor,
                      ),
                      subtitle: AppStyle.normal(
                        title: widget.doc['docPhone'],
                        color: AppColors.textColor.withOpacity(0.5),
                        size: AppSize.size12,
                      ),
                      trailing: Container(
                        width: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.yellow,
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    AppStyle.bold(
                      title: "Address",
                      color: AppColors.textColor,
                      size: AppSize.size16,
                    ),
                    SizedBox(height: 5),
                    AppStyle.normal(
                      title: widget.doc['docAddress'],
                      color: AppColors.textColor.withOpacity(0.5),
                      size: AppSize.size12,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStyle.bold(
                      title: "Feedback",
                      color: AppColors.textColor,
                      size: AppSize.size16,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: feedbackList.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbackList[index];
                        return ListTile(
                          title: Text(
                            feedback['feedback'],
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: AppSize.size14,
                            ),
                          ),
                          subtitle: RatingBarIndicator(
                            rating: feedback['rating']?.toDouble() ?? 0.0,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 15.0,
                            direction: Axis.horizontal,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showRatingDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomButton(
          buttonText: "Book an appointment",
          onTap: () {
            Get.to(() => BookAppointmentView(
                  docId: widget.doc['docid'],
                  docName: widget.doc['docName'],
                  userid: currentUser!.uid,
                ));
          },
        ),
      ),
    );
  }
}
