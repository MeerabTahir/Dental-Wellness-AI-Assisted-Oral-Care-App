import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../footer.dart';
import 'package:intl/intl.dart';

class DoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dentists',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GoogleSans',
            fontSize: 20,

          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('isDoctor', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: Colors.blue));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
            var doctors = snapshot.data!.docs;

            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                var doctor = doctors[index].data() as Map<String, dynamic>;

                String imageUrl = doctor['profileImage'] ?? "Unknown";
                String userName = doctor['userName'] ?? 'Unknown';
                String speciality = doctor['profession'] ?? 'Not Specified';
                String location = doctor['location'] ?? 'Location not available';
                String formattedAppointmentTime = '';

                var appointmentTime = doctor['appointmentTime'];
                if (appointmentTime != null) {
                  if (appointmentTime is Timestamp) {
                    DateTime dateTime = appointmentTime.toDate();
                    formattedAppointmentTime = DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
                  } else if (appointmentTime is String) {
                    formattedAppointmentTime = appointmentTime;
                  } else {
                    print('Unexpected appointmentTime format: $appointmentTime');
                  }
                }

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/desc', arguments: {
                      'doctorId': doctors[index].id,
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Doctor's Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/Images/avatar.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            'assets/Images/avatar.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20),
                        // Doctor's Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dr. $userName',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                speciality,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.blue, size: 18),
                                  SizedBox(width: 5),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontFamily: 'GoogleSans',
                                    ),
                                  ),
                                ],
                              ),
                              if (formattedAppointmentTime.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Available at: $formattedAppointmentTime',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 14,
                                    fontFamily: 'GoogleSans',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }
}
