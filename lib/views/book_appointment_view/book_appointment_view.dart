import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../consts/images.dart'; // Replace with your project's imports

class BookAppointmentView extends StatefulWidget {
  final String docId;
  final String docName;
  String? userid;

  BookAppointmentView({
    Key? key,
    required this.docId,
    required this.docName,
    this.userid,
  }) : super(key: key);

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
              .doc(widget.docId) // Assuming docId is the doctor's ID
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
    DateTime today = DateTime.now();

    for (var doc in query.docs) {
      String date = doc.id;
      DateTime appointmentDate = DateFormat('yyyy-MM-dd').parse(date);

      // Only consider appointments from today onwards
      if (appointmentDate.isBefore(today.subtract(Duration(hours: 24)))) {
        continue;
      }

      List<dynamic> appointments = doc['appointments_available'];
      List<String> times = appointments
          .where((appointment) => !(appointment['booked']))
          .map((appointment) => appointment['time'] as String)
          .toList();

      availableAppointments[date] = times;
    }

    setState(() {
      _availableAppointments = availableAppointments;
    });

    // Select the first available date by default if available
    if (availableAppointments.isNotEmpty) {
      _selectDefaultDate();
    }
  }

  void _selectDefaultDate() {
    setState(() {
      _selectedDate = _availableAppointments.keys.first;
      _selectedDayIndex = 0;
      _selectedTimeIndex = -1; // Reset time selection
      _selectedTime = '';
    });
  }

  Future<bool> isTimeSlotBooked(String date, String time) async {
    if (_availableAppointments.containsKey(date)) {
      // Check if the specific time slot is booked
      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(widget.docId)
          .collection('appointments')
          .doc(date)
          .get();

      List<dynamic> appointments = doc['appointments_available'];

      return appointments.any((appointment) =>
          appointment['time'] == time && appointment['booked']);
    }
    return Future.value(
        true); // If date not found or no times available, consider slot as booked
  }

  Future<void> bookAppointment(BuildContext context) async {
    if (_selectedDayIndex == -1 || _selectedTimeIndex == -1) {
      _showDialog(
        context,
        "Incomplete Selection",
        "Please select both a day and a time for the appointment.",
      );
      return;
    }

    bool isBooked = await isTimeSlotBooked(_selectedDate, _selectedTime);
    if (isBooked) {
      _showDialog(
        context,
        "Appointment Not Available",
        "This appointment slot is already booked. Please select another date and time.",
      );
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
      'appForUser': widget.userid,
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

    _showDialog(
      context,
      "Appointment Booked",
      "Your appointment has been successfully booked.",
    );

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
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsChips(List<String> availableSlots) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      children: availableSlots.map((slot) {
        return FutureBuilder(
          future: isTimeSlotBooked(_selectedDate, slot),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bool isBooked = snapshot.data as bool;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ChoiceChip(
                  label: Text(slot),
                  selected: _selectedTime == slot,
                  onSelected: isBooked
                      ? null // Disable selection for booked slots
                      : (bool selected) {
                          setState(() {
                            _selectedTimeIndex =
                                selected ? availableSlots.indexOf(slot) : -1;
                            _selectedTime = selected ? slot : '';
                          });
                        },
                  backgroundColor:
                      isBooked ? Colors.grey[300] : Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isBooked ? Colors.black87 : Colors.black,
                    fontWeight: isBooked ? FontWeight.normal : FontWeight.bold,
                  ),
                  selectedColor: Colors.purple,
                  visualDensity: VisualDensity.compact,
                  elevation: isBooked ? 0 : 2,
                  shadowColor: Colors.grey[50],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      }).toList(),
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
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Row(
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
                style: const TextStyle(
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
              _selectedDate.isNotEmpty &&
                      _availableAppointments.containsKey(_selectedDate)
                  ? _buildTimeSlotsChips(_availableAppointments[_selectedDate]!)
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("No available appointments for this date"),
                    ),
              const SizedBox(height: 20),
              const Text(
                'Make Appointment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: appMobileController,
                decoration: const InputDecoration(
                  labelText: 'Your Mobile',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: appNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: appMessageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  bookAppointment(context);
                },
                child: const Text('Book Appointment'),
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

  const InfoCard({
    Key? key, // Corrected the constructor parameter
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
