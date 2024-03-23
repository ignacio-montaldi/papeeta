import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign in anon
  Future<UserCredential?> signInAnon() async {
    try {
      UserCredential user = await _auth.signInAnonymously();
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in with email & password

  //register with email and password

  // sign out
}
