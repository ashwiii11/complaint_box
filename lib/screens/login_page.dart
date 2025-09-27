import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // ✅ Firestore import
import 'home_page.dart';
import 'admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;

Future<void> _login() async {
  setState(() => _loading = true);
  try {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final uid = userCred.user!.uid;

    // 🔍 Check if user is admin
    final adminSnap = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();

    if (adminSnap.exists) {
      // Navigate to AdminPage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      //  Navigate to HomePage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    _showError(e.message ?? "Login failed");
  } finally {
    setState(() => _loading = false);
  }
}


  Future<void> _register() async {
  setState(() => _loading = true);
  try {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Save user info in Firestore
    await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      'email': cred.user!.email,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'user', // default role
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } on FirebaseAuthException catch (e) {
    _showError(e.message ?? "Register failed");
  } finally {
    setState(() => _loading = false);
  }
}


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) ...[
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login"),
              ),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final userCred = await _auth.signInAnonymously();
                  final uid = userCred.user?.uid;

                  // Save guest profile in Firestore
                  if (uid != null) {
                    await FirebaseFirestore.instance.collection('users').doc(uid).set({
                      'email': 'guest',
                      'createdAt': FieldValue.serverTimestamp(),
                      'role': 'guest',
                    });
                  }

                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
                child: const Text("Continue as Guest"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
