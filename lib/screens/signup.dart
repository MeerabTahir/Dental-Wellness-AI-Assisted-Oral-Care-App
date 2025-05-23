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
  @override
  void initState() {
    super.initState();
    _passwordTextController.addListener(_validatePassword);
  }

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  List<String> _passwordErrors = [];

  bool _isPasswordValid(String password) {
    // Minimum 8 characters, at least one uppercase, one lowercase, one number, and one special character
    final passwordRegExp = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
    );
    return passwordRegExp.hasMatch(password);
  }

  void _validatePassword() {
    final password = _passwordTextController.text;
    final List<String> errors = [];

    if (password.length < 8) {
      errors.add("Must be at least 8 characters");
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add("Must contain an uppercase letter");
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add("Must contain a lowercase letter");
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add("Must contain a number");
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      errors.add("Must contain a special character (!@#\$&*~)");
    }

    setState(() {
      _passwordErrors = errors;
    });
  }


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
                ..._passwordErrors.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(e, style: const TextStyle(color: Colors.red, fontSize: 14, fontFamily: "GoogleSans")),
                    ],
                  ),
                )),


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
    if (!_isPasswordValid(_passwordTextController.text)) {
      _showCustomSnackBar(
        context,
        'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.',
        Colors.red,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      String userId = userCredential.user!.uid;

      UserAccounts userAccount = UserAccounts(
        id: userId,
        userName: _userNameTextController.text,
        password: _passwordTextController.text,
        isDoctor: false,
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