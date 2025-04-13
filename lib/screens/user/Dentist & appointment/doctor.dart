import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../footer.dart';
import 'package:intl/intl.dart';

class DoctorScreen extends StatefulWidget {
  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
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

                  var allDoctors = snapshot.data!.docs;
                  var doctors = allDoctors.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final userName = (data['userName'] ?? '').toString().toLowerCase();
                    return userName.contains(_searchText);
                  }).toList();

                  if (doctors.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching dentists found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

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
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Circular Doctor Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/Images/avatar.png',
                                      width: 60,
                                      height: 60,
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
                              const SizedBox(width: 12),
                              // Doctor Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. $userName',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'GoogleSans',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontFamily: 'GoogleSans',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      speciality,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontFamily: 'GoogleSans',
                                      ),
                                    ),
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
          ],
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }
}
