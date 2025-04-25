import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelProcessingScreen extends StatefulWidget {
  final String imageUrl;

  ModelProcessingScreen({required this.imageUrl});

  @override
  _ModelProcessingScreenState createState() => _ModelProcessingScreenState();
}

class _ModelProcessingScreenState extends State<ModelProcessingScreen> {
  Uint8List? _imageBytes;
  String result = '';
  late Interpreter _Interpreter;

  @override
  void initState() {
    super.initState();
    _loadModelAndImage();
  }

  @override
  void dispose() {
    _Interpreter.close();
    super.dispose();
  }

  Future<void> _loadModelAndImage() async {
    try {
      print("Loading ResNet model...");
      _Interpreter = await Interpreter.fromAsset('assets/model/disease_model.tflite');
      print("Model loaded.");

      print("Downloading image...");
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        _imageBytes = response.bodyBytes;
        setState(() => result = 'Processing...');
        await _runModel(_imageBytes!);
      } else {
        setState(() => result = 'Failed to load image.');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => result = 'Error loading model or image.');
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        result = 'Invalid image.';
        return;
      }

      final resizedImage = img.copyResize(image, width: 224, height: 224);
      final input = List.generate(224, (y) =>
          List.generate(224, (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              img.getRed(pixel).toDouble() / 255.0,
              img.getGreen(pixel).toDouble() / 255.0,
              img.getBlue(pixel).toDouble() / 255.0,
            ];
          }));

      var inputTensor = [input]; // [1, 224, 224, 3]
      var output = List.filled(1 * 5, 0.0).reshape([1, 5]);

      _Interpreter.run(inputTensor, output);

      List<double> probabilities = output[0];
      List<String> classLabels = [
        'Gingivitis',
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
        resultBuffer.writeln(
            'Oral Diagnosis:\nDetected: ${classLabels[maxIndex]}');
      } else {
        resultBuffer.writeln('Oral Diagnosis:\nNo dental issue detected');
      }

      // Show full probability breakdown
      resultBuffer.writeln('\nConfidence Scores:');
      for (int i = 0; i < classLabels.length; i++) {
        resultBuffer.writeln(
            '${classLabels[i]}: ${(probabilities[i] * 100).toStringAsFixed(2)}%');
      }

      setState(() {
        result = resultBuffer.toString();
      });
    } catch (e) {
      print('Error running model: $e');
      setState(() {
        result = 'Error during inference.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Model Result'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _imageBytes == null
              ? CircularProgressIndicator()
              : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.memory(_imageBytes!, width: 250),
                SizedBox(height: 20),
                Text(
                  result,
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
