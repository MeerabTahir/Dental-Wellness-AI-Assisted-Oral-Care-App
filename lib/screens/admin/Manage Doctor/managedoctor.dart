import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageDoctorsPage extends StatefulWidget {
  @override
  _ManageDoctorsPageState createState() => _ManageDoctorsPageState();
}

class _ManageDoctorsPageState extends State<ManageDoctorsPage> {
  bool isLoading = true; // Flag for loading indicator
  List<Map<String, dynamic>> doctors = []; // List to store doctor data

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDoctor', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctors = snapshot.docs.map((doc) {
            final data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList();
          isLoading = false; // Set loading to false once data is fetched
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching doctors: $error");
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  // Function to show Delete Dialog
  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this doctor?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Implement your delete logic here
              try {
                await FirebaseFirestore.instance.collection('users').doc(docId).delete();
                setState(() {
                  doctors.removeWhere((doctor) => doctor['docId'] == docId);
                });
                Navigator.of(context).pop();
              } catch (e) {
                print("Error deleting doctor: $e");
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorItem(Map<String, dynamic> doctor) {
    String? imageUrl = doctor['profileImage']; // Image URL from Firestore
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.blue.shade50.withOpacity(0.2),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 35,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage('assets/Images/avatar.png') as ImageProvider,
            child: imageUrl == null || imageUrl.isEmpty
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          // Doctor Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. ${doctor['userName'] ?? 'No Name'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${doctor['specialization'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${doctor['location'] ?? 'No Location Provided'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: "GoogleSans",
                  ),
                ),
              ],
            ),
          ),
          // Delete Icon
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(doctor['docId']);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage Dentists",
          style: TextStyle(fontFamily: "GoogleSans", fontSize: 16, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/Images/dentals.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Center(
              child: const Text(
                "All Dentists",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "GoogleSans",
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: const Text(
                "You can see all dentists here.",
                style: TextStyle(fontSize: 16, fontFamily: "GoogleSans"),
              ),
            ),
            const SizedBox(height: 16),
            doctors.isEmpty
                ? const Center(
              child: Text(
                "No dentists found",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "GoogleSans"),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorItem(doctors[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
