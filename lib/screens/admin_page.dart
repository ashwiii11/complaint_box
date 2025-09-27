import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(docId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs;

          if (complaints.isEmpty) {
            return const Center(
              child: Text(
                "No complaints found ",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final doc = complaints[index];
              final data = doc.data() as Map<String, dynamic>;

              final text = data['text'] ?? 'No description';
              final category = data['category'] ?? 'Uncategorized';
              final status = data['status'] ?? 'Pending';
              final isAnonymous = data['isAnonymous'] ?? false;
              final userEmail = data['userEmail'] ?? "Unknown User";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category: $category"),
                      Text("Status: $status"),
                      const SizedBox(height: 4),
                      isAnonymous
                          ? const Text(
                              "Posted anonymously",
                              style: TextStyle(color: Colors.grey),
                            )
                          : Text(
                              "User: $userEmail",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      _updateStatus(doc.id, value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "Pending",
                        child: Text("Mark as Pending"),
                      ),
                      const PopupMenuItem(
                        value: "In Progress",
                        child: Text("Mark as In Progress"),
                      ),
                      const PopupMenuItem(
                        value: "Resolved",
                        child: Text("Mark as Resolved"),
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
