import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tooth_tales/screens/user/Profile/patientProfile.dart';

import '../login.dart';
import '../footer.dart';
import 'Feedback & Query/feedback.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 0,
        centerTitle: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Your',
                style: TextStyle(fontFamily: 'GoogleSans', fontSize: 22)),
            Text(' Dentist',
                style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isNotEmpty ? 'Hello, $userName!' : 'Hello!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'GoogleSans'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Do oral examinations and consult our best dentists.',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'GoogleSans'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title:
              Text('Articles', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
                Navigator.pushNamed(context, '/articles');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title:
              Text('Profile', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title:
              Text('Feedback', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title:
              Text('Logout', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
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
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          color: Colors.grey[50],
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 160,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.96,
                    autoPlayInterval: Duration(seconds: 3),
                  ),
                  items: [
                    buildSimpleCarouselCard(
                      text: "You are Looking for your Desired Dentist?",
                      color: Colors.orangeAccent.shade400,
                      imagePath: "assets/Images/doctor1.png",
                    ),
                    buildSimpleCarouselCard(
                      text: "Detect Oral Diseases Early – Visit Us Today!",
                      color: Colors.red.shade400,
                      imagePath: "assets/Images/mouth.png",
                    ),
                    buildSimpleCarouselCard(
                      text: "Book Appointments Easily & On Time",
                      color: Colors.teal.shade400,
                      imagePath: "assets/Images/newappoint.png",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Categories',
                        style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          buildFeatureTile(context, Icons.calendar_today,
                              "Book \nAppointment", '/doctor', Colors.blueAccent),
                          SizedBox(width: 12),
                          buildFeatureTile(context, Icons.list_alt,
                              "My \nAppointments", '/schedule', Colors.pinkAccent),
                          SizedBox(width: 12),
                          buildFeatureTile(context, Icons.health_and_safety,
                              "Oral \nExamination", '/oralexamination', Colors.orange),
                          SizedBox(width: 12),
                          buildFeatureTile(context, Icons.chat,
                              "Ask \nQuestions", '/questions', Colors.deepPurple),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Our Dentists',
                            style: TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/doctor');
                          },
                          child: Text('See All',
                              style: TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontSize: 14,
                                  color: Colors.blue)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('isDoctor', isEqualTo: true)
                          .limit(4) // Show just a few for preview
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No dentists available.");
                        }

                        var doctorDocs = snapshot.data!.docs;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: doctorDocs.length,
                          itemBuilder: (context, index) {
                            var doc = doctorDocs[index];
                            String name = doc['userName'] ?? 'Unknown';
                            String specialization = doc['specialization'] ?? 'Dentist';
                            String location= doc['location'] ?? 'Location Not specified';
                            String imageUrl = doc['profileImage'] ?? 'https://via.placeholder.com/150';

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/desc', arguments: {'doctorId': doc[index].id,});
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: NetworkImage(imageUrl),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'GoogleSans',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      specialization,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontFamily: 'GoogleSans',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      location,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontFamily: 'GoogleSans',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FooterScreen(),
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

  Widget buildFeatureTile(BuildContext context, IconData icon, String title,
      String route, Color iconColor) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
