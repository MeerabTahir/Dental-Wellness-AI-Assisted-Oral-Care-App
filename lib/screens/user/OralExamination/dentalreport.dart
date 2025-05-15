import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DentalReport extends StatefulWidget {
  final String detectedDisease;
  final double confidenceScore;
  final Uint8List imageBytes;
  final String patientId;
  final Map<String, String> patientInfo;

  DentalReport({
    required this.detectedDisease,
    required this.confidenceScore,
    required this.imageBytes,
    required this.patientId,
    required this.patientInfo,
  });

  @override
  _DentalReportState createState() => _DentalReportState();
}

class _DentalReportState extends State<DentalReport> {
  String? doctorName;
  String? doctorSpecialization;
  bool loadingDoctor = true;
  bool doctorNotFound = false;
  bool fetchError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Only fetch doctor if disease is not "healthy"
    if (widget.detectedDisease.toLowerCase() != "healthy") {
      fetchRecommendedDoctor();
    } else {
      setState(() {
        loadingDoctor = false;
      });
    }
  }

  Future<void> fetchRecommendedDoctor() async {
    try {
      String specialization = _mapDiseaseToSpecialization(widget.detectedDisease);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('specialization', isEqualTo: specialization)
          .where('profession', isEqualTo: 'Dentist')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        setState(() {
          doctorName = doc['userName'] ?? doc['name'] ?? 'Not available';
          doctorSpecialization = doc['specialization'] ?? 'Not available';
          loadingDoctor = false;
          doctorNotFound = false;
          fetchError = false;
        });
      } else {
        await _fallbackToGeneralDentist();
      }
    } catch (e) {
      setState(() {
        loadingDoctor = false;
        fetchError = true;
        errorMessage = 'Failed to load doctor information. Please try again.';
      });
    }
  }

  Future<void> _fallbackToGeneralDentist() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('specialization', isEqualTo: 'General Dentist')
          .where('profession', isEqualTo: 'Dentist')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        setState(() {
          doctorName = doc['userName'] ?? doc['name'] ?? 'Not available';
          doctorSpecialization = 'General Dentist';
          loadingDoctor = false;
          doctorNotFound = false;
          fetchError = false;
        });
      } else {
        setState(() {
          loadingDoctor = false;
          doctorNotFound = true;
          fetchError = false;
        });
      }
    } catch (e) {
      setState(() {
        loadingDoctor = false;
        fetchError = true;
        errorMessage = 'Failed to load any dentist information.';
      });
    }
  }

  String _mapDiseaseToSpecialization(String disease) {
    String normalizedDisease = disease.toLowerCase().trim();
    switch (normalizedDisease) {
      case 'ulcer':
      case 'mouth ulcer':
        return 'Oral Medicine Specialist';
      case 'caries':
      case 'dental cavity':
        return 'Restorative Dentist';
      case 'oral cancer':
      case 'cancer':
        return 'Oral Oncologist';
      default:
        return 'General Dentist';
    }
  }

  List<String> getPotentialSymptoms() {
    String normalizedDisease = widget.detectedDisease.toLowerCase().trim();
    switch (normalizedDisease) {
      case 'cancer':
        return ['Red or white patches', 'Persistent mouth sore', 'Difficulty swallowing'];
      case 'mouth ulcer':
        return ['Painful sores', 'Swelling inside the mouth', 'Difficulty eating or speaking'];
      case 'dental cavity':
        return ['Toothache', 'Sensitivity to hot/cold', 'Visible holes or pits in teeth'];
      case 'healthy':
        return ['No symptoms detected', 'Oral health appears normal'];
      default:
        return ['No specific symptoms listed.'];
    }
  }

  String getSuggestedAction() {
    String normalizedDisease = widget.detectedDisease.toLowerCase().trim();
    switch (normalizedDisease) {
      case 'cancer':
        return 'Immediate consultation with an oncologist';
      case 'mouth ulcer':
        return 'Consult a dentist if persists beyond two weeks';
      case 'dental cavity':
        return 'Dental filling or cavity treatment recommended';
      case 'healthy':
        return 'Maintain regular oral hygiene and dental check-ups';
      default:
        return 'No specific action recommended';
    }
  }

  String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  String getSeverityLevel(double confidenceScore) {
    double percentage = confidenceScore * 100;
    if (percentage < 40) {
      return 'Low';
    } else if (percentage >= 40 && percentage < 70) {
      return 'Medium';
    } else if (percentage >= 70 && percentage < 95) {
      return 'High';
    } else {
      return 'Very High';
    }
  }

  Color getSeverityColor(double confidenceScore) {
    double percentage = confidenceScore * 100;
    if (percentage < 40) {
      return Colors.green;
    } else if (percentage >= 40 && percentage < 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue, fontFamily: "GoogleSans"),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade400);
  }

  Widget _buildInfoItem(String label, String value, {Color valueColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: "GoogleSans")),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w500, fontSize: 14, fontFamily: "GoogleSans")),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 16, fontFamily: "GoogleSans")),
        Container(child: Text(text, style: TextStyle(fontSize: 14, fontFamily: "GoogleSans"))),
      ],
    );
  }

  Widget _buildTwoColumnRow({required Widget left, required Widget right}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: left),
        SizedBox(width: 24),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildReportHeader() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.local_hospital, color: Colors.blue, size: 48),
          SizedBox(height: 8),
          Text('Oral Scan Report', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "GoogleSans")),
        ],
      ),
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(widget.imageBytes);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('Oral Scan Report', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Divider(),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Patient Information and Image in two columns
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Patient Information:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Name: ${widget.patientInfo['name'] ?? 'N/A'}'),
                    pw.SizedBox(height: 8),
                    pw.Text('Age: ${widget.patientInfo['age'] ?? 'N/A'}'),
                    pw.SizedBox(height: 8),
                    pw.Text('Gender: ${widget.patientInfo['gender'] ?? 'N/A'}'),
                    if (widget.patientInfo['medicalHistory']?.isNotEmpty ?? false)
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 8),
                          pw.Text('Medical History: ${widget.patientInfo['medicalHistory']}'),
                        ],
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 100,
                      width: 100,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey700),
                      ),
                      child: pw.Image(image, fit: pw.BoxFit.cover),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Detected Area', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Report Information Section
          pw.Text('Report Information:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildTableRow('Report Date', getCurrentDate()),
              _buildTableRow('Report Time', getCurrentTime()),
            ],
          ),

          pw.SizedBox(height: 20),

          // Diagnosis Details
          pw.Text('Diagnosis Details:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Detected Condition: ${widget.detectedDisease}'),
          if (widget.detectedDisease.toLowerCase() != 'healthy')
            pw.Bullet(text: 'Severity: ${getSeverityLevel(widget.confidenceScore)}'),


          pw.SizedBox(height: 10),

          // Potential Symptoms
          pw.Text('Potential Symptoms:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...getPotentialSymptoms().map((symptom) => pw.Bullet(text: symptom)),

          pw.SizedBox(height: 10),

          // Suggested Action
          pw.Text('Suggested Action:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(getSuggestedAction(), style: pw.TextStyle(fontSize: 14)),

          // Only show recommended specialist if disease is not "healthy"
          if (widget.detectedDisease.toLowerCase() != "healthy") ...[
            pw.SizedBox(height: 10),
            pw.Text('Recommended Specialist:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Doctor: ${doctorNotFound ? 'No Recommendation' : 'Dr. ${doctorName ?? 'Not available'}'}'),
            pw.Bullet(text: 'Specialization: ${doctorSpecialization ?? 'No Recommendation'}'),
          ],

          pw.SizedBox(height: 20),
          pw.Divider(),

          // Footer Text
          pw.Center(
            child: pw.Text(
              'Generated by Dental Wellness App\nAI-based Early Detection System',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = widget.detectedDisease.toLowerCase() == "healthy";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Oral Scan Report', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.blue,
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => generatePdf(context),
        child: Icon(Icons.picture_as_pdf),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: loadingDoctor && !isHealthy
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            SizedBox(height: 16),
            Text('Finding a specialist for ${widget.detectedDisease}...'),
          ],
        ),
      )
          : fetchError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchRecommendedDoctor,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(),
            SizedBox(height: 32),

            // Patient Information Section
            _buildSectionTitle('Patient Information'),
            _buildDivider(),
            SizedBox(height: 16),
            _buildTwoColumnRow(
              left: _buildInfoItem('Name', widget.patientInfo['name'] ?? 'N/A'),
              right: _buildInfoItem('Age', widget.patientInfo['age'] ?? 'N/A'),
            ),
            SizedBox(height: 10),
            _buildTwoColumnRow(
              left: _buildInfoItem('Gender', widget.patientInfo['gender'] ?? 'N/A'),
              right: widget.patientInfo['medicalHistory']?.isNotEmpty ?? false
                  ? _buildInfoItem('Medical History', widget.patientInfo['medicalHistory']!)
                  : Container(),
            ),
            SizedBox(height: 16),

            // Report Information Section
            _buildSectionTitle('Report Information'),
            _buildDivider(),
            SizedBox(height: 16),
            _buildTwoColumnRow(
              left: _buildInfoItem('Report Time', getCurrentTime()),
              right: _buildInfoItem('Report Date', getCurrentDate()),
            ),
            SizedBox(height: 16),

            // Examination Findings Section
            _buildSectionTitle('Examination Findings'),
            _buildDivider(),
            SizedBox(height: 16),
            _buildTwoColumnRow(
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('Detected Condition', widget.detectedDisease),
                  SizedBox(height: 12),
                ],
              ),
              right: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.detectedDisease.toLowerCase() != 'healthy')
                    _buildInfoItem('Severity', getSeverityLevel(widget.confidenceScore)),

                ],
              ),
            ),
            SizedBox(height: 24),

            // Clinical Presentation Section
            _buildSectionTitle('Clinical Presentation'),
            _buildDivider(),
            SizedBox(height: 16),
            _buildInfoItem('Potential Symptoms', ''),
            SizedBox(height: 0),
            ...getPotentialSymptoms().map((symptom) => _buildBulletPoint(symptom)),
            SizedBox(height: 24),

            // Medical Recommendations Section
            _buildSectionTitle('Medical Recommendations'),
            _buildDivider(),
            SizedBox(height: 16),
            _buildTwoColumnRow(
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('Suggested Action', getSuggestedAction()),
                  SizedBox(height: 12),
                  _buildInfoItem('Preventive Measures', 'Maintain oral hygiene\nAvoid tobacco/alcohol\nRegular check-ups'),
                ],
              ),
              right: isHealthy
                  ? Container() // Empty container if healthy
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('Recommended Specialist', doctorNotFound ? 'No Recommendation' : 'Dr. ${doctorName ?? 'Not available'}'),
                  SizedBox(height: 12),
                  _buildInfoItem('Specialization', doctorSpecialization ?? 'No Recommendation'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}