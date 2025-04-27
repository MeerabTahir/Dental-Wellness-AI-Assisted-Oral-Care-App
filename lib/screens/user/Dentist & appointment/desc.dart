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
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'GoogleSans',
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'GoogleSans',
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySlotCard(String day, List<Map<String, String>> slots) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Text(
                  '${slot['start']} - ${slot['end']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Doctor Profile',
          style: TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: doctor == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: doctor?['profileImage'] != null
                          ? NetworkImage(doctor!['profileImage'])
                          : const AssetImage('assets/Images/dentist1.jpg')
                      as ImageProvider,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.verified,
                          size: 16, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Dr. ${doctor?['userName'] ?? 'No Name'}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                    fontFamily: 'GoogleSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${doctor?['specialization'] ?? ''}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'GoogleSans',
                  ),
                ),
                const SizedBox(height: 8),
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
                  _sectionTitle("About Doctor"),
                  const SizedBox(height: 8),
                  Text(
                    doctor?['desc'] ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'GoogleSans',
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Details"),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      icon: FontAwesomeIcons.briefcaseMedical,
                      text: "${doctor?['experience']} years of experience"),
                  _buildDetailRow(
                      icon: FontAwesomeIcons.locationDot,
                      text: doctor?['location'] ?? 'Not provided'),
                  _buildDetailRow(
                      icon: FontAwesomeIcons.moneyBillWave,
                      text: 'Rs. ${doctor?['fees']} per consultation' ??
                          'Not provided'),
                  const SizedBox(height: 24),
                  _sectionTitle('Availability'),
                  const SizedBox(height: 8),
                  availability.isEmpty
                      ? Text(
                    "No available slots.",
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey[600]),
                  )
                      : Column(
                    children: availability.keys.map((day) {
                      List<Map<String, String>> slots =
                          availability[day] ?? [];
                      return _buildDaySlotCard(day, slots);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Book Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
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
                      const SnackBar(
                          content: Text("No available slots.")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'GoogleSans',
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}