import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({Key? key}) : super(key: key);

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitSuggestion() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'unknown';
      final email = user?.email ?? 'anonymous';

      final data = {
        'userId': uid,
        'userEmail': email,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('suggestions').add(data);

      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Suggestion submitted!')),
      );
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
      appBar: AppBar(title: const Text('Suggestions Counter')),
      body: Column(
        children: [
          // Suggestion input box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter your suggestion',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitSuggestion,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit Suggestion'),
          ),
          const Divider(height: 30),
          const Text(
            'All Suggestions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Stream of suggestions
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suggestions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No suggestions yet.'));
                }

                final suggestions = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final data =
                        suggestions[index].data() as Map<String, dynamic>;
                    final email = data['userEmail'] ?? 'anonymous';
                    final text = data['text'] ?? '';

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(text),
                        subtitle: Text('By: $email'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
