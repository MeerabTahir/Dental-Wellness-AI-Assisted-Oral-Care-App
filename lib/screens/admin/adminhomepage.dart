import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../footer.dart';
import 'package:intl/intl.dart';

import '../login.dart';

class AdminHomePage extends StatefulWidget {
  final String adminId;

  const AdminHomePage({Key? key, required this.adminId}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String adminName = "John Doe";
  bool isLoading = true;
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    _fetchAdminName();
    _getCurrentDate();
  }

  Future<void> _fetchAdminName() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.adminId)
          .get();

      if (snapshot.exists) {
        setState(() {
          adminName = snapshot.data()?['userName'] ?? "John Doe";
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching admin name: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat dateFormat = DateFormat("MM-dd-yyyy EEEE");
    setState(() {
      currentDate = dateFormat.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Welcome Back",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "GoogleSans",
            fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                }).catchError((e) {
                  print('Error signing out: $e');
                });
              },
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show current date with calendar icon
            currentDate.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "GoogleSans",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.black.withOpacity(0.2),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, $adminName!",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: "GoogleSans",
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "You're managing the Dental Wellness App.",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "GoogleSans",
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/Images/checklist.png',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildCard(
                    color: Colors.blue.shade200,
                    icon: Icons.people,
                    title: "Users",
                    onTap: () {
                      Navigator.pushNamed(context, '/manageusers');
                    },
                  ),
                  _buildCard(
                    color: Colors.pink.shade200,
                    icon: Icons.local_hospital,
                    title: "Dentists",
                    onTap: () {
                      Navigator.pushNamed(context, '/managedoctor');
                    },
                  ),
                  _buildCard(
                    color: Colors.purple.shade200,
                    icon: Icons.calendar_today,
                    title: "Appointments",
                    onTap: () {
                      Navigator.pushNamed(context, '/viewappointments');
                    },
                  ),
                  _buildCard(
                    color: Colors.orange.shade200,
                    icon: Icons.add,
                    title: "Add Dentists",
                    onTap: () {
                      Navigator.pushNamed(context, '/doctorregisterpage');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 60),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: "GoogleSans",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _logout(BuildContext context) {
  //   Navigator.pop(context); // Example: Navigate back to the login screen
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Logged out successfully")),
  //   );
  // }
}
