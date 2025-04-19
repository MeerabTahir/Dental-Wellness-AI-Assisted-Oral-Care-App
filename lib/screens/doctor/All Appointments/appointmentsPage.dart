import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/appointmentModel.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  DateTime? parseAppointmentTime(String timeStr) {
    try {
      final now = DateTime.now();
      final formatted = '$timeStr ${now.year}';
      return DateFormat("MM-dd 'at' h:mm a yyyy").parse(formatted);
    } catch (e) {
      debugPrint('Date parsing error: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
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
          "Appointments",
          style: TextStyle(
            fontFamily: "GoogleSans",
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                'No appointments found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            );
          }

          final allAppointments = snapshot.data!.docs
              .map((doc) => Appointment.fromDocument(doc))
              .toList();

          final now = DateTime.now();
          final upcoming = allAppointments
              .where((a) =>
          parseAppointmentTime(a.appointmentTime)?.isAfter(now) ?? false)
              .toList();
          final done = allAppointments
              .where((a) =>
          parseAppointmentTime(a.appointmentTime)?.isBefore(now) ?? false)
              .toList();

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
                  "You can see all appointments here",
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
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return appointments.isEmpty
        ? const Center(child: Text("No appointments"))
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final dateTime = parseAppointmentTime(appointment.appointmentTime);
        final dateStr =
        dateTime != null ? DateFormat.MMMd().format(dateTime) : 'N/A';
        final timeStr =
        dateTime != null ? DateFormat.jm().format(dateTime) : 'N/A';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          elevation: 5,
          shadowColor: Colors.blue.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Text(
                    "Patient Name:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "GoogleSans",
                    ),
                  ),
                  title: Text(
                    appointment.patientName,
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
                      'Date: $dateStr',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Time: $timeStr',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.emoji_people, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Age: ${appointment.patientAge}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                        'Phone No: ${appointment.phoneNo}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
}
