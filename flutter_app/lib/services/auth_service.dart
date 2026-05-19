import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'analytics_service.dart';

class AuthService extends ChangeNotifier {
  static const String _webClientId =
      '391671861358-2vu0vul5kav214f1nh3hvk1n19hgb4b9.apps.googleusercontent.com';

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: _webClientId,
  );
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
    unawaited(AnalyticsService.instance.logLogin('password'));
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    unawaited(AnalyticsService.instance.logSignUp('password'));
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
    unawaited(AnalyticsService.instance.logLogin('google'));
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
        'network-request-failed': 'Network error - check your connection',
        'account-exists-with-different-credential':
            'This email is already linked to another sign-in method',
        'credential-already-in-use':
            'This Google account is already linked elsewhere',
      };
      return map[err.code] ?? err.code.replaceAll('-', ' ');
    }
    if (err is PlatformException) {
      final details = '${err.code} ${err.message ?? ''} ${err.details ?? ''}'
          .toLowerCase();
      if (details.contains('10') || details.contains('developer_error')) {
        return 'Google Sign-In is not configured for this build. Add Android SHA-1/SHA-256 OAuth clients in Firebase, refresh google-services.json, and rebuild.';
      }
      if (details.contains('url scheme') ||
          details.contains('reversed_client_id')) {
        return 'iOS Google Sign-In needs GoogleService-Info.plist and the REVERSED_CLIENT_ID URL scheme.';
      }
      if (err.code == 'sign_in_canceled') {
        return 'Google Sign-In was cancelled';
      }
      if (err.code == 'network_error') {
        return 'Network error - check your connection';
      }
      return err.message ?? err.code.replaceAll('_', ' ');
    }
    return err.toString();
  }
}
