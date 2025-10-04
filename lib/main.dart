// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/admin_dashboard.dart';

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
    const beige = Color(0xFFF5F5DC);
    const lightBrown = Color(0xFFB5651D);

    return MaterialApp(
      title: 'Complaint Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: beige,
        primaryColor: lightBrown,
        colorScheme: ColorScheme.fromSeed(seedColor: lightBrown),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        fontFamily: 'sans-serif', // prevents Roboto web loading error
      ),
      home: const RootPage(),
    );
  }
}

// 🔹 Handles routing based on auth and role
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // not logged in → login page
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            // fallback in case user doc missing
            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const HomePage();
            }

            final data = userSnap.data!.data() as Map<String, dynamic>? ?? {};
            final role = data['role'] ?? 'user';

            // route by role
            if (role == 'admin') {
              return AdminDashboard(); // ✅ non-const call
            } else {
              return const HomePage();
            }
          },
        );
      },
    );
  }
}
