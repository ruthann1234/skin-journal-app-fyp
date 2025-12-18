import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'welcome_page.dart';
import 'privacy_page.dart';
import 'appearance_page.dart';
import 'language_page.dart';
import 'reminders_page.dart';
import 'about_page.dart';

// Fixed Help & Support Pages imports
import 'feedback_page.dart';
import 'report_page.dart';
import 'help_support_page.dart'; // Contact & FAQ page

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final username = user?.displayName ?? "User";
    final email = user?.email ?? "No email";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF9C27B0), // Soft purple app bar
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ---------------- USER INFO ----------------
          ListTile(
            leading: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 35, color: Colors.white),
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(email),
          ),
          const Divider(),

          /// ---------------- SETTINGS ----------------
          _buildSettingTile(
            context,
            title: "Privacy & Security",
            icon: Icons.lock,
            page: const PrivacyPage(),
          ),
          _buildSettingTile(
            context,
            title: "Appearance",
            icon: Icons.color_lens,
            page: const AppearancePage(),
          ),
          _buildSettingTile(
            context,
            title: "Language",
            icon: Icons.language,
            page: const LanguagePage(),
          ),
          _buildSettingTile(
            context,
            title: "Reminders",
            icon: Icons.notifications,
            page: const RemindersPage(),
          ),
          _buildSettingTile(
            context,
            title: "About",
            icon: Icons.info,
            page: const AboutPage(),
          ),

          const Divider(),

          /// ---------------- HELP & SUPPORT ----------------
          _buildSettingTile(
            context,
            title: "Submit Feedback",
            icon: Icons.feedback,
            page: const FeedbackPage(),
          ),
          _buildSettingTile(
            context,
            title: "Report a Problem",
            icon: Icons.report_problem,
            page: const ReportPage(),
          ),
          _buildSettingTile(
            context,
            title: "Contact & FAQ",
            icon: Icons.contact_page,
            page: const HelpSupportPage(),
          ),

          const SizedBox(height: 20),

          /// ---------------- LOGOUT ----------------
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0), // Purple button
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildSettingTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon, color: Colors.black), // Black icons
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black,
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
