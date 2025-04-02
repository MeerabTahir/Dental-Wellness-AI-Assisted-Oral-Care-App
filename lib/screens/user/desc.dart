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
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;
        print('Doctor Data: $doctorData'); // Debugging

        Map<String, List<Map<String, String>>> parsedAvailability = {};

        if (doctorData.containsKey('availability')) {
          Map<String, dynamic> availabilityData = doctorData['availability'] as Map<String, dynamic>;
          print('Availability Data: $availabilityData');

          availabilityData.forEach((day, slotData) {
            if (slotData is List) {
              List<Map<String, String>> slots = slotData.map((slot) {
                return {
                  'start': slot['start']?.toString() ?? '',
                  'end': slot['end']?.toString() ?? '',
                };
              }).toList();
              parsedAvailability[day] = slots;
            }
          });
        }

        setState(() {
          doctor = doctorData;
          availability = parsedAvailability;
        });
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  // Get the first available slot
  Map<String, String>? _getFirstAvailableSlot() {
    if (availability.isNotEmpty) {
      for (var day in availability.keys) {
        if (availability[day]!.isNotEmpty) {
          return availability[day]!.first;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dentist Details',
          style: TextStyle(fontFamily: 'GoogleSans', color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: doctor == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor's details
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: doctor?['profileImage'] != null
                        ? NetworkImage(doctor!['profileImage'])
                        : const AssetImage('assets/Images/dentist1.jpg')
                    as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. ${doctor?['userName'] ?? 'No Name'}",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GoogleSans',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _infoText(doctor?['specialization']),
                        _infoText(doctor?['profession']),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Experience
              _buildDetailRow(
                icon: FontAwesomeIcons.star,
                text: "${doctor?['experience']} years of Experience",
              ),
              const SizedBox(height: 20),

              // Location
              _buildDetailRow(
                icon: FontAwesomeIcons.locationDot,
                text: doctor?['location'] ?? 'Not provided',
              ),
              const SizedBox(height: 20),

              // Description
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    doctor?['desc'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'GoogleSans',
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Available Timings
              _sectionTitle('Available Timings'),
              const SizedBox(height: 10),
              availability.isEmpty
                  ? const Text(
                "No available slots.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
                  : Column(
                children: availability.keys.map((day) {
                  List<Map<String, String>> slots = availability[day] ?? [];
                  return _buildDaySlotCard(day, slots);
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Book Appointment Button
              Center(
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
                          content: Text("No available slots."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'GoogleSans',
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Helper widget for section titles
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'GoogleSans',
        color: Colors.blue,
      ),
    );
  }
  Widget _infoText(String? text) {
    return text != null
        ? Text(
      text,
      style: const TextStyle(fontSize: 18, fontFamily: 'GoogleSans'),
    )
        : const SizedBox.shrink();
  }
  // Helper widget for displaying day and slots
  Widget _buildDaySlotCard(String day, List<Map<String, String>> slots) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          ...slots.map((slot) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "${_formatTime(slot['start'] ?? '')} - ${_formatTime(slot['end'] ?? '')}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // Helper function to format time
  String _formatTime(String time) {
    if (time.isEmpty) return "";

    try {
      DateTime parsedTime = DateTime.parse("2022-01-01 $time");
      return "${parsedTime.hour % 12 == 0 ? 12 : parsedTime.hour % 12}:${parsedTime.minute.toString().padLeft(2, '0')} ${parsedTime.hour < 12 ? 'AM' : 'PM'}";
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }
}