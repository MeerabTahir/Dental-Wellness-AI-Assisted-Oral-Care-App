import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String label;
  final String confidence;

  const ResultScreen({required this.label, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagnosis Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Diagnosis:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('Confidence: $confidence%', style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
