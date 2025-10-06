// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'complaint_form.dart';
import 'complaint_history.dart';
import 'admin_dashboard.dart';
import 'suggestion_page.dart';

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

  // If no user is logged in
  if (uid == null) {
    setState(() {
      _isAdmin = false;
      _loading = false;
    });
    return;
  }

  try {
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snap.exists) {
      final data = snap.data();
      _isAdmin = (data != null && data['role'] == 'admin');
    } else {
      // Create a user entry if missing (default = normal user)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'user',
        'email': _authSvc.currentUser?.email ?? 'anonymous',
      });
      _isAdmin = false;
    }
  } catch (e) {
    debugPrint('Error checking admin: $e');
    _isAdmin = false;
  }

  setState(() {
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
                  ElevatedButton(
                   onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SuggestionsPage()),
          ),
  child: const Text('Suggestions Counter'),
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
