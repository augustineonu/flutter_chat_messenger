import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_messenger/firebase_options.dart';
import 'package:flutter_chat_messenger/providers/home_provider.dart';
import 'package:flutter_chat_messenger/services/auth/auth_gate.dart';
import 'package:flutter_chat_messenger/services/auth/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    // ChangeNotifierProvider(
    //   create: (context) => AuthService(prefs: prefs),
      // child: 
      MyApp(
        prefs: prefs,
      // ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
   MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(prefs: prefs,
                firebaseAuth: FirebaseAuth.instance,
                firestore: firebaseFirestore
                 ),
                 
        ),
        Provider<HomeProvider>(
            create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore)),
      ],
      child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          // Use builder only if you need to use library outside ScreenUtilInit context
          builder: (_, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Chat Messenger',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: const AuthGate(),
            );
          }),
    );
  }
}
