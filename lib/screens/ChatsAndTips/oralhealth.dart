import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class OralHealthTipsPage extends StatefulWidget {
  @override
  _OralHealthTipsPageState createState() => _OralHealthTipsPageState();
}

class _OralHealthTipsPageState extends State<OralHealthTipsPage> {
  String selectedPain = 'Toothache';
  String selectedIssue = 'Cavity';
  int painIntensity = 3;

  List<String> pains = ['Toothache', 'Gum Pain', 'Jaw Pain'];
  List<String> issues = ['Cavity', 'Sensitivity', 'Bleeding Gums'];

  List<charts.Series<PainData, String>> _createSampleData() {
    final data = [
      PainData('Low', painIntensity > 1 ? 1 : painIntensity),
      PainData('Medium', painIntensity > 3 ? 2 : (painIntensity - 1)),
      PainData('High', painIntensity > 5 ? 3 : (painIntensity - 3)),
    ];

    return [
      charts.Series<PainData, String>(
        id: 'Pain',
        domainFn: (PainData pain, _) => pain.level,
        measureFn: (PainData pain, _) => pain.intensity,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        title: Text('Oral Health Tips', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdowns for pain and issue selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedPain,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPain = newValue!;
                        });
                      },
                      items: pains.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedIssue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedIssue = newValue!;
                        });
                      },
                      items: issues.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Slider(
                value: painIntensity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: painIntensity.toString(),
                onChanged: (double newValue) {
                  setState(() {
                    painIntensity = newValue.toInt();
                  });
                },
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: charts.BarChart(
                  _createSampleData(),
                  animate: true,
                ),
              ),
              SizedBox(height: 16),
              ..._getTips(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/doctor');
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.cyan, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Consult a Doctor', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getTips() {
    List<Widget> tips = [];

    if (selectedPain == 'Toothache') {
      tips.add(_buildTipCard(
          icon: Icons.local_hospital,
          title: 'For Toothache',
          tip: 'Use a cold compress on the affected area to alleviate pain. Rinse with warm salt water to clean the affected area.'
      ));
    } else if (selectedPain == 'Gum Pain') {
      tips.add(_buildTipCard(
          icon: Icons.healing,
          title: 'For Gum Pain',
          tip: 'Gently brush your gums with a soft-bristled toothbrush. Use an antiseptic mouthwash to reduce inflammation.'
      ));
    } else if (selectedPain == 'Jaw Pain') {
      tips.add(_buildTipCard(
          icon: Icons.mood_bad,
          title: 'For Jaw Pain',
          tip: 'Apply a warm compress to your jaw to relax the muscles. Avoid chewing gum or hard foods.'
      ));
    }

    if (selectedIssue == 'Cavity') {
      tips.add(_buildTipCard(
          icon: Icons.local_hospital,
          title: 'For Cavities',
          tip: 'Use fluoride toothpaste and avoid sugary foods. Regularly visit your dentist for check-ups.'
      ));
    } else if (selectedIssue == 'Sensitivity') {
      tips.add(_buildTipCard(
          icon: Icons.sick,
          title: 'For Sensitivity',
          tip: 'Use toothpaste designed for sensitive teeth and avoid very hot or cold foods and drinks.'
      ));
    } else if (selectedIssue == 'Bleeding Gums') {
      tips.add(_buildTipCard(
          icon: Icons.bloodtype,
          title: 'For Bleeding Gums',
          tip: 'Brush gently with a soft-bristled toothbrush and use an antibacterial mouthwash. Consult your dentist for persistent issues.'
      ));
    }

    if (painIntensity > 4) {
      tips.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'High pain intensity detected. If the pain persists, please consult a dentist immediately.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ));
    }

    return tips;
  }

  Widget _buildTipCard({required IconData icon, required String title, required String tip}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.cyan),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(tip),
      ),
    );
  }
}

class PainData {
  final String level;
  final int intensity;

  PainData(this.level, this.intensity);
}
