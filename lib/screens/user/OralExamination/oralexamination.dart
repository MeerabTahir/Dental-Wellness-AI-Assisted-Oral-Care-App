import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import './modelProcessing.dart';
import 'package:image_cropper/image_cropper.dart';

class OralExaminationScreen extends StatefulWidget {
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

  Future<void> _uploadImage() async {
    String? userId = getCurrentUserId();

    print('Uploading image. User ID: $userId, Image file: $_imageFile');

    if (_imageFile != null && userId != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String fileName = 'oral_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        print('Uploading to Firebase storage with filename: $fileName');

        UploadTask uploadTask = ref.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        print('Image uploaded successfully. Download URL: $downloadUrl');

        await FirebaseFirestore.instance.collection('Oral Images').add({
          'imageUrl': downloadUrl,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Firestore document added with image URL');

        setState(() {
          _isUploading = false;
          _imageFile = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModelProcessingScreen(imageUrl: downloadUrl),
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
        print('Error during upload: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Error: No image selected or user is not logged in.');
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
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          ]
      );

      if (croppedFile == null) return;

      setState(() {
        _imageFile = File(croppedFile.path);
      });
    } catch (e) {
      print('Error picking or cropping image: $e');
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
                  SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade50,
                            child: _imageFile == null
                                ? Icon(Icons.camera_alt, size: 50, color: Colors.blue)
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _uploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: TextStyle(fontSize: 16, fontFamily: 'GoogleSans'),
                          ),
                          child: _isUploading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Upload Picture', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: 16),
                        Text('OR', style: TextStyle(fontSize: 16, fontFamily: 'GoogleSans', color: Colors.grey)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: TextStyle(fontSize: 16, fontFamily: 'GoogleSans'),
                          ),
                          child: Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
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