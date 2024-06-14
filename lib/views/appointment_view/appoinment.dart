import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String doctorId;
  final String date;
  final String time;
  final bool available;

  Appointment(
      {required this.doctorId,
      required this.date,
      required this.time,
      required this.available});
}

class AvailableSlot {
  final String date;
  final String time;
  final bool available;

  AvailableSlot(
      {required this.date, required this.time, required this.available});
}

void addAvailableSlot(
    String doctorId, String date, String time, bool available) {
  FirebaseFirestore.instance
      .collection('appointments')
      .doc(doctorId)
      .collection('available_slots')
      .doc(date)
      .collection('times')
      .doc(time)
      .set({
    'time': time,
    'available': available,
  });
}

Future<List<AvailableSlot>> getAvailableSlots(
    String doctorId, String date) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('appointments')
      .doc(doctorId)
      .collection('available_slots')
      .doc(date)
      .collection('times')
      .get();

  return snapshot.docs.map((doc) {
    // Explicitly cast the result of 'data()' to 'Map<String, dynamic>'
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Use null-aware operators to access fields safely
    return AvailableSlot(
      date: date,
      time: data['time'] as String, // Add null check for accessing 'time' field
      available: data['available']
          as bool, // Add null check for accessing 'available' field
    );
  }).toList();
}

void updateSlotAvailability(
    String doctorId, String date, String time, bool available) {
  FirebaseFirestore.instance
      .collection('appointments')
      .doc(doctorId)
      .collection('available_slots')
      .doc(date)
      .collection('times')
      .doc(time)
      .update({'available': available});
}

Stream<List<AvailableSlot>> availableSlotsStream(String doctorId, String date) {
  return FirebaseFirestore.instance
      .collection('appointments')
      .doc(doctorId)
      .collection('available_slots')
      .doc(date)
      .collection('times')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return AvailableSlot(
        date: date,
        time: doc.data()['time'],
        available: doc.data()['available'],
      );
    }).toList();
  });
}
