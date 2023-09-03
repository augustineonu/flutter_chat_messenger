import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/pages/home_page.dart';
import 'package:flutter_chat_messenger/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // print("firebase response ${snapshot.data}");
            return const HomePage();
          } else {
            // print("firebase user");
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
