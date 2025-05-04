import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dentalreport.dart';

class ModelProcessingScreen extends StatefulWidget {
  final Map<String, String> patientInfo;
  final String imageUrl;

  const ModelProcessingScreen({required this.imageUrl, required this.patientInfo});

  @override
  _ModelProcessingScreenState createState() => _ModelProcessingScreenState();
}

class _ModelProcessingScreenState extends State<ModelProcessingScreen> {
  Uint8List? _imageBytes;
  String result = '';
  late Interpreter _interpreter;
  String? _detectedDisease;
  double? _confidenceScore;

  final Map<String, String> diseaseDescriptions = {
    'Mouth Ulcer': 'Mouth ulcers are small, painful sores inside the mouth caused by irritation, stress, or certain infections.',
    'Dental Cavity': 'Dental cavities are permanently damaged areas in teeth caused by decay, often due to poor brushing habits.',
    'Healthy': 'No dental issues detected. Your oral health looks good!',
    'Cancer': 'Oral cancer refers to uncontrollable growth of cells in the mouth area that can be life-threatening if not treated early.'
  };

  @override
  void initState() {
    super.initState();
    _loadModelAndImage();
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  Future<void> _loadModelAndImage() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/mobilenet_oral_diseases.tflite');
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        _imageBytes = response.bodyBytes;
        setState(() => result = 'Processing...');
        await _runModel(_imageBytes!);
      } else {
        setState(() => result = 'Failed to load image.');
      }
    } catch (e) {
      setState(() => result = 'Error loading model or image: $e');
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        setState(() => result = 'Invalid image.');
        return;
      }

      final resizedImage = img.copyResize(image, width: 224, height: 224);
      final input = List.generate(224, (y) =>
          List.generate(224, (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          }));

      var inputTensor = [input];
      var output = List.filled(1 * 4, 0.0).reshape([1, 4]);

      _interpreter.run(inputTensor, output);

      List<double> probabilities = output[0];
      List<String> classLabels = [
        'Mouth Ulcer',
        'Dental Cavity',
        'Healthy',
        'Cancer'
      ];

      int maxIndex = probabilities.indexWhere((p) =>
      p == probabilities.reduce((a, b) => a > b ? a : b));
      double maxConfidence = probabilities[maxIndex];

      StringBuffer resultBuffer = StringBuffer();
      if (maxConfidence > 0.5 && classLabels[maxIndex] != 'Healthy') {
        resultBuffer.writeln('${classLabels[maxIndex]}');
        _detectedDisease = classLabels[maxIndex];
        _confidenceScore = maxConfidence;
      } else {
        resultBuffer.writeln('No dental issue detected');
        _detectedDisease = 'Healthy';
        _confidenceScore = maxConfidence;
      }

      resultBuffer.writeln('\nConfidence Scores:');
      for (int i = 0; i < classLabels.length; i++) {
        resultBuffer.writeln('${classLabels[i]}: ${(probabilities[i] * 100).toStringAsFixed(2)}%');
      }

      setState(() {
        result = resultBuffer.toString();
      });
    } catch (e) {
      setState(() {
        result = 'Error during inference: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Oral Scan Results', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageBytes == null)
                Column(
                  children: [
                    CircularProgressIndicator(color: Colors.blue, strokeWidth: 4),
                    SizedBox(height: 20),
                    Text(
                      'Loading image & model...',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else ...[
                Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Diagnosis Result',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'GoogleSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Divider(color: Colors.blue.shade300, thickness: 1),
                      SizedBox(height: 16),
                      Text(
                        "Detected",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontFamily: 'GoogleSans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _detectedDisease ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey.shade800,
                          fontFamily: 'GoogleSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      if (_confidenceScore != null)
                        Text(
                          "Confidence: ${(_confidenceScore! * 100).toStringAsFixed(2)}%",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blueGrey,
                            fontFamily: 'GoogleSans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 12),
                      Text(
                        diseaseDescriptions[_detectedDisease ?? 'Healthy'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'GoogleSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Icon(Icons.medical_services, color: Colors.blue.shade300, size: 36),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                if (_detectedDisease != null && _confidenceScore != null && _imageBytes != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DentalReport(
                            detectedDisease: _detectedDisease!,
                            confidenceScore: _confidenceScore!,
                            imageBytes: _imageBytes!,
                            patientInfo: widget.patientInfo,
                            patientId: '', // Pass patient info here
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    child: Text(
                      'Generate Detailed Report',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
    );
  }
}