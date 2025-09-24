// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db_service.dart';


class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});
  final DBService _db = DBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.allComplaintsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text('No complaints yet.'));
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final status = d['status'] ?? 'pending';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(d['category'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['text'] ?? ''),
                      const SizedBox(height: 6),
                      if (d['userEmail'] != null) Text('From: ${d['userEmail']}'),
                      if (d['isAnonymous'] == true) const Text('Submitted anonymously'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'resolve') {
                        _db.updateComplaint(doc.id, {'status': 'resolved'});
                      } else if (v == 'pending') {
                        _db.updateComplaint(doc.id, {'status': 'pending'});
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'resolve', child: Text('Mark Resolved')),
                      const PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
