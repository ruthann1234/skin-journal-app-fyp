import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _reportController = TextEditingController();
  bool _isSubmitting = false;
  final Color purple = const Color(0xFF9C27B0);

  Future<void> _submitReport() async {
    if (_reportController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('reports').add({
      'userId': user?.uid ?? '',
      'report': _reportController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _isSubmitting = false);
    _reportController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Problem reported successfully!"),
        backgroundColor: purple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report a Problem"),
        backgroundColor: purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _reportController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Describe the problem here...",
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
              onPressed: _isSubmitting ? null : _submitReport,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
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
