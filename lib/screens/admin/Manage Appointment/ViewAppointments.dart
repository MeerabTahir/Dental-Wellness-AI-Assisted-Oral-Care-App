import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsPage extends StatefulWidget {
  const ViewAppointmentsPage({Key? key}) : super(key: key);

  @override
  _ViewAppointmentsPageState createState() => _ViewAppointmentsPageState();
}

class _ViewAppointmentsPageState extends State<ViewAppointmentsPage> {
  String _selectedSpecialization = 'All';
  List<String> _specializations = ['All'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpecializations();
  }

  Future<void> _fetchSpecializations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final specializations = snapshot.docs
          .map((doc) => doc.data()['specialization'] as String? ?? 'General')
          .where((spec) => spec.isNotEmpty)
          .toSet()
          .toList();

      setState(() {
        _specializations = ['All', ...specializations];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching specializations: $e');
    }
  }

  DateTime? _parseAppointmentDateTime(String? date, String? time) {
    try {
      if (date == null || time == null) return null;

      // Parse date in format "2025-05-20"
      final dateParts = date.split('-');
      if (dateParts.length != 3) return null;

      final year = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final day = int.tryParse(dateParts[2]);
      if (year == null || month == null || day == null) return null;

      // Parse time in format "8:00 PM"
      final timeFormat = DateFormat('h:mm a');
      final timeOfDay = timeFormat.parse(time);

      // Combine date and time
      return DateTime(
        year,
        month,
        day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    } catch (e) {
      debugPrint('Error parsing date/time: $e');
      return null;
    }
  }

  List<Map<String, dynamic>> _sortAppointmentsByDateDesc(List<Map<String, dynamic>> appointments) {
    return appointments..sort((a, b) {
      final aDt = _parseAppointmentDateTime(a['appointmentDate'], a['appointmentTime']);
      final bDt = _parseAppointmentDateTime(b['appointmentDate'], b['appointmentTime']);

      if (aDt == null && bDt == null) return 0;
      if (aDt == null) return 1;
      if (bDt == null) return -1;

      return bDt.compareTo(aDt); // Descending order (newest first)
    });
  }

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      Query query = FirebaseFirestore.instance.collection('appointments')
          .orderBy('appointmentDate', descending: true) // Primary sort by date
          .orderBy('appointmentTime', descending: true); // Secondary sort by time

      if (_selectedSpecialization != 'All') {
        // First get doctor IDs with this specialization
        final doctorsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('specialization', isEqualTo: _selectedSpecialization)
            .get();

        final doctorIds = doctorsSnapshot.docs.map((doc) => doc.id).toList();

        if (doctorIds.isNotEmpty) {
          query = query.where('doctorId', whereIn: doctorIds);
        } else {
          return []; // No doctors with this specialization
        }
      }

      final querySnapshot = await query.get();

      final appointments = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'doctorId': data['doctorId'] as String? ?? 'Unknown',
          'doctorName': data['doctorName'] as String? ?? 'Unknown Doctor',
          'specialization': data['doctorSpecialization'] as String? ?? 'General',
          'patientName': data['patientName'] as String? ?? 'Unknown Patient',
          'patientAge': (data['patientAge']?.toString() as String?) ?? 'Unknown',
          'phoneNo': data['phoneNo'] as String? ?? 'Unknown',
          'appointmentDate': data['appointmentDate']?.toString() ?? '',
          'appointmentTime': data['appointmentTime']?.toString() ?? '',
          'timestamp': data['timestamp'],
        };
      }).toList();

      // Additional client-side sorting for more accurate ordering
      return _sortAppointmentsByDateDesc(appointments);
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      return [];
    }
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
            fontSize: 18,
            fontFamily: "GoogleSans",
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Specialization Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  value: _selectedSpecialization,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _specializations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: "GoogleSans",
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSpecialization = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No appointments found.",
                      style: TextStyle(fontFamily: "GoogleSans"),
                    ),
                  );
                }

                final appointments = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/Images/app.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _selectedSpecialization == 'All'
                              ? "All Appointments"
                              : "$_selectedSpecialization Appointments",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GoogleSans",
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Filtered by selected specialization",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "GoogleSans"),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        itemCount: appointments.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          final patientName = appointment['patientName'] as String;
                          final doctor = appointment['doctorName'] as String;
                          final specialization = appointment['specialization'] as String;
                          final formattedDate = _formatDate(appointment['appointmentDate'] as String?);
                          final formattedTime = _formatTime(appointment['appointmentTime'] as String?);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
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
                                  Text(
                                    "Specialization: $specialization",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "GoogleSans",
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey),
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 16, color: Colors.grey),
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
                                      const Icon(Icons.phone,
                                          size: 16, color: Colors.grey),
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 16, color: Colors.grey),
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
          ),
        ],
      ),
    );
  }
}