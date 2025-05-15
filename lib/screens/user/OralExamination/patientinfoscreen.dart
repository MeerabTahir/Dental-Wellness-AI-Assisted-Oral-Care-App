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

  // Track validation errors
  String? _nameError;
  String? _ageError;
  String? _genderError;

  Future<void> _savePatientInfo() async {
    // Reset errors
    setState(() {
      _nameError = null;
      _ageError = null;
      _genderError = null;
    });

    // Validate fields
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() => _nameError = 'Name is required');
      isValid = false;
    }

    if (_ageController.text.isEmpty) {
      setState(() => _ageError = 'Age is required');
      isValid = false;
    }

    if (_selectedGender == null) {
      setState(() => _genderError = 'Gender is required');
      isValid = false;
    }

    if (!isValid) {
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
          'medicalHistory': _medicalHistoryController.text,
        })),
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
                    image: AssetImage('assets/Images/report.png'),
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

              // Form Fields with validation messages
              if (_nameError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _nameError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              _buildTextField(
                _nameController,
                'Full Name',
                Icons.person,
                hasError: _nameError != null,
              ),
              SizedBox(height: 16),

              if (_ageError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _ageError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              _buildTextField(
                _ageController,
                'Age',
                Icons.calendar_today,
                keyboardType: TextInputType.number,
                hasError: _ageError != null,
              ),

              SizedBox(height: 16),

              // Gender Dropdown with validation
              if (_genderError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _genderError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
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
                  border: Border.all(
                    color: _genderError != null ? Colors.red : Colors.grey[400]!,
                    width: 1.0,
                  ),
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
                        _genderError = null; // Clear error when user selects something
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        bool hasError = false,
      }) {
    return TextField(
      style: const TextStyle(fontSize: 14, fontFamily: 'GoogleSans'),
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey[50],
        errorText: null, // We're handling errors above the field instead
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.grey[400]!,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.grey[400]!,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.blue,
            width: 2.0,
          ),
        ),
      ),
      onChanged: (value) {
        // Clear error when user starts typing
        if (label == 'Full Name' && value.isNotEmpty) {
          setState(() => _nameError = null);
        } else if (label == 'Age' && value.isNotEmpty) {
          setState(() => _ageError = null);
        }
      },
    );
  }
}