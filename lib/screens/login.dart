import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/reusable_widgets/reusable_widget.dart';
import 'package:tooth_tales/screens/signup.dart';
import 'package:tooth_tales/screens/user/homepage.dart';
import 'package:tooth_tales/screens/doctor/doctorHomePage.dart';
import 'admin/adminhomepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.15, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Login to your account and",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "GoogleSans",
                  ),
                ),
                Text(
                  "start your dental health experience.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "GoogleSans",
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  "assets/Images/dentistss.png",
                  width: 500,
                ),
                SizedBox(height: 20),
                ReusableTextField(
                  text: "Enter Email",
                  icon: Icons.email_outlined,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                SizedBox(height: 20),
                ReusableTextField(
                  text: "Enter Password",
                  icon: Icons.lock_outlined,
                  isPasswordType: true,
                  controller: _passwordTextController,
                ),
                // SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontFamily: 'GoogleSans'),
                    ),
                  ),
                ),
                SizedBox(height: 3),
                signInSignUpButton(context, true, _signInUser),
                signUpOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String userIdFromFirestore = userDoc.get('id').toString();

        if (userIdFromFirestore == '0') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(adminId: "9zMrY7yPCFfQW3mG88cz47MlZau2"),
            ),
          );
          return;
        }

        bool isDoctor = userDoc.get('isDoctor');
        _showCustomSnackBar(context, 'Login successful!', Colors.green);

        if (isDoctor) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        _showCustomSnackBar(context, 'User does not exist!', Colors.red);
      }
    } catch (error) {
      _showCustomSnackBar(context, 'Incorrect credentials', Colors.red);
    }
  }

  void _resetPassword() async {
    if (_emailTextController.text.isEmpty) {
      _showCustomSnackBar(context, 'Enter your email to reset password.', Colors.orange);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailTextController.text);
      _showCustomSnackBar(context, 'Password reset email sent!', Colors.green);
    } catch (error) {
      _showCustomSnackBar(context, 'Error: Check your email address.', Colors.red);
    }
  }

  void _showCustomSnackBar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Row signUpOption(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Don't have an account?", style: TextStyle(color: Colors.black, fontFamily: "GoogleSans")),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
        },
        child: Text(
          " Sign Up",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontFamily: "GoogleSans"),
        ),
      ),
    ],
  );
}
