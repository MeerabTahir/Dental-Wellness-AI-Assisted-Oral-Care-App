import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/userModel.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  UserAccounts? _user;

  UserAccounts? get user => _user;

  Future<void> signUp(String email, String password, String username, bool isDoctor) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _user = UserAccounts(
          id: firebaseUser.uid,
          userName: username,
          password: password,
          isDoctor: isDoctor,
        );
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _user = UserAccounts(
          id: firebaseUser.uid,
          userName: email.split('@')[0],
          password: password,
          isDoctor: false,
        );
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
