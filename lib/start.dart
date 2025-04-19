import 'package:flutter/material.dart';
import 'package:tooth_tales/screens/login.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,  // Ensures the container takes full width
        height: double.infinity, // Ensures the container takes full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade300, Colors.blue.shade800],
          ),
        ),
        child: Center(  // Ensures the entire content is centered
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Center Icon and App Name
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/Images/toothstart.png",
                      width:500,
                      height: 250,
                    ),
                    // SizedBox(height: 10),
                    Text(
                      "Dental Wellness",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        fontFamily: "GoogleSans",
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom Section: Description and Button
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Find your best Dentists",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "GoogleSans",
                      ),
                    ),
                    Text(
                      "without wasting time",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "GoogleSans",
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,  // Background color of button
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontFamily: "GoogleSans",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}