import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _auth = AuthService();
  bool _submitting = false;
  bool _showAnimation = false;

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    final user = _auth.currentUser;
    await FirebaseFirestore.instance.collection('complaints').add({
      'userId': user?.uid,
      'email': user?.email ?? 'Anonymous',
      'text': _complaintController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _submitting = false;
      _showAnimation = true;
    });

    // Play animation for 2 seconds before showing success
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _showAnimation = false;
      });
      _complaintController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Complaint submitted successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write Complaint"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _showAnimation
              ? Lottie.asset('assets/complaint_drop.json', repeat: false)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Write your complaint below 👇",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _complaintController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: "Type your complaint here...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? "Please enter a complaint"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _submitting ? null : _submitComplaint,
                              icon: const Icon(Icons.send),
                              label: _submitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text("Submit"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
