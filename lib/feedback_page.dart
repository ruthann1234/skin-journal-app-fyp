import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  final Color purple = const Color(0xFF9C27B0);

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('feedback').add({
      'userId': user?.uid ?? '',
      'feedback': _feedbackController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _isSubmitting = false);
    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Feedback submitted successfully!"),
        backgroundColor: purple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Feedback"),
        backgroundColor: purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              onPressed: _isSubmitting ? null : _submitFeedback,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
