// lib/screens/complaint_history.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';

class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Not signed in')));

    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: StreamBuilder<QuerySnapshot>(
        stream: DBService().complaintsStreamForUser(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text('No complaints yet.'));
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final ts = d['timestamp'] as Timestamp?;
              final time = ts != null ? (ts.toDate().toString()) : '';
              return ListTile(
                title: Text(d['category'] ?? ''),
                subtitle: Text(d['text'] ?? ''),
                trailing: Text(d['status'] ?? 'pending'),
                isThreeLine: true,
                dense: false,
              );
            },
          );
        },
      ),
    );
  }
}
