import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import '../login.dart';
import 'All Appointments/appointmentsPage.dart';
import 'Change Password/changepassword.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({Key? key}) : super(key: key);

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = '';
  String? imageUrl;
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('userName');
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treat Your',
                style: TextStyle(fontFamily: 'GoogleSans', fontSize: 22)),
            Text(' Patient',
                style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 160,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.98,
                  autoPlayInterval: Duration(seconds: 3),
                ),
                items: [
                  buildSimpleCarouselCard(
                    text: "Provide treatment to the Dental Patient",
                    color: Colors.orangeAccent.shade400,
                    imagePath: "assets/Images/dentalpatient.png",
                  ),
                  buildSimpleCarouselCard(
                    text: "Answer the little Queries of the Users",
                    color: Colors.purpleAccent.shade400,
                    imagePath: "assets/Images/queries.png",
                  ),
                  buildSimpleCarouselCard(
                    text: "Manage all Appointments Easily & On Time",
                    color: Colors.teal.shade400,
                    imagePath: "assets/Images/newappoint.png",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Welcome Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  userName.isNotEmpty ? 'Hello, Dr. $userName!' : 'Hello!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "GoogleSans"),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Manage appointments and queries easily.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Action Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                children: [
                  _buildDashboardTile(
                    icon: Icons.calendar_today,
                    label: "Appointments",
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppointmentsPage()),
                    ),
                  ),
                  _buildDashboardTile(
                    icon: Icons.question_answer,
                    label: "Patient Queries",
                    color: Colors.pinkAccent,
                    onTap: () => Navigator.pushNamed(context, '/dentist-queries'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildSimpleCarouselCard({
    required String text,
    required Color color,
    required String imagePath,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "GoogleSans",
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : const AssetImage('assets/Images/avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: "GoogleSans"),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile', style: TextStyle(fontFamily: "GoogleSans")),
            onTap: () => Navigator.pushNamed(context, '/doctor-profile'),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password', style: TextStyle(fontFamily: "GoogleSans")),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(fontFamily: "GoogleSans")),
            onTap: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: "GoogleSans"),
            ),
          ],
        ),
      ),
    );
  }
}
