// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'complaint_form.dart';
import 'complaint_history.dart';
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
    final uid = _authSvc.currentUser?.uid;
    if (uid == null) {
      setState(() { _isAdmin = false; _loading = false; });
      return;
    }
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data();
    setState(() {
      _isAdmin = (data != null && data['role'] == 'admin');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authSvc.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authSvc.signOut();
              // authStateChanges stream in main will redirect to LoginPage
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Welcome ${user?.isAnonymous == true ? "Guest" : user?.email ?? ''}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintForm())),
                  child: const Text('Write Complaint'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintHistory())),
                  child: const Text('My Complaints'),
                ),
                if (_isAdmin) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboard())),
                    child: const Text('Admin Dashboard'),
                  ),
                ],
              ]),
            ),
    );
  }
}
