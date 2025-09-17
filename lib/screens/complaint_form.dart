import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/db_service.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _textCtl = TextEditingController();
  String _category = 'Hostel';
  bool _isAnonymous = false;
  final _db = DBService();
  final _auth = FirebaseAuth.instance;
  bool _submitting = false;

  Future<void> _submit() async {
    final user = _auth.currentUser;
    setState(() {
      _submitting = true;
    });
    final uid = user?.uid ?? 'anonymous';
    final email = user?.isAnonymous == true ? null : user?.email;

    try {
      await _db.addComplaint({
        'userId': uid,
        'userEmail': email,
        'category': _category,
        'text': _textCtl.text.trim(),
        'isAnonymous': _isAnonymous,
        'status': 'pending',
        // ✅ Correct use of FieldValue from FirebaseFirestore
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted')),
      );
      Navigator.pop(context);
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Teacher', 'Hostel', 'Canteen', 'Library', 'Other']
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() {
                _category = v!;
              }),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _textCtl,
              maxLines: 6,
              decoration:
                  const InputDecoration(labelText: 'Write your complaint'),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (v) =>
                      setState(() => _isAnonymous = v ?? false),
                ),
                const Text('Submit anonymously'),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}
