import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInEmail(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email, password: pass);

  Future<UserCredential> signUpEmail(String email, String pass) =>
      _auth.createUserWithEmailAndPassword(email: email, password: pass);

  Future<UserCredential> signInAnonymously() =>
      _auth.signInAnonymously();

  Future<void> signOut() => _auth.signOut();
}
