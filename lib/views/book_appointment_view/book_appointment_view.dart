// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// class BookAppointmentView extends StatefulWidget {
//   final String docId;
//   final String docName;
//   String? userid;

//   BookAppointmentView(
//       {Key? key, required this.docId, required this.docName, this.userid})
//       : super(key: key);

//   @override
//   _BookAppointmentViewState createState() => _BookAppointmentViewState();
// }

// class _BookAppointmentViewState extends State<BookAppointmentView> {
//   TextEditingController appDayController = TextEditingController();
//   TextEditingController appTimeController = TextEditingController();
//   TextEditingController appMobileController = TextEditingController();
//   TextEditingController appNameController = TextEditingController();
//   TextEditingController appMessageController = TextEditingController();
//   var isLoading = false.obs;
//   var currentUser = FirebaseAuth.instance.currentUser;
//   var username = ''.obs;
//   var email = ''.obs;
//   Future? getData;

//   late FirebaseFirestore _firestore;
//   getUserData() async {
//     isLoading(true);
//     DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
//         .instance
//         .collection('user')
//         .doc(currentUser!.uid)
//         .get();
//     var userData = user.data();
//     isLoading(false);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _firestore = FirebaseFirestore.instance;
//   }

//   void onTapFunction(BuildContext context) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       lastDate:
//           DateTime.now().add(Duration(days: 30)), // Example: 30 days from now
//       firstDate: DateTime.now(),
//       initialDate: DateTime.now(),
//     );
//     if (pickedDate == null) return;
//     setState(() {
//       appDayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//     });
//   }

//   void onTapTimeFunction(BuildContext context) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (pickedTime == null) return;
//     setState(() {
//       appTimeController.text = pickedTime.format(context);
//     });
//   }

//   Future<bool> checkAvailability(String date, String time) async {
//     // Query Firestore to check if an appointment exists for the given date and time
//     QuerySnapshot query = await _firestore
//         .collection('appointments')
//         .where('date', isEqualTo: date)
//         .where('time', isEqualTo: time)
//         .get();

//     return query.docs.isEmpty; // Return true if no appointment exists
//   }

//   Future<void> bookAppointment(BuildContext context) async {
//     // Check availability before booking
//     bool isAvailable =
//         await checkAvailability(appDayController.text, appTimeController.text);

//     if (!isAvailable) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Appointment Not Available"),
//           content: Text(
//               "This appointment slot is already booked. Please select another date and time."),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("OK"),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     // If available, book the appointment
//     await _firestore.collection('appointments').add({
//       'appWith': widget.docId,
//       'appWithName': widget.docName,
//       'appDay': appDayController.text,
//       'appTime': appTimeController.text,
//       'appMobile': appMobileController.text,
//       'appName': appNameController.text,
//       'appMsg': appMessageController.text,
//       'appForUser': widget.userid,
//     });

//     // Optionally, show a success message
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Appointment Booked"),
//         content: Text("Your appointment has been successfully booked."),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text("OK"),
//           ),
//         ],
//       ),
//     );

//     // Clear form fields after booking
//     appDayController.clear();
//     appTimeController.clear();
//     appMobileController.clear();
//     appNameController.clear();
//     appMessageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.docName),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       onTapFunction(context);
//                     },
//                     icon: Icon(Icons.access_alarm),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: InkWell(
//                       child: TextField(
//                         controller: appDayController,
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           hintText: "Select day",
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       onTapTimeFunction(context);
//                     },
//                     icon: Icon(Icons.access_time),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: InkWell(
//                       child: TextField(
//                         controller: appTimeController,
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           hintText: "Select Time",
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               Text("Mobile Number:"),
//               SizedBox(height: 5),
//               TextField(
//                 controller: appMobileController,
//                 decoration: InputDecoration(
//                   hintText: "Enter your mobile number",
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text("Full name:"),
//               SizedBox(height: 5),
//               TextField(
//                 controller: appNameController,
//                 decoration: InputDecoration(
//                   hintText: "Enter your name",
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text("Message:"),
//               SizedBox(height: 5),
//               TextField(
//                 controller: appMessageController,
//                 decoration: InputDecoration(
//                   hintText: "Enter your message",
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: ElevatedButton(
//           onPressed: () => bookAppointment(context),
//           child: Text("Book an appointment"),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../consts/images.dart';

class BookAppointmentView extends StatefulWidget {
  final String docId;
  final String docName;
  String? userid;

  BookAppointmentView(
      {Key? key, required this.docId, required this.docName, this.userid})
      : super(key: key);

  @override
  _BookAppointmentViewState createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  TextEditingController appMobileController = TextEditingController();
  TextEditingController appNameController = TextEditingController();
  TextEditingController appMessageController = TextEditingController();

  late FirebaseFirestore _firestore;
  int _selectedDayIndex = -1;
  int _selectedTimeIndex = -1;
  String _selectedDate = '';
  String _selectedTime = '';
  Map<String, List<String>> _availableAppointments = {};

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _fetchAvailableAppointments();
    _fetchDoctorDetails();
  }

  Map<String, dynamic> _doctorData = {};

  Future<void> _fetchDoctorDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(widget.docId) // Assuming docName is the doctor's ID
              .get();

      if (doc.exists) {
        setState(() {
          _doctorData = doc.data()!;
        });
      } else {
        print('Doctor not found');
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
    }
  }

  Future<void> _fetchAvailableAppointments() async {
    QuerySnapshot query = await _firestore
        .collection('doctors')
        .doc(widget.docId)
        .collection('appointments')
        .get();

    Map<String, List<String>> availableAppointments = {};

    for (var doc in query.docs) {
      String date = doc.id;
      List<dynamic> appointments = doc['appointments_available'];
      List<String> times = appointments
          .where((appointment) => !appointment['booked'])
          .map((appointment) => appointment['time'] as String)
          .toList();

      availableAppointments[date] = times;
    }

    setState(() {
      _availableAppointments = availableAppointments;
    });
  }

  bool isTimeSlotBooked(String date, String time) {
    if (_availableAppointments.containsKey(date)) {
      return !_availableAppointments[date]!.contains(time);
    }
    return true; // If date not found, consider the time slot as booked
  }

  Future<void> bookAppointment(BuildContext context) async {
    if (_selectedDayIndex == -1 || _selectedTimeIndex == -1) {
      _showDialog(context, "Incomplete Selection",
          "Please select both a day and a time for the appointment.");
      return;
    }

    bool isAvailable = !isTimeSlotBooked(_selectedDate, _selectedTime);

    if (!isAvailable) {
      _showDialog(context, "Appointment Not Available",
          "This appointment slot is already booked. Please select another date and time.");
      return;
    }

    await _firestore.collection('appointments').add({
      'appWith': widget.docId,
      'appWithName': widget.docName,
      'appDay': _selectedDate,
      'appTime': _selectedTime,
      'appMobile': appMobileController.text,
      'appName': appNameController.text,
      'appMsg': appMessageController.text,
      'appForUser': widget.userid
    });

    await _firestore
        .collection('doctors')
        .doc(widget.docId)
        .collection('appointments')
        .doc(_selectedDate)
        .update({
      'appointments_available': FieldValue.arrayUnion([
        {
          'date': _selectedDate,
          'time': _selectedTime,
          'booked': true,
        }
      ]),
    });

    _showDialog(context, "Appointment Booked",
        "Your appointment has been successfully booked.");

    _clearForm();
  }

  void _clearForm() {
    appMobileController.clear();
    appNameController.clear();
    appMessageController.clear();
    setState(() {
      _selectedDayIndex = -1;
      _selectedTimeIndex = -1;
      _selectedDate = '';
      _selectedTime = '';
      _fetchAvailableAppointments();
    });
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    AppAssets.imgSignup), // Replace with your image asset
              ),
              const SizedBox(height: 20),
              Text(
                widget.docName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                (_doctorData['docCategory'] ?? '') + ' Specialize',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoCard(title: '350+', subtitle: 'Patients'),
                  InfoCard(title: '15+', subtitle: 'Exp. years'),
                  InfoCard(title: '284+', subtitle: 'Reviews'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _doctorData['docDesc'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Schedules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                children: _availableAppointments.keys.map((date) {
                  DateTime day = DateFormat('yyyy-MM-dd').parse(date);
                  return ChoiceChip(
                    label: Text(DateFormat('EEEE, MMM d').format(day)),
                    selected: _selectedDate == date,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedDate = selected ? date : '';
                        _selectedDayIndex = selected
                            ? _availableAppointments.keys.toList().indexOf(date)
                            : -1;
                        _selectedTimeIndex = -1; // Reset time selection
                        _selectedTime = '';
                      });
                    },
                    selectedColor: Colors.purple,
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Visit Hour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                children: _selectedDate.isNotEmpty &&
                        _availableAppointments.containsKey(_selectedDate)
                    ? _availableAppointments[_selectedDate]!.map((time) {
                        return ChoiceChip(
                          label: Text(time),
                          selected: _selectedTime == time,
                          onSelected: (bool selected) {
                            if (!isTimeSlotBooked(_selectedDate, time)) {
                              setState(() {
                                _selectedTimeIndex = selected
                                    ? _availableAppointments[_selectedDate]!
                                        .indexOf(time)
                                    : -1;
                                _selectedTime = selected ? time : '';
                              });
                            }
                          },
                          selectedColor: Colors.purple,
                          backgroundColor: Colors.grey[100],
                          disabledColor: Colors.redAccent,
                        );
                      }).toList()
                    : [
                        Text("No available appointments for this date")
                      ], // Display message when no appointments are available
              ),
              const SizedBox(height: 20),
              TextField(
                controller: appMobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: appNameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: appMessageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  bookAppointment(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  InfoCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
