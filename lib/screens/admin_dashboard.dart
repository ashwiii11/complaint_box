// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs;

          if (complaints.isEmpty) {
            return const Center(child: Text("No complaints found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: complaints.length,
            itemBuilder: (context, i) {
              final c = complaints[i].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    c['category'] ?? "Uncategorized",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(c['text'] ?? ''),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        c['isAnonymous'] == true
                            ? "Anonymous"
                            : (c['userEmail'] ?? 'Unknown'),
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c['status'] ?? 'Pending',
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
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
