import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final user = FirebaseAuth.instance.currentUser;
final uid = user?.uid;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _googleSignInReady = false;

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInReady) return;

    await GoogleSignIn.instance.initialize();
    _googleSignInReady = true;
  }

  // REGISTER
  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (_) {
      return null;
    }
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (_) {
      return null;
    }
  }

  Future<User?> loginWithGoogle() async {
    try {
      await _ensureGoogleSignInReady();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);

      return result.user;
    } catch (_) {
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    if (_googleSignInReady) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  // USER ACTUAL
  User? get currentUser => _auth.currentUser;
}
