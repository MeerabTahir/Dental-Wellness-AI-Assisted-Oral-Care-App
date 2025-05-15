import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tooth_tales/models/appointmentModel.dart';
import 'package:tooth_tales/screens/footer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

import '../../../main.dart';


class AppointmentScreen extends StatefulWidget {
  final String doctorId;
  final Map<String, String> selectedSlot;

  const AppointmentScreen({
    Key? key,
    required this.doctorId,
    required this.selectedSlot,
  }) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late Map<String, dynamic> doctorData = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedDate;
  String? selectedSubSlot;
  List<String> allPossibleSubSlots = [];
  List<String> availableSubSlots = [];
  List<String> availableDates = [];
  List<String> bookedSlots = [];
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
    tz.initializeTimeZones();
  }

  List<int> availableWeekdays = [];
  Map<int, String> weekdayMap = {
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

  Future<void> _fetchDoctorData() async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        setState(() {
          doctorData = doctorDoc.data() as Map<String, dynamic>;
          final availability = doctorData['availability'] as Map<String, dynamic>?;
          if (availability != null) {
            availableWeekdays = availability.keys.map((day) {
              return weekdayMap.entries
                  .firstWhere((entry) => entry.value == day)
                  .key;
            }).toList();
          }
          _generateAvailableDates();
          _generateAllPossibleSubSlots();
        });
      } else {
        print('Doctor not found');
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _generateAllPossibleSubSlots() {
    allPossibleSubSlots.clear();
    String startTime = widget.selectedSlot['start']!;
    String endTime = widget.selectedSlot['end']!;

    try {
      DateFormat format = DateFormat.jm();
      DateTime start = format.parse(startTime);
      DateTime end = format.parse(endTime);

      while (start.isBefore(end)) {
        allPossibleSubSlots.add(format.format(start));
        start = start.add(Duration(minutes: 15));
      }
    } catch (e) {
      print('Error parsing time slots: $e');
    }
  }

  Future<void> _fetchBookedSlots() async {
    if (selectedDate == null) return;

    setState(() {
      isLoading = true;
      selectedSubSlot = null;
    });

    try {
      // Parse the selected date with year included
      DateTime parsedDate = DateFormat('EEEE, dd MMMM yyyy').parse(selectedDate!);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      // Query appointments for this doctor on this specific date
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('appointmentDate', isEqualTo: formattedDate)

          .get();

      setState(() {
        // Get all booked time slots for this date
        bookedSlots = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['appointmentTime'].toString();
        }).toList();

        // Filter available slots by removing booked slots
        availableSubSlots = allPossibleSubSlots.where((slot) {
          return !bookedSlots.contains(slot);
        }).toList();

        if (availableSubSlots.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No available slots for this date."),backgroundColor: Colors.red,),
          );
        }
      });
    } catch (e) {
      print('Error fetching booked slots: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _generateAvailableDates() {
    availableDates.clear();
    DateTime today = DateTime.now();
    DateTime endDate = today.add(Duration(days: 30));

    List<String> doctorAvailableDays = doctorData['availability']?.keys.toList().cast<String>() ?? [];

    while (today.isBefore(endDate)) {
      String weekdayName = DateFormat('EEEE').format(today);
      if (doctorAvailableDays.contains(weekdayName)) {
        String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(today);  // Added year
        availableDates.add(formattedDate);
      }
      today = today.add(Duration(days: 1));
    }
  }


  void _submitAppointment(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedDate == null || selectedSubSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a date and time slot."),backgroundColor: Colors.red,),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        // Parse the selected date with year included
        DateTime parsedDate = DateFormat('EEEE, dd MMMM yyyy').parse(selectedDate!);
        String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

        Appointment appointment = Appointment(
          doctorId: widget.doctorId,
          doctorName: doctorData['userName'],
          patientName: _nameController.text.trim(),
          patientAge: _ageController.text.trim(),
          phoneNo: _phoneController.text.trim(),
          timestamp: Timestamp.now(),
          userId: FirebaseAuth.instance.currentUser!.uid,
          appointmentDate: formattedDate,
          appointmentTime: selectedSubSlot!,
        );

        // Save the appointment first
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('appointments')
            .add(appointment.toMap());

        await docRef.update({'id': docRef.id});

        // Try to schedule notification, but don't let it fail the whole process
        try {
          DateTime parseDate = DateFormat('yyyy-MM-dd').parse(appointment.appointmentDate);
          DateTime parsedTime = DateFormat.jm().parse(appointment.appointmentTime);

          DateTime appointmentDateTime = DateTime(
            parseDate.year,
            parseDate.month,
            parseDate.day,
            parsedTime.hour,
            parsedTime.minute,
          );

          DateTime notifyTime = appointmentDateTime.subtract(Duration(minutes: 13));

          print('Appointment time: $appointmentDateTime');
          print('Notification scheduled for: $notifyTime');

          await scheduleAppointmentNotification(
            'Appointment Reminder',
            'Your appointment with Dr. ${doctorData['userName']} is at ${appointment.appointmentTime}',
            notifyTime,
          );
        } catch (e) {
          print('Error in notification time calculation: $e');
        }

        // Navigate regardless of notification success
        Navigator.pushReplacementNamed(context, '/schedule');
      } catch (e) {
        print('Error submitting appointment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to book appointment. Please try again."),backgroundColor: Colors.red,),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }
  Future<void> scheduleAppointmentNotification(
      String title, String body, DateTime scheduledDateTime) async {
    print('Attempting to schedule notification for: $scheduledDateTime');

    // Check if the time is in the future
    if (scheduledDateTime.isBefore(DateTime.now())) {
      print('Notification time is in the past!');
      return;
    }

    var androidDetails = AndroidNotificationDetails(
      'appointment_channel', // Make sure this matches your channel ID
      'Appointment Reminders',
      channelDescription: 'Reminders for your upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID
        title,
        body,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Book Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: doctorData.isEmpty
            ? Center(child: Text('Doctor data not available'))
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment with Dr. ${doctorData['userName']}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                SizedBox(height: 6),
                Text(
                  doctorData['profession'] ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                Text(
                  'Patient Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _nameController,
                  label: 'Patient Name',
                  hint: 'Enter full name',
                  keyboardType: TextInputType.name,
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _ageController,
                  label: 'Age',
                  hint: 'Enter age',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter 11-digit phone number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) {
                      return 'Enter a valid 11-digit phone number';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Appointment Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                SizedBox(height: 10),
                _buildStyledDropdown(
                  value: selectedDate,
                  hint: 'Select Appointment Date',
                  items: availableDates,
                  onChanged: (value) async {
                    setState(() {
                      selectedDate = value;
                      selectedSubSlot = null;
                    });
                    await _fetchBookedSlots();
                  },
                ),
                SizedBox(height: 10),
                _buildTimeSlotDropdown(),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submitAppointment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Book Appointment',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.blue),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: TextStyle(fontSize: 16, color: Colors.black),
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      ))
          .toList(),
    );
  }

  Widget _buildTimeSlotDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSubSlot,
      icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Select Time Slot',
        labelStyle: TextStyle(color: Colors.blue),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: TextStyle(fontSize: 16, color: Colors.black),
      onChanged: (value) {
        setState(() {
          selectedSubSlot = value;
        });
      },
      items: allPossibleSubSlots.map((slot) {
        bool isBooked = bookedSlots.contains(slot);
        return DropdownMenuItem<String>(
          value: isBooked ? null : slot,
          child: Text(
            slot,
            style: TextStyle(
              color: isBooked ? Colors.grey : Colors.black,
            ),
          ),
          enabled: !isBooked,
        );
      }).toList(),
    );
  }


}