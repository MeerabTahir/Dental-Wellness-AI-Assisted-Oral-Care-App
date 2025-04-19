import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tooth_tales/screens/user/homepage.dart';
import 'ChatsAndTips/chat.dart';
import 'login.dart';
import 'user/Profile/patientProfile.dart';

class FooterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}