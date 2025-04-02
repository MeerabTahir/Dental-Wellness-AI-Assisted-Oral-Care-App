import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/email_service.dart';
import '../../services/firestore_service.dart';
import 'package:tooth_tales/models/userModel.dart';

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({Key? key}) : super(key: key);

  @override
  _DoctorRegisterPageState createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false; // State for showing progress indicator

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Dentist Registration", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Register Dentist!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "GoogleSans",
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Create a Dentist account to enable them to provide treatment to users.",
                    style: TextStyle(fontSize: 16, fontFamily: "GoogleSans"),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    "assets/Images/dentistss.png",
                    width: 500,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(_nameController, "Full Name", Icons.person),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "Email", Icons.email),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : ElevatedButton(
                  onPressed: _registerDoctor,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  String _generatePassword() {
    const String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&*!";
    Random random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _registerDoctor() async {
    setState(() => _isLoading = true); // Show loading indicator

    try {
      String email = _emailController.text.trim();
      String name = _nameController.text.trim();
      String password = _generatePassword();

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();

        // Save doctor info in Firestore
        String doctorId = user.uid;
        UserAccounts doctorAccount = UserAccounts(
          id: doctorId,
          userName: name,
          isDoctor: true,
          password: password, // Save password
        );

        await FirestoreService<UserAccounts>('users').addItemWithId(doctorAccount, doctorId);

        // Send email in background (UI remains smooth)
        Future.delayed(Duration.zero, () {
          print("Sending credentials email..."); // Debug log
          EmailService.sendEmail(
            recipientEmail: email,
            recipientName: name,
            password: password,
          ).then((_) {
            print("✅ Credentials email sent successfully.");
          }).catchError((e) {
            print("❌ Error sending credentials email: $e");
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }
}
