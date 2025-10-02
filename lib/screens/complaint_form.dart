// lib/screens/complaint_form.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _textCtl = TextEditingController();
  String _category = 'Hostel';
  bool _isAnonymous = false;
  final _auth = FirebaseAuth.instance;
  bool _submitting = false;

  Future<void> _submit() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in first')));
      return;
    }

    final text = _textCtl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter complaint text')));
      return;
    }

    setState(() { _submitting = true; });

    final uid = user.uid;
    final email = user.email;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final data = {
      'userId': uid,                              // always save actual uid
      'userEmail': _isAnonymous ? null : email,  // hide email if anonymous
      'category': _category,
      'text': text,
      'isAnonymous': _isAnonymous,
      'status': 'pending',
      'adminReply': null,
      'createdAtMs': nowMs,                      // client timestamp (stable)
      'serverTimestamp': FieldValue.serverTimestamp(), // server timestamp as well
    };

    try {
      final docRef = await FirebaseFirestore.instance.collection('complaints').add(data);
      print('✅ Complaint submitted, docId: ${docRef.id}');
      // Read it back to confirm saved fields:
      final saved = await docRef.get();
      print('📦 Saved doc data: ${saved.data()}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted')));
      Navigator.pop(context);
    } catch (e, st) {
      print('❌ Error submitting complaint: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() { _submitting = false; });
    }
  }

  @override
  void dispose() {
    _textCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButtonFormField<String>(
            value: _category,
            items: ['Teacher','Hostel','Canteen','Library','Other']
              .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() { _category = v!; }),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textCtl,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Write your complaint'),
          ),
          Row(children: [
            Checkbox(value: _isAnonymous, onChanged: (v) => setState(() { _isAnonymous = v ?? false; })),
            const Text('Submit anonymously'),
          ]),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth:2)) : const Text('Submit Complaint'),
          )
        ]),
      ),
    );
  }
}
