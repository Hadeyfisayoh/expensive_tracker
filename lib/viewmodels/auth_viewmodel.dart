import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register(String username, String email, String password) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the display name
      await userCredential.user?.updateDisplayName(username);

      // Send the email verification to the user
      await userCredential.user?.sendEmailVerification();

      // Notify listeners (UI) to reflect any changes, if needed
      notifyListeners();
    } catch (e) {
      // Handle any errors
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Sign the user in with email and password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } catch (e) {
      // Handle login error
      throw e;
    }
  }

  Future<void> logout() async {
    // Log the user out
    await _auth.signOut();
    notifyListeners();
  }

  Future<bool> isEmailVerified() async {
    // Check if the current user is verified
    User? user = _auth.currentUser;
    return user != null && user.emailVerified;
  }
}
