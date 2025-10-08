import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({super.key});

  @override
  State<ComplaintFormPage> createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  late AnimationController _controller;

  final _authSvc = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  Future<void> _submitComplaint() async {
    final text = _textController.text.trim();
    final category = _categoryController.text.trim();
    if (text.isEmpty || category.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final user = _authSvc.currentUser;
      await FirebaseFirestore.instance.collection('complaints').add({
        'text': text,
        'category': category,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user?.uid ?? 'anonymous',
        'isAnonymous': user == null || user.isAnonymous,
      });

      setState(() {
        _submitted = true;
        _submitting = false;
      });
      _controller.forward();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Write a Complaint'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: _submitted
              ? FadeTransition(
                  opacity: _controller,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOutBack,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green.shade600, size: 100),
                        const SizedBox(height: 20),
                        const Text(
                          'Complaint Submitted!',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your issue has been recorded successfully.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home),
                          label: const Text('Go Back'),
                        )
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildAnimatedTextField(
                            controller: _categoryController,
                            label: 'Category',
                            icon: Icons.category_outlined),
                        const SizedBox(height: 20),
                        _buildAnimatedTextField(
                            controller: _textController,
                            label: 'Write your complaint...',
                            icon: Icons.message_outlined,
                            maxLines: 5),
                        const SizedBox(height: 40),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _submitting ? 70 : 200,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _submitting ? null : _submitComplaint,
                            child: _submitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Submit Complaint',
                                    style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigo),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigoAccent, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
