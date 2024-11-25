import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hallmeal/screens/adminscreen/Home/AdminMenu.dart';
import 'package:hallmeal/screens/studentscreen/StudentPage.dart';
import 'package:hallmeal/screens/studentscreen/StudentLoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import 'firebase_options.dart'; // Import Firebase options generated by FlutterFire CLI

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Handle loading and error states explicitly
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen(); // Show loading screen while waiting
          }

          if (snapshot.hasError) {
            return ErrorScreen(); // Show error screen in case of error
          }

          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user != null) {
              // Check for user role in Firestore
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen(); // Show loading screen while fetching user role
                  }

                  if (userSnapshot.hasData) {
                    var userRole = userSnapshot.data?.get('role'); // Assuming 'role' is stored in Firestore
                    if (userRole == 'admin' && user.emailVerified) {
                      return AdminMenu(); // Admin is logged in
                    } else {
                      return StudentPage(); // Student is logged in
                    }
                  } else {
                    return ErrorScreen(); // Handle case where Firestore document is not found
                  }
                },
              );
            }
          }

          // If no data is found, show the login page
          return StudentloginPage();
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('An error occurred. Please try again later.'),
      ),
    );
  }
}
