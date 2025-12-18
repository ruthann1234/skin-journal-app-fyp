import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = "English";
  final List<String> languages = ["English", "Malay", "Chinese"];
  final Color purple = const Color(0xFF9C27B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language"), backgroundColor: purple),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your preferred language",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: purple,
              ),
            ),
            const SizedBox(height: 20),

            /// Language list
            ...languages.map((lang) {
              return ListTile(
                title: Text(lang),
                trailing: selectedLanguage == lang
                    ? Icon(Icons.check, color: purple)
                    : null,
                onTap: () {
                  setState(() {
                    selectedLanguage = lang;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Language set to $lang"),
                      backgroundColor: purple,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
