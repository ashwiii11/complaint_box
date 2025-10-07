import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
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
  bool _showAnimation = false; // 👈 new state

  Future<void> _submit() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final uid = user.uid;
      final email = user.isAnonymous ? null : user.email;

      await _db.addComplaint({
        'userId': _isAnonymous ? 'anonymous' : uid,
        'userEmail': _isAnonymous ? null : email,
        'category': _category,
        'text': _textCtl.text.trim(),
        'isAnonymous': _isAnonymous,
        'status': 'pending',
        'adminReply': null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _showAnimation = true; // 👈 Show Lottie animation
      });

      await Future.delayed(const Duration(seconds: 3)); // Wait for animation
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      body: Center(
        child: _showAnimation
            ? Lottie.asset(
                'assets/animations/complaint_box.json',
                repeat: false,
                width: 250,
                height: 250,
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _category,
                      items: ['Teacher', 'Hostel', 'Canteen', 'Library', 'Other']
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _category = v ?? 'Hostel'),
                      decoration:
                          const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textCtl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Write your complaint',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: _isAnonymous,
                            onChanged: (v) =>
                                setState(() => _isAnonymous = v ?? false)),
                        const Text('Submit anonymously'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit Complaint'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
