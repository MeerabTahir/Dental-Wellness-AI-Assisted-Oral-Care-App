import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../footer.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white, // Soft background color
      appBar: AppBar(
        title: Text(
          'Scheduled Appointments',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GoogleSans',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue, // Darker blue for contrast
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white, size:20,),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: currentUserId) // Filter by current user
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue[800]),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No appointments scheduled',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          List<QueryDocumentSnapshot> appointments = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var data = appointments[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    // Add navigation or action on tap
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue, size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Name: ${data['patientName']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Doctor: Dr. ${data['doctorName']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Phone no: ${data['phoneNo']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Time: ${data['appointmentTime']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }
}