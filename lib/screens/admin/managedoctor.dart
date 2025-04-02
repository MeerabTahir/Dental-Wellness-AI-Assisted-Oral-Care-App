import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/screens/user/desc.dart'; // Import for detail page

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
          doctors = snapshot.docs.map((doc) => doc.data()).toList();
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
                  doctors.removeWhere((doctor) => doctor['id'] == docId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,size: 18,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Manage Dentists",
          style: TextStyle(fontFamily: "GoogleSans", fontSize: 16, color: Colors.white),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading spinner
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/Images/dentals.png',
                width: 500,
                height: 250,
              ),
              const SizedBox(height: 10),
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

              // Table (List of Dentists)
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
                    final doctor = doctors[index];
                    return Card(
                      elevation: 8, // Adding a slight shadow for visual appeal
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person, color: Colors.blue, size: 30),
                        ),
                        title: Text(
                          "Dr. ${doctor['userName'] ?? 'No Name'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GoogleSans",
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${doctor['profession'] ?? 'N/A'}", // Specialty
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "GoogleSans",
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4), // Spacer between specialty and location
                            Text(
                              "${doctor['location'] ?? 'No Location Provided'}", // Location
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "GoogleSans",
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(doctor['id']); // Show delete dialog
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
