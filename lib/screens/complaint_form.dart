import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({Key? key}) : super(key: key);

  @override
  State<ComplaintFormPage> createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> {
  final _controller = TextEditingController();
  String _category = 'General';
  bool _isAnonymous = false;
  bool _isLoading = false;

  Future<void> _submitComplaint() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'unknown';
      final email = user?.email;

      final nowMs = DateTime.now().millisecondsSinceEpoch;

      final data = {
        'userId': uid,
        'userEmail': _isAnonymous ? null : email,
        'category': _category,
        'text': _controller.text.trim(),
        'isAnonymous': _isAnonymous,
        'status': 'pending',
        'adminReply': null,
        'createdAtMs': nowMs,
        'serverTimestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('complaints').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Complaint submitted successfully!')),
      );

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Complaint')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category:'),
            DropdownButton<String>(
              value: _category,
              onChanged: (value) => setState(() => _category = value!),
              items: const [
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                DropdownMenuItem(value: 'Academics', child: Text('Academics')),
              ],
            ),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Enter your complaint',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (v) => setState(() => _isAnonymous = v!),
                ),
                const Text('Submit anonymously')
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitComplaint,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}
