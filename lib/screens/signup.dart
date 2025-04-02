import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/reusable_widgets/reusable_widget.dart';
import 'package:tooth_tales/screens/login.dart';
import 'package:tooth_tales/models/userModel.dart';
import '../services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

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
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(
              children: [

                Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: "GoogleSans",
                  ),
                ),
                SizedBox(height:5),
                Text(
                  "Create your account and",
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
                SizedBox(height:20),
                Image.asset("assets/Images/dentistss.png",
                  width: 500,),
                SizedBox(height: 20),
                ReusableTextField(
                  text: "Enter Username",
                  icon: Icons.person_outline,
                  isPasswordType: false,
                  controller: _userNameTextController,
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

                SizedBox(height: 20),
                signInSignUpButton(context, false, _registerUser),
                LoginOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      String userId = userCredential.user!.uid;
      print('Newly registered user ID: $userId');

      UserAccounts userAccount = UserAccounts(
        id: userId,
        userName: _userNameTextController.text,
        password: _passwordTextController.text,
        isDoctor: false,  // Set this to false as doctor functionality is removed
      );

      await FirestoreService<UserAccounts>('users').addItemWithId(userAccount, userId);

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName('User');
        _showCustomSnackBar(context, 'Registration successful! Please log in.', Colors.green);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } catch (error) {
      print("Error registering user: $error");
      _showCustomSnackBar(context, 'Error registering user', Colors.red);
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

Row LoginOption(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Already have an account?", style: TextStyle(color: Colors.black,fontFamily:"GoogleSans",)),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        },
        child: const Text(
          " Login",
          style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontFamily:"GoogleSans",),
        ),
      ),
    ],
  );
}