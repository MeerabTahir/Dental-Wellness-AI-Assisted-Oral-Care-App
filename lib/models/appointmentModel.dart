import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String id;
  String doctorId;
  String doctorName;
  String patientName;
  String patientAge;
  Timestamp timestamp;
  String userId;
  String phoneNo;
  String appointmentDate;
  String appointmentTime;

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
    };
  }
}