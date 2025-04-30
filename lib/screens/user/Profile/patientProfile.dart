import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userNameController.text = userData['userName'] ?? '';
          _dobController.text = userData['dateOfBirth'] ?? '';
          _gender = userData['gender'] ?? 'Male';
          _imageUrl = userData['imageUrl'];
        });
      }
    } catch (e) {
      _showCustomSnackBar(context, 'Error loading profile: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_userNameController.text.isEmpty) {
      _showCustomSnackBar(context, 'Please enter a username', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    String? imageUrl = _imageUrl;

    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
      if (imageUrl == null) {
        _showCustomSnackBar(context, 'Image upload failed', Colors.red);
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'userName': _userNameController.text,
        'dateOfBirth': _dobController.text,
        'gender': _gender,
        'imageUrl': imageUrl,
      });

      _showCustomSnackBar(context, 'Profile updated successfully!', Colors.green);
    } catch (e) {
      _showCustomSnackBar(context, 'Error updating profile: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference =
      FirebaseStorage.instance.ref().child('user_profiles/$userId.jpg');

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 18,fontFamily: "GoogleSans")),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.shade100,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue.shade50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : AssetImage('assets/Images/avatar.png') as ImageProvider,
                    child: _imageFile == null && _imageUrl == null
                        ? Icon(Icons.person, size: 70, color: Colors.blue)
                        : null,
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.blue.shade700,
                  onPressed: _pickImage,
                  child: Icon(Icons.camera_alt, size: 20,color: Colors.white,),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Profile Form Section
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  // Username Field
                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Date of Birth Field
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.cake, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 20),

                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: ['Male', 'Female', 'Other']
                        .map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.male, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Update Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSnackBar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
