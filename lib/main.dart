import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/admin_dashboard.dart'; // make sure this import is here
import 'package:cloud_firestore/cloud_firestore.dart'; // needed for FutureBuilder

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
    return MaterialApp(
      title: 'Complaint Box',
      debugShowCheckedModeBanner: false,

      // ✅ GLOBAL THEME
      theme: ThemeData(
         fontFamily: 'sans-serif', // ⛔ no external Roboto
    primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // beige
        primaryColor: const Color(0xFFA0522D), // light brown
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFA0522D), // light brown
          secondary: const Color(0xFFD2B48C), // tan accent (optional)
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFA0522D), // light brown
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA0522D), // light brown
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snap.data?.data() as Map<String, dynamic>?;
              final role = data?['role'] ?? 'user';

              if (role == 'admin') {
                return AdminDashboard();
              } else {
                return const HomePage();
              }
            },
          );
        },
      ),
    );
  }
}
