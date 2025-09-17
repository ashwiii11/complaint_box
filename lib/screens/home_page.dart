import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'complaint_form.dart';
import 'complaint_history.dart';
import 'admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authSvc = AuthService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final uid = _authSvc.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
    setState(() {
      _isAdmin = snap.exists;
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
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome ${user?.isAnonymous == true ? "Guest" : user?.email ?? ''}'),
            const SizedBox(height: 12),

            // ✅ Removed const
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ComplaintForm()),
              ),
              child: const Text('Write Complaint'),
            ),

            // ✅ Removed const
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ComplaintHistory()),
              ),
              child: const Text('My Complaints'),
            ),

            if (_isAdmin)
              // ✅ Removed const
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminDashboard()),
                ),
                child: const Text('Admin Dashboard'),
              ),
          ],
        ),
      ),
    );
  }
}
