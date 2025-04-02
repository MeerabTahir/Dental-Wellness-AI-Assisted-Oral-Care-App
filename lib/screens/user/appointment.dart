import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tooth_tales/models/appointmentModel.dart';
import 'package:tooth_tales/screens/footer.dart';

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
  List<String> availableSubSlots = [];
  List<String> availableDates = [];

  final _formKey = GlobalKey<FormState>();


  // get phoneno => null;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
    _generateSubSlots();
    _generateAvailableDates();
  }

  Future<void> _fetchDoctorData() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        setState(() {
          doctorData = doctorDoc.data() as Map<String, dynamic>;
        });
      } else {
        print('Doctor not found');
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  void _generateSubSlots() {
    availableSubSlots.clear();

    String startTime = widget.selectedSlot['start']!;
    String endTime = widget.selectedSlot['end']!;

    try {
      DateFormat format = DateFormat.jm();
      DateTime start = format.parse(startTime);
      DateTime end = format.parse(endTime);

      while (start.isBefore(end)) {
        availableSubSlots.add(format.format(start));
        start = start.add(Duration(minutes: 15));
      }

      setState(() {});
    } catch (e) {
      print('Error parsing time slots: $e');
    }
  }

  void _generateAvailableDates() {
    availableDates.clear();
    DateTime today = DateTime.now();
    DateTime endDate = today.add(Duration(days: 30));

    while (today.isBefore(endDate)) {
      if (today.weekday >= DateTime.monday && today.weekday <= DateTime.friday) {
        String formattedDate = DateFormat('EEE d MMM').format(today);
        availableDates.add(formattedDate);
      }
      today = today.add(Duration(days: 1));
    }

    setState(() {});
  }

  void _submitAppointment(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedDate == null || selectedSubSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a date and time slot.")),
        );
        return;
      }

      String name = _nameController.text.trim();
      String age = _ageController.text.trim();
      String phone = _phoneController.text.trim(); // Correct variable

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('No user is currently logged in.');
        return;
      }

      try {
        DateTime parsedDate = DateFormat('EEE d MMM').parse(selectedDate!);
        String formattedDate = DateFormat('MM-dd').format(parsedDate);

        Appointment appointment = Appointment(
          doctorId: widget.doctorId,
          doctorName: doctorData['userName'],
          patientName: name,
          patientAge: age,
          phoneNo: phone, // Use the validated phone number
          timestamp: Timestamp.now(),
          userId: userId,
          appointmentTime: "$formattedDate at $selectedSubSlot",
        );

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('appointments')
            .add(appointment.toMap());

        String appointmentId = docRef.id;
        await docRef.update({'id': appointmentId});

        Navigator.pushReplacementNamed(context, '/schedule');
      } catch (e) {
        print('Error submitting appointment: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GoogleSans',

          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: doctorData.isEmpty
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment with Dr. ${doctorData['userName']}',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${doctorData['profession'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'GoogleSans',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontFamily: 'GoogleSans',
                  ),
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _nameController,
                  label: 'Patient Name',
                  hint: 'Enter patient name',
                  icon: Icons.person,
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _ageController,
                  label: 'Patient Age',
                  hint: 'Enter patient age',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter phone number (e.g., 01712345678)',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    // Check if phone number is numeric and has 11 digits
                    if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) {
                      return 'Enter a valid 11-digit phone number';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11), // Changed from 10 to 11
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontFamily: 'GoogleSans',
                  ),
                ),
                SizedBox(height: 10),
                _buildDropdown(
                  value: selectedDate,
                  hint: 'Select Appointment Date',
                  items: availableDates,
                  onChanged: (value) {
                    setState(() {
                      selectedDate = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildDropdown(
                  value: selectedSubSlot,
                  hint: 'Select Time Slot',
                  items: availableSubSlots,
                  onChanged: (value) {
                    setState(() {
                      selectedSubSlot = value!;
                    });
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _submitAppointment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        // elevation: 5,
                      ),),
                    child: Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                        fontFamily: 'GoogleSans',
                      ),
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue!),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}