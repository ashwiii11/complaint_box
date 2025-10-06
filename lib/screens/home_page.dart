// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'complaint_form.dart';
import 'suggestion_page.dart';
import 'admin_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authSvc = AuthService();
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = _authSvc.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data();
      _isAdmin = data?['role'] == 'admin';
    } else {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email ?? 'anonymous',
        'role': 'user',
      });
      _isAdmin = false;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAdmin ? const AdminDashboard() : _buildUserHome(context);
  }

  Widget _buildUserHome(BuildContext context) {
    final user = _authSvc.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authSvc.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome ${user?.email ?? "Guest"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintForm()),
              ),
              child: const Text('Write a Complaint'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuggestionsPage()),
              ),
              child: const Text('Suggestion Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
