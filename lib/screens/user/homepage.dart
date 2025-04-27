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
                      imageHeight:double.infinity,
                      imageWidth: double.infinity,
                      boxFit: BoxFit.fitHeight,
                    ),
                    buildSimpleCarouselCard(
                      text: "Detect Oral Diseases Early – Visit Us Today!",
                      color: Colors.blue.shade400,
                      imagePath: "assets/Images/diseases.png",
                      imageHeight: double.infinity,
                      imageWidth: double.infinity,
                      boxFit: BoxFit.fitHeight,
                    ),
                    buildSimpleCarouselCard(
                      text: "Book Appointments Easily & On Time",
                      color: Colors.teal.shade400,
                      imagePath: "assets/Images/Picture1.png",
                      imageHeight: double.infinity,
                      imageWidth: 500,
                      boxFit: BoxFit.fitWidth,
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
                              "Oral \nExamination", '/patient', Colors.orange),
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
                          .limit(4)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "No dentists available at the moment.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: 'GoogleSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        var doctorDocs = snapshot.data!.docs;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: doctorDocs.length,
                          itemBuilder: (context, index) {
                            var doc = doctorDocs[index];
                            String name = doc['userName'] ?? 'Unknown';
                            String specialization = doc['specialization'] ?? 'Dentist';
                            String location = doc['location'] ?? 'Location not specified';
                            String imageUrl = doc['profileImage'] ?? 'https://via.placeholder.com/150';

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/desc', arguments: {'doctorId': doc.id});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Image
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: NetworkImage(imageUrl),
                                          child: imageUrl.isEmpty
                                              ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                                              : null,
                                        ),
                                      ),
                                    ),

                                    // Content area with fixed constraints
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Name
                                          Center(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'GoogleSans',
                                                color: Colors.blue[900],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: 4),

                                          // Specialization
                                          Center(
                                            child: Text(
                                              specialization,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'GoogleSans',
                                                color: Colors.blue[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: 4),

                                          // Location
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  location,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: 'GoogleSans',
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),

                                          // Button
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            child: Center(
                                              child: Text(
                                                'View Profile',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'GoogleSans',
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),


                    SizedBox(height: 30),
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    FAQTile(
                      question: 'How can I book an appointment?',
                      answer: 'Go to Book Appointment section, select your dentist and choose a suitable time slot.',
                    ),
                    FAQTile(
                      question: 'Can I consult online?',
                      answer: 'Yes! Some dentists offer online consultations. Check the profile details before booking.',
                    ),
                    FAQTile(
                      question: 'How do I detect oral diseases early?',
                      answer: 'Regular checkups and early screenings are the best ways to detect oral issues early.',
                    ),
                    FAQTile(
                      question: 'Is my information secure?',
                      answer: 'Absolutely! We prioritize user privacy and data security at all times.',
                    ),
                    SizedBox(height: 20),

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
    double imageHeight = 80,
    double imageWidth = 80,
    BoxFit boxFit = BoxFit.contain,
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
                alignment: Alignment.center, // changed to center
                child: Image.asset(
                  imagePath,
                  width: imageWidth,   // <-- custom width
                  height: imageHeight, // <-- custom height
                  fit: boxFit, // contain to avoid stretching
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
      borderRadius: BorderRadius.circular(16),
      splashColor: iconColor.withOpacity(0.2),
      highlightColor: iconColor.withOpacity(0.1),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor,
                    Color.lerp(iconColor, Colors.black, 0.1)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "GoogleSans",
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget FAQTile({required String question, required String answer}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              fontFamily: 'GoogleSans',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                answer,
                style: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
          iconColor: Colors.grey[600],
          collapsedIconColor: Colors.grey[600],
          tilePadding: EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
