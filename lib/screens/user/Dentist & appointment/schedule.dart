import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../footer.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scheduled Appointments',
          style: TextStyle(
            fontFamily: 'GoogleSans',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true) // Add this line for initial sorting
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No appointments scheduled.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
          }

          final appointments = snapshot.data!.docs
              .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
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
          })
              .toList();

          final now = DateTime.now();
          final upcoming = _sortAppointmentsByDateDesc(appointments
              .where((a) {
            final dt = _parseAppointmentDateTime(
              a['appointmentDate'] as String?,
              a['appointmentTime'] as String?,
            );
            return dt != null && dt.isAfter(now);
          })
              .toList());
          final done = _sortAppointmentsByDateDesc(appointments
              .where((a) {
            final dt = _parseAppointmentDateTime(
              a['appointmentDate'] as String?,
              a['appointmentTime'] as String?,
            );
            return dt != null && dt.isBefore(now);
          })
              .toList());

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/Images/app.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Your Appointments",
                  style: TextStyle(
                    fontFamily: "GoogleSans",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "You can see all your appointments here",
                  style: TextStyle(
                    fontFamily: "GoogleSans",
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Upcoming"),
                  Tab(text: "Done"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentList(upcoming),
                    _buildAppointmentList(done),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }


  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments) {
    return appointments.isEmpty
        ? const Center(child: Text("No appointments"))
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final formattedDate = _formatDate(appointment['appointmentDate'] as String?);
        final formattedTime = _formatTime(appointment['appointmentTime'] as String?);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Text(
                    "Patient Name:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "GoogleSans",
                    ),
                  ),
                  title: Text(
                    appointment['patientName'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "GoogleSans",
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Date: $formattedDate',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "GoogleSans"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Time: $formattedTime',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "GoogleSans"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.emoji_people, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Patient Age: ${appointment['patientAge']}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "GoogleSans"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Doctor: ${appointment['doctorName']}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "GoogleSans"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phone: ${appointment['phoneNo']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: "GoogleSans"),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
}