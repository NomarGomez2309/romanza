import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final user = FirebaseAuth.instance.currentUser;
final uid = user?.uid;

enum AuthProviderType { email, google }

class AuthSession {
  const AuthSession({
    required this.user,
    required this.profileCreated,
    required this.hasRelationshipDate,
  });

  final User user;
  final bool profileCreated;
  final bool hasRelationshipDate;
}

class AuthActionResult {
  const AuthActionResult._({this.session, this.message});

  const AuthActionResult.success(AuthSession session)
    : this._(session: session);

  const AuthActionResult.failure(String message) : this._(message: message);

  final AuthSession? session;
  final String? message;

  bool get isSuccess => session != null;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static bool _googleSignInReady = false;

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInReady) return;

    await GoogleSignIn.instance.initialize();
    _googleSignInReady = true;
  }

  Future<AuthActionResult> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = result.user;
      if (user == null) {
        return const AuthActionResult.failure('No pude crear la cuenta.');
      }

      return AuthActionResult.success(
        await _ensureUserProfile(user, AuthProviderType.email),
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult.failure(_authMessage(error));
    } catch (_) {
      return const AuthActionResult.failure('No pude crear la cuenta.');
    }
  }

  Future<AuthActionResult> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = result.user;
      if (user == null) {
        return const AuthActionResult.failure('No pude iniciar sesion.');
      }

      return AuthActionResult.success(
        await _ensureUserProfile(user, AuthProviderType.email),
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult.failure(_authMessage(error));
    } catch (_) {
      return const AuthActionResult.failure('No pude iniciar sesion.');
    }
  }

  Future<AuthActionResult> loginWithGoogle() async {
    try {
      await _ensureGoogleSignInReady();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        return const AuthActionResult.failure(
          'No pude iniciar sesion con Google.',
        );
      }

      return AuthActionResult.success(
        await _ensureUserProfile(user, AuthProviderType.google),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'account-exists-with-different-credential') {
        return const AuthActionResult.failure(
          'Ya existe una cuenta con este email. Entra con email y password para vincular Google desde tu cuenta.',
        );
      }
      return AuthActionResult.failure(_authMessage(error));
    } catch (_) {
      return const AuthActionResult.failure(
        'No pude iniciar sesion con Google todavia.',
      );
    }
  }

  Future<AuthActionResult> linkCurrentUserWithGoogle() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const AuthActionResult.failure('Inicia sesion primero.');
    }

    try {
      await _ensureGoogleSignInReady();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await currentUser.linkWithCredential(credential);
      final user = result.user ?? currentUser;

      return AuthActionResult.success(
        await _ensureUserProfile(user, AuthProviderType.google),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'provider-already-linked') {
        return AuthActionResult.success(
          await _ensureUserProfile(currentUser, AuthProviderType.google),
        );
      }
      return AuthActionResult.failure(_authMessage(error));
    } catch (_) {
      return const AuthActionResult.failure('No pude vincular Google.');
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

  Future<AuthSession> _ensureUserProfile(
    User user,
    AuthProviderType provider,
  ) async {
    final userRef = _db.collection('users').doc(user.uid);
    var profileCreated = false;
    var hasRelationshipDate = false;

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final providerName = provider == AuthProviderType.google
          ? 'google.com'
          : 'password';

      if (!snapshot.exists) {
        profileCreated = true;
        transaction.set(userRef, {
          'uid': user.uid,
          'name': user.displayName ?? user.email?.split('@').first ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL,
          'authProvider': providerName,
          'authProviders': FieldValue.arrayUnion([providerName]),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'partnerId': null,
          'coupleId': null,
        });
        return;
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      hasRelationshipDate = data['relationshipStartDate'] is Timestamp;
      transaction.set(userRef, {
        'uid': user.uid,
        'name': user.displayName ?? data['name'] ?? '',
        'email': user.email ?? data['email'] ?? '',
        'photoUrl': user.photoURL ?? data['photoUrl'],
        'authProvider': providerName,
        'authProviders': FieldValue.arrayUnion([providerName]),
        'updatedAt': FieldValue.serverTimestamp(),
        'partnerId': data['partnerId'],
        'coupleId': data['coupleId'],
      }, SetOptions(merge: true));
    });

    return AuthSession(
      user: user,
      profileCreated: profileCreated,
      hasRelationshipDate: hasRelationshipDate,
    );
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email. Inicia sesion o vincula Google desde esa cuenta.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o password incorrectos.';
      case 'user-not-found':
        return 'No existe una cuenta con ese email.';
      case 'weak-password':
        return 'Usa un password mas fuerte.';
      case 'network-request-failed':
        return 'Revisa tu conexion a internet.';
      default:
        return error.message ?? 'No pude completar la autenticacion.';
    }
  }
}
