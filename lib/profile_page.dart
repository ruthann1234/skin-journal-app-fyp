import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF9C27B0), // Purple AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Icon
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF9C27B0), // Purple circle
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white, // Icon white for contrast
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Username
            Text(
              "Username: ${user?.displayName ?? 'Not set'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            /// Email
            Text(
              "Email: ${user?.email ?? 'No email'}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
