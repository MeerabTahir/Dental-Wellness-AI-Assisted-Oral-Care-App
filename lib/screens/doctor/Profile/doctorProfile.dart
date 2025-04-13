import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  Map<String, List<Map<String, String>>> availability = {};
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedGender;

  File? _profileImage;
  String? _imageUrl;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        nameController.text = userData['userName'] ?? '';
        specializationController.text = userData['specialization'] ?? '';
        professionController.text = userData['profession'] ?? '';
        experienceController.text = userData['experience'] ?? '';
        locationController.text = userData['location'] ?? '';
        selectedGender = userData['gender'] ?? '';
        descController.text = userData['desc'] ?? '';
        _imageUrl = userData['profileImage'];

        // Fetching and parsing availability data
        if (userData['availability'] != null) {
          availability = (userData['availability'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
              key,
              (value as List<dynamic>)
                  .map((slot) => Map<String, String>.from(slot))
                  .toList(),
            ),
          );
        }
      });
    }
  }


  Future<void> _updateProfile() async {
    String? imageUrl = _imageUrl;
    if (_profileImage != null) {
      imageUrl = await _uploadImage(_profileImage!);
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "userName": nameController.text,
        "specialization": specializationController.text,
        "profession": professionController.text,
        "experience": experienceController.text,
        "location": locationController.text,
        "gender": selectedGender,
        "desc": descController.text,
        "availability": availability, // Save availability
        "profileImage": imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference storageRef =
    FirebaseStorage.instance.ref().child('doctor_profiles/$uid.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _addTimeSlot() {
    if (selectedDay != null && startTime != null && endTime != null) {
      String start = startTime!.format(context);
      String end = endTime!.format(context);

      setState(() {
        // Replace existing slot instead of adding multiple slots for the same day
        availability[selectedDay!] = [
          {"start": start, "end": end}
        ];
        startTime = null;
        endTime = null;
      });
    }
  }


  void _removeTimeSlot(String day, int index) {
    setState(() {
      availability[day]?.removeAt(index);
      if (availability[day]!.isEmpty) {
        availability.remove(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Dentist Profile",
            style: TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 18,
                color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : AssetImage('assets/Images/avatar.png') as ImageProvider,
                    child: _profileImage == null && _imageUrl == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.white.withOpacity(0.7))
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                  child: Text("Dentist Profile",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GoogleSans',
                          color: Colors.blue))),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: specializationController,
                decoration: InputDecoration(
                  labelText: "Specialization",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: professionController,
                decoration: InputDecoration(
                  labelText: "Profession",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(
                  labelText: "Experience",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              // DropdownButtonFormField<String>(
              //   value: selectedGender,
              //   decoration: InputDecoration(
              //     labelText: "Gender",
              //     border: OutlineInputBorder(),
              //     contentPadding:
              //     EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              //   ),
              //   items: ["Male", "Female", "Other"]
              //       .map((gender) => DropdownMenuItem(
              //     value: gender,
              //     child: Text(gender),
              //   ))
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedGender = value;
              //     });
              //   },
              // ),
              SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedDay,
                hint: Text("Select Day",
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'GoogleSans',
                        color: Colors.black)),
                onChanged: (value) => setState(() => selectedDay = value),
                items: days
                    .map((day) => DropdownMenuItem(
                  value: day,
                  child: Text(day),
                ))
                    .toList(),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(
                        " ${startTime?.format(context) ?? "Start Time"}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GoogleSans',
                            color: Colors.blue),
                      )),
                  TextButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(
                        "${endTime?.format(context) ?? "End Time"}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GoogleSans',
                            color: Colors.blue),
                      )),
                  IconButton(
                      icon: Icon(Icons.add), onPressed: _addTimeSlot),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Available Slots",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 5),
                  availability.isNotEmpty
                      ? Column(
                    children: availability.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${entry.key}",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: entry.value.map((slot) {
                              return ListTile(
                                title: Text(
                                    "Time: ${slot['start']} - ${slot['end']}"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _removeTimeSlot(entry.key, entry.value.indexOf(slot));
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                      : Text("No availability set."),
                ],
              ),

              Center(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Save Profile",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'GoogleSans',
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
