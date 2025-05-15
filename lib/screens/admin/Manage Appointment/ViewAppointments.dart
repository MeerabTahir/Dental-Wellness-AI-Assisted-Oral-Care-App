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

      final dateParts = date.split('-');
      if (dateParts.length != 3) return null;

      final year = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final day = int.tryParse(dateParts[2]);
      if (year == null || month == null || day == null) return null;

      final timeFormat = DateFormat('h:mm a');
      final timeOfDay = timeFormat.parse(time);

      return DateTime(
        year,
        month,
        day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    } catch (e) {
      debugPrint('Error parsing date/time: $e');
    }
    return null;
  }

  List<Map<String, dynamic>> _sortAppointmentsByDateDesc(List<Map<String, dynamic>> appointments) {
    return appointments..sort((a, b) {
      final aDt = _parseAppointmentDateTime(a['appointmentDate'], a['appointmentTime']);
      final bDt = _parseAppointmentDateTime(b['appointmentDate'], b['appointmentTime']);

      if (aDt == null && bDt == null) return 0;
      if (aDt == null) return 1;
      if (bDt == null) return -1;

      return bDt.compareTo(aDt);
    });
  }

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      Query query = FirebaseFirestore.instance.collection('appointments')
          .orderBy('appointmentDate', descending: true)
          .orderBy('appointmentTime', descending: true);

      if (_selectedSpecialization != 'All') {
        final doctorsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('specialization', isEqualTo: _selectedSpecialization)
            .get();

        final doctorIds = doctorsSnapshot.docs.map((doc) => doc.id).toList();

        if (doctorIds.isNotEmpty) {
          query = query.where('doctorId', whereIn: doctorIds);
        } else {
          return [];
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

  Color _getSpecializationColor(String specialization) {
    final colors = {
      'Cardiology': Colors.red.shade100,
      'Dermatology': Colors.orange.shade100,
      'Neurology': Colors.blue.shade100,
      'Pediatrics': Colors.green.shade100,
      'Orthopedics': Colors.purple.shade100,
      'General': Colors.grey.shade100,
    };
    return colors[specialization] ?? Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "View Appointments",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
          children: [
      // Header with filter
      Container(
      padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Filter Appointments",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "GoogleSans",
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: _selectedSpecialization,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                items: _specializations.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontFamily: "GoogleSans",
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
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load appointments",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontFamily: "GoogleSans",
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Images/app.jpg',
                      width: 400,
                      height: 200,
                    ),
                    Text(
                      "No appointments found",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontFamily: "GoogleSans",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedSpecialization == 'All'
                          ? "There are no appointments scheduled"
                          : "No appointments for $_selectedSpecialization",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: "GoogleSans",
                      ),
                    ),
                  ],
                ),
              );
            }

            final appointments = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              color: Colors.blue,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final patientName = appointment['patientName'] as String;
                  final doctor = appointment['doctorName'] as String;
                  final specialization = appointment['specialization'] as String;
                  final formattedDate = _formatDate(appointment['appointmentDate'] as String?);
                  final formattedTime = _formatTime(appointment['appointmentTime'] as String?);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Patient info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patientName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Age: ${appointment['patientAge']}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Doctor info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Doctor",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          doctor,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Appointment time
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Date",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Time",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "GoogleSans",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Contact info
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 20, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    appointment['phoneNo'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontFamily: "GoogleSans",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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