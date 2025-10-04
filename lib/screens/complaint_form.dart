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
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    setState(() => _submitting = true);
    final uid = user.uid;
    final email = user.isAnonymous ? null : user.email;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    try {
      final data = {
        'userId': _isAnonymous ? 'anonymous' : uid,
        'userEmail': _isAnonymous ? null : email,
        'category': _category,
        'text': _textCtl.text.trim(),
        'isAnonymous': _isAnonymous,
        'status': 'pending',
        'adminReply': null,
        'createdAtMs': nowMs,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('complaints').add(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Complaint submitted')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // beige
      appBar: AppBar(
        title: const Text('New Complaint'),
        backgroundColor: const Color(0xFFA67B5B), // light brown
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Teacher', 'Hostel', 'Canteen', 'Library', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textCtl,
                maxLines: 5,
                decoration:
                    const InputDecoration(labelText: 'Write your complaint'),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v ?? false),
                  ),
                  const Text('Submit anonymously'),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA67B5B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Complaint',
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
