import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'oralexamination.dart';

class PatientInfoScreen extends StatefulWidget {
  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _medicalHistoryController = TextEditingController();
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  Future<void> _savePatientInfo() async {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('oral scan patients').add({
        'name': _nameController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'medicalHistory': _medicalHistoryController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OralExaminationScreen(patientInfo: {
          'name': _nameController.text,
          'age': _ageController.text,
          'gender': _selectedGender ?? 'Not specified',
          'medicalHistory': _medicalHistoryController.text,},)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient information saved successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save patient information: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'GoogleSans',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text(
            'Patient Information',
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/Images/report.png'), // Add your image asset
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Title
              Center(
                child: Text(
                  'Your Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Please provide your details to proceed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Form Fields
              _buildTextField(_nameController, 'Full Name', Icons.person),
              SizedBox(height: 16),
              _buildTextField(
                _ageController,
                'Age',
                Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Gender Dropdown
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    hint: Text('Select your gender'),
                    items: _genderOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              _buildTextField(
                _medicalHistoryController,
                'Medical History (Optional)',
                Icons.medical_services,
                maxLines: 3,
              ),
              SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePatientInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Proceed to Dental Scan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      style:
      const TextStyle(
          fontSize: 14,
          fontFamily: 'GoogleSans'),
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey[50],

      ),
    );
  }
}
