import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientName;
  final String patientAge;
  final String phoneNo;
  final Timestamp timestamp;
  final String userId;
  final String appointmentDate;
  final String appointmentTime;
  // final DateTime appointmentDateTime;

  Appointment({
    this.id = '', // Default value
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    required this.patientAge,
    required this.phoneNo,
    required this.timestamp,
    required this.userId,
    required this.appointmentDate,
    required this.appointmentTime,
    // required this.appointmentDateTime,


  });

  factory Appointment.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      patientName: data['patientName'] ?? '',
      patientAge: data['patientAge'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      // appointmentDateTime: ['appointmentDateTime'] as Timestamp.toDate(),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientName': patientName,
      'patientAge': patientAge,
      'phoneNo': phoneNo,
      'appointmentTime': appointmentTime,
      'timestamp': timestamp,
      'userId': userId,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      // 'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
    };
  }
}