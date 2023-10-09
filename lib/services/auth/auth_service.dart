import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/model/user_chat_model.dart';

class AuthService extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign user in
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      // sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // add a new document for the user in the users collection if it doesn't already exist
      _firestore.collection('users').doc(userCredential.user!.uid).set(
          {'uid': userCredential.user!.uid, 'email': email},
          SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // create a new user
  Future<UserCredential> signUpWithEmailandPassword(
      String email, String password, String fullName) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user!;
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where(userCredential.user!.uid, isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> document = result.docs;

      // if the document returns empty list
      if (document.isEmpty) {
        // after creating the user, create a new document for the user in the user collection
        _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': fullName,
          'timeStamp': DateTime.now().millisecondsSinceEpoch.toString(),
        });

        // store user data in local storage. pref shared preferences
      } else {
        print("docment response ${document.length.toString()}");
        DocumentSnapshot documentSnapshot = document[0];
        UserChat userChat = UserChat.fromDocument(documentSnapshot);
        // ChatUser userChat = ChatUser.fromDocument(documentSnapshot);

        // store user data in local storage. pref shared preferences
      }

      firebaseUser.updateDisplayName(fullName);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      throw Exception(e.code);
    }
  }

  // sign user out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
