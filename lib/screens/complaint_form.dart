import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _complaintController = TextEditingController();
  String _category = 'General';
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _categories = [
    'General',
    'Technical',
    'Facility',
    'Academic',
    'Other'
  ];

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      final uid = user?.uid ?? '';
      final email = user?.email ?? 'anonymous@user.com';

      final text = _complaintController.text.trim();
      final now = DateTime.now().millisecondsSinceEpoch;

      final complaintData = {
        'userId': uid,
        'userEmail': _isAnonymous ? null : email,
        'category': _category,
        'text': text,
        'isAnonymous': _isAnonymous,
        'status': 'pending',
        'adminReply': null,
        'timestamp': FieldValue
            .serverTimestamp(), // ✅ Used in query, avoids index errors
        'createdAtMs': now, // optional for local sorting
      };

      await _firestore.collection('complaint').add(complaintData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),
      );

      _complaintController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: Colors.brown.shade200,
      ),
      backgroundColor: const Color(0xFFF5F5DC),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complaintController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Enter your complaint',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a complaint' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Submit anonymously'),
                value: _isAnonymous,
                onChanged: (val) => setState(() => _isAnonymous = val),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Complaint',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
