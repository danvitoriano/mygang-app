import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  UserRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> register(String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    final uid = cred.user!.uid;
    if (displayName.trim().isNotEmpty) {
      await cred.user!.updateDisplayName(displayName.trim());
    }
    await _firestore.collection('users').doc(uid).set({
      'displayName': displayName.trim(),
      'photoUrl': cred.user!.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() => _auth.signOut();

  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfile({required String uid, required String displayName}) {
    return _firestore.collection('users').doc(uid).set({
      'displayName': displayName.trim(),
    }, SetOptions(merge: true));
  }
}
