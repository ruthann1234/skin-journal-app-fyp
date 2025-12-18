import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool morningReminder = false;
  bool eveningReminder = false;
  bool loaded = false;
  final Color purple = const Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    if (uid != null) _loadReminders();
  }

  Future<void> _loadReminders() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        morningReminder = data?['morningReminder'] ?? false;
        eveningReminder = data?['eveningReminder'] ?? false;
        loaded = true;
      });
    } else {
      setState(() => loaded = true);
    }
  }

  Future<void> _saveReminders() async {
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'morningReminder': morningReminder,
      'eveningReminder': eveningReminder,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Reminders saved!"),
        backgroundColor: purple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: purple)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Reminders"),
        backgroundColor: purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Morning Reminder"),
              secondary: Icon(Icons.wb_sunny, color: purple),
              activeThumbColor: purple,
              value: morningReminder,
              onChanged: (val) => setState(() => morningReminder = val),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Evening Reminder"),
              secondary: Icon(Icons.nights_stay, color: purple),
              activeThumbColor: purple,
              value: eveningReminder,
              onChanged: (val) => setState(() => eveningReminder = val),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 14,
                ),
              ),
              onPressed: _saveReminders,
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
