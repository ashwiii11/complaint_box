import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in.")),
      );
    }

    // 🧠 Stream complaints made by the current user (no index issues)
    final complaintsStream = FirebaseFirestore.instance
        .collection('complaints')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true) // ✅ must exist in DB
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaints"),
        backgroundColor: Colors.brown.shade200,
      ),
      backgroundColor: const Color(0xFFF5F5DC), // beige
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: complaintsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No complaints yet.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final data = complaints[index].data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                elevation: 3,
                child: ListTile(
                  title: Text(
                    data['text'] ?? 'No text',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Category: ${data['category'] ?? 'Unknown'}\nStatus: ${data['status'] ?? 'Pending'}",
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
