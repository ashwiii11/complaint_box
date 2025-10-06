// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('timestamp', descending: true)
        .snapshots();

    final suggestions = FirebaseFirestore.instance
        .collection('suggestions')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Complaints'),
              Tab(text: 'Suggestions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Complaints Tab
            StreamBuilder(
              stream: complaints,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No complaints yet.'));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final c = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(c['text'] ?? ''),
                        subtitle: Text(
                          "From: ${c['isAnonymous'] == true ? 'Anonymous' : c['userEmail'] ?? 'Unknown'}\n"
                          "Status: ${c['status'] ?? 'pending'}",
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Suggestions Tab
            StreamBuilder(
              stream: suggestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No suggestions yet.'));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final s = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(s['text'] ?? ''),
                        subtitle: Text("By: ${s['userId'] ?? 'Unknown'}"),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
