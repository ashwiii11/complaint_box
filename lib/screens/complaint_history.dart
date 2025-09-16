import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db_service.dart';

class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('No user')));
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: StreamBuilder<QuerySnapshot>(
        stream: DBService().complaintsStreamForUser(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No complaints yet.'));
          return ListView(
            children: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['category'] ?? ''),
                subtitle: Text(data['text'] ?? ''),
                trailing: Text(data['status'] ?? 'pending'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
