import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OralExaminationScreen extends StatefulWidget {
  @override
  _OralExaminationScreenState createState() => _OralExaminationScreenState();
}

class _OralExaminationScreenState extends State<OralExaminationScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _isMouthDetected = false;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      bool mouthDetected = await _isMouthPresent(image);
      setState(() {
        _isMouthDetected = mouthDetected;
        _imageFile = mouthDetected ? image : null;
      });
      if (!mouthDetected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No mouth detected! Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _isMouthPresent(File image) async {
    final inputImage = InputImage.fromFile(image);
    final faces = await _faceDetector.processImage(inputImage);

    for (Face face in faces) {
      if (face.contours[FaceContourType.lowerLipBottom] != null &&
          face.contours[FaceContourType.upperLipTop] != null) {
        return true;
      }
    }
    return false;
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null && _isMouthDetected) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Upload to Firebase Storage
        String fileName = 'oral_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save URL to Firestore
        await FirebaseFirestore.instance.collection('Oral Image').add({
          'imageUrl': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _imageFile = null;
          _isMouthDetected = false;
          _isUploading = false;
        });

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
          content: Text('Please take a valid mouth picture!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
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
      body: Column(
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
                      Center(
                        child: ElevatedButton(
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
          Spacer(),
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
