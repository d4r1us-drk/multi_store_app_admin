import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';

class AuthController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // For authentication
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore
      .instance; // Access to the database
  //final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Method to register a new user
  Future<String> registerNewUser
      (String name, String email, String password) async {
    String response = "Something went wrong";

    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: email,
          password: password);

      // Upload the user data to the database
      await _firebaseFirestore.collection('buyers')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': name,
        'profileImage': "",
        'email': email,
        'uid': userCredential.user!.uid,
        'city': "",
        'state': "",
      });
      response = 'success';
    }

    catch (e) {
      response = e.toString();
    }

    return response;
  }

  // Method to log in a user
  Future<String> loginUser(String email, String password) async {
    String response = "Something went wrong";

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      response = 'success';
    } catch (e) {
      response = e.toString();
    }

    return response;
  }
}
