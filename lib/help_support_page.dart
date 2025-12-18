import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final String contactEmail = "support@skinjournal.com";
  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I add a new journal entry?",
      "answer":
          "Go to the Home page and click on 'Add New Log'. Fill in your details and save.",
    },
    {
      "question": "Can I track multiple products?",
      "answer": "Yes, you can track up to 4 main products in your daily log.",
    },
    {
      "question": "How do I set reminders?",
      "answer":
          "Go to Settings > Reminders to set morning and evening notifications.",
    },
    {
      "question": "Is my data private?",
      "answer":
          "Yes, all data is stored securely and only accessible to your account.",
    },
  ];

  final Color purple = const Color(0xFF9C27B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: purple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Section
          Text(
            "Contact Us",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.email, color: purple),
            title: Text(contactEmail),
            onTap: () {
              // Optional: open email app
            },
          ),
          const Divider(height: 30),

          // FAQ Section
          Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          const SizedBox(height: 8),
          ...faqs.map((faq) {
            return ExpansionTile(
              title: Text(faq["question"]!),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(faq["answer"]!),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
