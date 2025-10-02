// lib/screens/complaint_history.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    // DEBUG: print uid to console
    print(' ComplaintHistory for uid: $uid');

    return Scaffold(
      appBar: AppBar(title: const Text("My Complaints")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAtMs', descending: true) // use client ms timestamp
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(' Snapshot error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          // debug print:
          print('complaint snapshot count: ${docs.length}');
          if (docs.isEmpty) {
            return const Center(child: Text("No complaints yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final text = data['text'] ?? 'No text';
              final category = data['category'] ?? 'General';
              final status = data['status'] ?? 'Pending';
              final isAnon = data['isAnonymous'] ?? false;
              final adminReply = data['adminReply'];
              final createdMs = data['createdAtMs'];
              String timeStr = '';
              if (createdMs is int) {
                final dt = DateTime.fromMillisecondsSinceEpoch(createdMs);
                timeStr = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(isAnon ? 'Anonymous Complaint' : text, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: $category'),
                      Text('Status: $status'),
                      if (adminReply != null) Text('Admin reply: ${adminReply.toString()}'),
                      if (isAnon) const Text('(Submitted Anonymously)'),
                      if (timeStr.isNotEmpty) Text('Submitted: $timeStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
