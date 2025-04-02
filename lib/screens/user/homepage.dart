import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/screens/user/patientProfile.dart';
import '../login.dart';
import '../footer.dart';
import './feedback.dart'; // Import Feedback Screen

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
        } else {
          print('User document does not exist');
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Homepage',
          style: TextStyle(fontFamily: 'GoogleSans'),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
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
                    style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'GoogleSans'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Do oral examinations and consult our best dentists.',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'GoogleSans'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('Articles', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
                Navigator.pushNamed(context, '/articles');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback', style: TextStyle(fontFamily: 'GoogleSans')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout', style: TextStyle(fontFamily: 'GoogleSans')),
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
      body: Container(
        color: Colors.white,
        height: height,
        width: width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                width: width - 32,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? 'Hello, $userName!' : 'Hello!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'GoogleSans'),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Welcome to the Dental',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: "GoogleSans"),
                          ),
                          Text(
                            'Wellness you get all',
                            style: TextStyle(fontSize: 16, color: Colors.white,fontFamily: "GoogleSans"),
                          ),
                          Text(
                            'services here.',
                            style: TextStyle(fontSize: 16, color: Colors.white,fontFamily: "GoogleSans"),
                          )],
                      ),
                      Spacer(),
                      Image.asset(
                        'assets/Images/dentisthomes.png',
                        height: 100,
                        width: 150,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16),
                        children: [
                          buildFeatureTile(context, Icons.calendar_today, "Book Appointment", '/doctor', Colors.blue.shade200),
                          buildFeatureTile(context, Icons.list_alt, "My Appointments", '/schedule', Colors.pink.shade200),
                          buildFeatureTile(context, Icons.health_and_safety, "Oral Examination", '/oralexamination', Colors.purple.shade200),
                          buildFeatureTile(context, Icons.chat, "Ask Questions", '/questions', Colors.orange.shade200),

                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterScreen(),
    );
  }

  Widget buildFeatureTile(BuildContext context, IconData icon, String title, String route, Color cardColor) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
