import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsPage extends StatelessWidget {
  const ViewAppointmentsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'doctorId': data['doctorId'] ?? 'Unknown',
        'doctorName': data['doctorName'] ?? 'Unknown Doctor',
        'patientName': data['patientName'] ?? 'Unknown Patient',
        'patientAge': data['patientAge']?.toString() ?? 'Unknown',
        'phoneNo': data['phoneNo'] ?? 'Unknown',
        'appointmentDate': data['appointmentDate']?.toString() ?? '',
        'appointmentTime': data['appointmentTime']?.toString() ?? '',
        'timestamp': data['timestamp'],
      };
    }).toList();
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Not specified';

    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM d, yyyy').format(parsedDate);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return date;
    }
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return 'Not specified';

    try {
      final timeFormat = DateFormat('h:mm a');
      final parsedTime = timeFormat.parse(time);
      return timeFormat.format(parsedTime);
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "View Appointments",
          style: TextStyle(
            fontSize: 22,
            fontFamily: "GoogleSans",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          final appointments = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/Images/app.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  "All Appointments",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You can see all appointments here.",
                  style: TextStyle(fontSize: 16, fontFamily: "GoogleSans"),
                ),
                const SizedBox(height: 16),

                // Appointments list
                ListView.builder(
                  itemCount: appointments.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final patientName = appointment['patientName'];
                    final doctor = appointment['doctorName'];
                    final formattedDate = _formatDate(appointment['appointmentDate']);
                    final formattedTime = _formatTime(appointment['appointmentTime']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          "Patient: $patientName",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "GoogleSans",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Doctor: $doctor",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "GoogleSans",
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "GoogleSans",
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "GoogleSans",
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Phone: ${appointment['phoneNo']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "GoogleSans",
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Age: ${appointment['patientAge']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "GoogleSans",
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}