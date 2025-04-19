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
  String _result = '';
  late Interpreter _interpreter;

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
      print("Loading model...");
      _interpreter = await Interpreter.fromAsset('assets/model/oralcancer_model.tflite');
      print('Model loaded');

      print("Downloading image from Firebase...");
      final response = await http.get(Uri.parse(widget.imageUrl));
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        _imageBytes = response.bodyBytes;
        setState(() => _result = 'Processing...');
        await _runModel(response.bodyBytes);
      } else {
        setState(() => _result = 'Failed to load image');
      }
    } catch (e) {
      print('Error loading model/image: $e');
      setState(() => _result = 'Error loading model or image');
    }
  }

  Future<void> _runModel(Uint8List imageBytes) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        setState(() => _result = 'Invalid image');
        return;
      }

      final resizedImage = img.copyResize(image, width: 224, height: 224);
      final input = List.generate(224, (y) => List.generate(224, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [
          img.getRed(pixel).toDouble(),
          img.getGreen(pixel).toDouble(),
          img.getBlue(pixel).toDouble()
        ];
      }));

      // Reshape to [1, 224, 224, 3]
      var inputTensor = [input];

      // Output should be shape [1, 1]
      var output = List.filled(1 * 1, 0.0).reshape([1, 1]);

      _interpreter.run(inputTensor, output);

      double confidence = output[0][0];
      double cancerProbability = 1.0 - confidence;
      String label = confidence > 0.5 ? 'No Cancer Detected' : 'Cancer Detected';

      setState(() {
        _result = '${label}\nProbability of Cancer: ${(cancerProbability * 100).toStringAsFixed(2)}%\nProbability of Non-Cancer: ${(confidence * 100).toStringAsFixed(2)}%';
      });
    } catch (e) {
      print('Error running model: $e');
      setState(() => _result = 'Error during model inference');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Model Result'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _imageBytes == null
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(_imageBytes!, width: 250),
              SizedBox(height: 20),
              Text(_result, style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
