import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';

class AdminHomePage extends StatefulWidget {
  final String adminId;

  const AdminHomePage({Key? key, required this.adminId}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String adminName = "Admin";
  bool isLoading = true;
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    _fetchAdminName();
  }

  Future<void> _fetchAdminName() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('User')
          .doc(widget.adminId)
          .get();

      if (snapshot.exists) {
        setState(() {
          adminName = snapshot.data()?['userName'] ?? "Admin";
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
  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            color:Colors.black,
            fontFamily: "GoogleSans",
            fontSize: 20,
            fontWeight: FontWeight.w600,

          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            adminName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "GoogleSans",
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "You're managing the \n Dental Wellness App",
                            style: TextStyle(
                              fontFamily: "GoogleSans",
                              fontSize: 14,

                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(width: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/Images/checklist.png',
                          width: 150,
                          height: 150,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

              SizedBox(height: 32),

              // Dashboard Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: "Users",
                    color: Colors.blue[400]!,
                    onTap: () => Navigator.pushNamed(context, '/manageusers'),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                  _buildDashboardCard(
                    context,
                    icon: Icons.medical_services_rounded,
                    title: "Dentists",
                    color: Colors.teal[400]!,
                    onTap: () => Navigator.pushNamed(context, '/managedoctor'),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

                  _buildDashboardCard(
                    context,
                    icon: Icons.calendar_month_rounded,
                    title: "Appointments",
                    color: Colors.purple[400]!,
                    onTap: () => Navigator.pushNamed(context, '/viewappointments'),
                  ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1, end: 0),

                  _buildDashboardCard(
                    context,
                    icon: Icons.person_add_alt_1_rounded,
                    title: "Add Dentists",
                    color: Colors.orange[400]!,
                    onTap: () => Navigator.pushNamed(context, '/doctorregisterpage'),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background for the card
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2), // Lighter version of the color
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color), // Icon in the original color
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                    color: Colors.black, // Black text for better contrast on white
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}