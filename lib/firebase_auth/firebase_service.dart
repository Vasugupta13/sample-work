import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthFunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUp(String username, String email, String password) async {
    try {
      if (!isValidEmail(email) && !isValidPassword(password)) {
        throw ("Invalid email or password");
      }else if( !isValidPassword(password)){
        throw ("Password must contain atleast 6 characters");
      }else if(!isValidEmail(email)){
        throw ("Invalid email format");
      }
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = _auth.currentUser;
      String uid = user?.uid ?? '';

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
      });
      return uid;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      rethrow;
    }
  }
  Future<String?> signIn(String email, String password) async {
    try {
      if (!isValidEmail(email) || !isValidPassword(password)) {
        throw ("Invalid email or password");
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = _auth.currentUser;
      String uid = user?.uid ?? '';
      return uid;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw ('Invalid Email or Password');
    }
  }

  bool isValidEmail(String email) {
    return email.contains('@');
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
