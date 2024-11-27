// ignore_for_file: avoid_print

import 'package:ecom_app/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Sign out the user
  Future signOut() async {
    await auth.signOut();
    SharedPreferenceHelper().clearUser();
  }

  // Re-authenticate the user with email and password
  Future<void> reAuthenticateUser(String email, String password) async {
    User? user = auth.currentUser;

    if (user != null) {
      try {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);
        print("User re-authenticated successfully.");
      } on FirebaseAuthException catch (e) {
        // Throw an error if re-authentication fails
        if (e.code == 'wrong-password') {
          throw FirebaseAuthException(
              code: 'wrong-password', message: 'Invalid password.');
        } else if (e.code == 'user-not-found') {
          throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found with this email.');
        } else {
          throw FirebaseAuthException(
              code: e.code, message: 'Re-authentication failed: ${e.message}');
        }
      }
    }
  }

  // Delete the user's Firestore data and Firebase authentication account
  Future<void> deleteUser(String email, String password) async {
    User? user = auth.currentUser;

    if (user != null) {
      try {
        // Re-authenticate the user before deleting
        await reAuthenticateUser(email, password);

        // Delete the user's document from Firestore
        await firestore.collection('users').doc(user.uid).delete();
        print("User data deleted from Firestore.");

        // Delete the Firebase Authentication account
        await user.delete();
        print("Firebase authentication account deleted.");

        // Optionally, sign the user out after deletion
        await signOut();
      } on FirebaseAuthException catch (e) {
        // Handle re-authentication errors (e.g., invalid password)
        // ignore: use_rethrow_when_possible
        throw e;
      } catch (e) {
        // Handle other errors (e.g., network issues)
        print("Error deleting user: $e");
      }
    }
  }
}
