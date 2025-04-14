import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewAppointmentsPage extends StatelessWidget {
  const ViewAppointmentsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
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
                    final patientName = appointment['patientName'] ?? 'N/A';
                    final doctor = appointment['doctorName'] ?? 'N/A';

                    String rawAppointment = appointment['appointmentTime'] ?? 'N/A';
                    String datePart = 'N/A';
                    String timePart = 'N/A';

                    if (rawAppointment.contains(" at ")) {
                      final parts = rawAppointment.split(" at ");
                      if (parts.length == 2) {
                        datePart = parts[0];
                        timePart = parts[1];
                      }
                    }

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
                            Text(
                              "Date: $datePart",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "GoogleSans",
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Time: $timePart",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "GoogleSans",
                                color: Colors.grey,
                              ),
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
