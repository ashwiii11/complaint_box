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
        body: Center(child: Text("Not logged in ")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Complaints")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('userId', isEqualTo: uid) 
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No complaints yet."));
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final data = complaints[index].data();
              return ListTile(
                title: Text(data['text'] ?? 'No text'),
                subtitle: Text("Status: ${data['status'] ?? 'Pending'}"),
              );
            },
          );
        },
      ),
    );
  }
}
