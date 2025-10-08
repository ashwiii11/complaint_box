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

    if (_textCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your complaint')),
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),
      );
      Navigator.pop(context);
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
    const lightBrown = Color(0xFFB5651D);
    const beige = Color(0xFFF5F5DC);

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        title: const Text('Submit a Complaint'),
        backgroundColor: lightBrown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complaint Category",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  items: ['Teacher', 'Hostel', 'Canteen', 'Library', 'Other']
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? 'Hostel'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Write your complaint",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textCtl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Describe your issue clearly...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  activeColor: lightBrown,
                  onChanged: (v) =>
                      setState(() => _isAnonymous = v ?? false),
                ),
                const Text('Submit anonymously',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightBrown,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Complaint",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
