import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool dataBackup = true;
  bool analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        backgroundColor: const Color(0xFF9C27B0), // Purple AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple headings
              ),
            ),
            const SizedBox(height: 15),

            // CLOUD BACKUP
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Cloud Backup"),
              subtitle: const Text(
                "Automatically back up your journals and photos.",
              ),
              activeThumbColor: const Color(0xFF9C27B0), // Purple switch
              value: dataBackup,
              onChanged: (val) => setState(() => dataBackup = val),
            ),

            // ANALYTICS
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Anonymous Analytics"),
              subtitle: const Text(
                "Help improve Skin Journal by sharing anonymous usage statistics. No personal data or photos are shared.",
              ),
              activeThumbColor: const Color(0xFF9C27B0), // Purple switch
              value: analyticsEnabled,
              onChanged: (val) => setState(() => analyticsEnabled = val),
            ),

            const SizedBox(height: 25),

            const Text(
              "How We Protect Your Data",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple headings
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your skin journals, photos, and notes are stored securely. "
              "We do not use AI to analyze your photos, and we never sell or share your data.\n",
              style: TextStyle(fontSize: 15),
            ),
            const Text(
              "✔ Data stays private and encrypted\n"
              "✔ You control cloud backup\n"
              "✔ Delete data anytime\n"
              "✔ No third-party ads or tracking\n",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 25),
            const Text(
              "Your Rights",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple headings
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Download your data\n"
              "• Delete your account permanently\n"
              "• Disable backup anytime\n"
              "• Turn off analytics anytime\n",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0), // Purple button
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showDeleteDialog(context),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text(
          "Deleting your account will permanently remove all journals, photos, reminders, and settings.",
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFF9C27B0)), // Purple delete text
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account deletion triggered.")),
              );
            },
          ),
        ],
      ),
    );
  }
}
