import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import './modelProcessing.dart';
import 'package:image_cropper/image_cropper.dart';

class OralExaminationScreen extends StatefulWidget {
  final Map<String, String> patientInfo;

  OralExaminationScreen({required this.patientInfo});

  @override
  _OralExaminationScreenState createState() => _OralExaminationScreenState();
}

class _OralExaminationScreenState extends State<OralExaminationScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  void _deleteImage() {
    setState(() {
      _imageFile = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image removed'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _uploadImage() async {
    String? userId = getCurrentUserId();

    if (_imageFile != null && userId != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String fileName = 'oral_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);

        UploadTask uploadTask = ref.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('Oral Images').add({
          'imageUrl': downloadUrl,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isUploading = false;
          _imageFile = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModelProcessingScreen(
              imageUrl: downloadUrl,
              patientInfo: widget.patientInfo,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please take a valid mouth picture or log in!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        _imageFile = File(croppedFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking or cropping image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Oral Examination',
          style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Oral Examination Steps',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'GoogleSans'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Follow these steps to take a picture of your oral cavity for examination:',
                    style: TextStyle(fontSize: 16, fontFamily: 'GoogleSans', color: Colors.blue),
                  ),
                  SizedBox(height: 12),
                  _buildStep('1. Open your mouth wide to expose your teeth and gums.'),
                  _buildStep('2. Ensure the light is sufficient to capture a clear image.'),
                  _buildStep('3. Hold the camera steady for a clear picture.'),
                  _buildStep('4. Take a picture and check the image for clarity.'),
                  _buildStep('5. Crop the image to focus on disease.'),
                  SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage(ImageSource.camera),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.blue.shade50,
                                child: _imageFile == null
                                    ? Icon(Icons.camera_alt, size: 50, color: Colors.blue)
                                    : ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    _imageFile!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (_imageFile != null)
                              IconButton(
                                icon: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close, size: 20, color: Colors.white),
                                ),
                                onPressed: _deleteImage,
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text("OR", style: TextStyle(fontFamily: 'GoogleSans', fontSize: 18)),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Text(
                            'Choose from Gallery',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _imageFile == null || _isUploading ? null : _uploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: TextStyle(fontSize: 16, fontFamily: 'GoogleSans'),
                          ),
                          child: _isUploading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Submit', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              width: double.infinity,
              child: Text(
                '© 2025 Oral Care App. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontFamily: 'GoogleSans', color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String stepText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(stepText, style: TextStyle(fontSize: 16, fontFamily: 'GoogleSans')),
          ),
        ],
      ),
    );
  }
}