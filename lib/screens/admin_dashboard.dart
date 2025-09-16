import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  final DBService _db = const DBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: DBService().allComplaintsStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView(
            children: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(d['category'] ?? ''),
                subtitle: Text(d['text'] ?? ''),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'resolve') {
                      DBService().updateComplaint(doc.id, {'status': 'resolved'});
                    } else if (v == 'pending') {
                      DBService().updateComplaint(doc.id, {'status': 'pending'});
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'resolve', child: Text('Mark Resolved')),
                    const PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
