import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _initialized = false;

  AuthService(this._auth) {
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
    _initialized = true;
  }

  bool get initialized => _initialized;
  User? get user => _auth.currentUser;
  bool get isAuthenticated => user != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  String friendlyError(dynamic err) {
    if (err is FirebaseAuthException) {
      const map = {
        'invalid-email': 'Invalid email address',
        'user-disabled': 'Account has been disabled',
        'user-not-found': 'No account found with this email',
        'wrong-password': 'Incorrect password',
        'invalid-credential': 'Invalid email or password',
        'email-already-in-use': 'An account with this email already exists',
        'weak-password': 'Password must be at least 6 characters',
        'network-request-failed': 'Network error — check your connection',
      };
      return map[err.code] ?? err.code.replaceAll('-', ' ');
    }
    return err.toString();
  }
}
