import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth_token.dart';

class AuthService with ChangeNotifier {
  // Firebase Authentication instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Secure storage for storing token data
  final storage = new FlutterSecureStorage();

  User? _user;
  bool _isAdmin = false;

  // Getter to check if the current user is an admin.
  bool get isAdmin => _isAdmin;

  // Constructor: sets up auth state changes listener.
  AuthService() {
    updateIsAdmin();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      updateIsAdmin();
      notifyListeners(); // Notifies listeners about state changes.
    });
  }

  // Getter for current user.
  User? get user => _user;
  // Getter for FirebaseAuth instance.
  FirebaseAuth get firebaseAuthInstance => _auth;

  // Updates the _isAdmin flag based on user's token claims.
  Future updateIsAdmin() async {
    if (_user != null) {
      final tokenResult = await _user!.getIdTokenResult();
      _isAdmin = tokenResult.claims?['admin'] ?? false;
    } else {
      _isAdmin = false;
    }
  }

  // Deletes the current user from Firebase.
  Future deleteUser() async {
    try {
      await _user?.delete();
      //print("User successfully deleted.");
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        //print('The user must reauthenticate before this operation can be executed.');
        return 'relogin';
      } else {
        return e.toString();
      }
    } catch (error) {
      //print(error.toString());
      return error.toString();
    }
  }

  // Signs in a user with email and password.
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          await storage.write(key: 'auth_token', value: authToken);
          return 'Success';
        } else {
          return 'Please click on the link provided in your email.';
        }
      } else {
        return 'Fail to Login';
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (error) {
      return error.toString();
    }
  }

  // Registers a new user with email and password.
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Send verification email after successful registration.
      if (user != null) {
        Locale? myLocale = WidgetsBinding.instance?.platformDispatcher.locale;
        await _auth.setLanguageCode(myLocale?.languageCode ?? 'en');
        await user.sendEmailVerification();
        return 'Success';
      }
      return 'Fail to register';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email is already in use or you have not clicked the link in the email';
      }
      return e.message;
    } catch (e) {
      //print(e.toString());
      return e.toString();
    }
  }

  // Sends a password reset email to the given email.
  Future sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      //print(e.toString());
      return e.toString();
    }
  }

  // Signs out the current user.
  Future signOut() async {
    try {
      await _auth.signOut();
      return 'Success';
    } catch (error) {
      //print(error.toString());
      return error.toString();
    }
  }
}
