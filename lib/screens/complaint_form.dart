import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _category = 'Hostel';
  String _text = '';
  bool _isAnonymous = false;
  bool _loading = false;

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    final uid = _auth.currentUser?.uid ?? 'anonymous';
    final data = {
      'userId': _isAnonymous ? 'anonymous' : uid,
      'category': _category,
      'text': _text,
      'isAnonymous': _isAnonymous,
      'status': 'pending',
      'adminReply': null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('complaints').add(data);
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Complaint submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write Complaint')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _category,
                      items: ['Hostel', 'Canteen', 'Campus', 'Academics']
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Complaint Text'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter complaint text' : null,
                      onSaved: (v) => _text = v!,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Submit anonymously'),
                      value: _isAnonymous,
                      onChanged: (v) => setState(() => _isAnonymous = v),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitComplaint,
                      child: const Text('Submit Complaint'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
