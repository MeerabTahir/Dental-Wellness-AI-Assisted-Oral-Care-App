import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'appointment.dart';


class DescriptionScreen extends StatefulWidget {
  final String doctorId;

  const DescriptionScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  Map<String, dynamic>? doctor;
  Map<String, List<Map<String, String>>> availability = {};

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.doctorId).get();
      if (snapshot.exists) {
        setState(() {
          doctor = snapshot.data();
          Map<String, dynamic>? availabilityData = doctor?['availability'];
          if (availabilityData != null) {
            availabilityData.forEach((day, slots) {
              if (slots is List) {
                availability[day] = slots.map<Map<String, String>>((slot) {
                  return {
                    'start': slot['start'].toString(),
                    'end': slot['end'].toString(),
                  };
                }).toList();
              }
            });

          }
        });
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
    }
  }

  Map<String, String>? _getFirstAvailableSlot() {
    for (var day in availability.keys) {
      final slots = availability[day];
      if (slots != null && slots.isNotEmpty) {
        return slots.first;
      }
    }
    return null;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'GoogleSans',
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontFamily: 'GoogleSans'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySlotCard(String day, List<Map<String, String>> slots) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots
                    .map((slot) => Chip(
                  label: Text('${slot['start']} - ${slot['end']}'),
                  backgroundColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome',
                style: TextStyle(fontFamily: 'GoogleSans', fontSize: 22)),
            Text(' Dentist',
                style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white
         )),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: doctor == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          // Profile Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2979FF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: doctor?['profileImage'] != null
                      ? NetworkImage(doctor!['profileImage'])
                      : const AssetImage('assets/Images/dentist1.jpg') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  "Dr. ${doctor?['userName'] ?? 'No Name'}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'GoogleSans',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${doctor?['specialization'] ?? ''} · ${doctor?['profession'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'GoogleSans',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text("4.8 (456 Reviews)", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          // Details and Slots
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Description"),
                  const SizedBox(height: 10),
                  Text(
                    doctor?['desc'] ?? 'No description available.',
                    style: TextStyle(fontSize: 16, fontFamily: 'GoogleSans', color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle("Information"),
                  const SizedBox(height: 10),
                  _buildDetailRow(icon: FontAwesomeIcons.star, text: "${doctor?['experience']} years of Experience"),
                  _buildDetailRow(icon: FontAwesomeIcons.locationDot, text: doctor?['location'] ?? 'Not provided'),
                  const SizedBox(height: 20),
                  _sectionTitle('Available Timings'),
                  const SizedBox(height: 10),
                  availability.isEmpty
                      ? const Text("No available slots.", style: TextStyle(fontSize: 16, color: Colors.grey))
                      : Column(
                    children: availability.keys.map((day) {
                      List<Map<String, String>> slots = availability[day] ?? [];
                      return _buildDaySlotCard(day, slots);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Map<String, String>? slot = _getFirstAvailableSlot();
                  if (slot != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentScreen(
                          doctorId: widget.doctorId,
                          selectedSlot: slot,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No available slots.")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(fontSize: 18, fontFamily: 'GoogleSans', color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
