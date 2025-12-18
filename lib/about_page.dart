import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded app info
    const String appName = "Skin Journal";
    const String version = "1.0.0+1";

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: const Color(0xFF9C27B0), // Purple AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Color(0xFF9C27B0), // Purple icon
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Center(
              child: Text(
                appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A), // Darker purple text
                ),
              ),
            ),
            Center(
              child: Text(
                "Version: $version",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "About Skin Journal",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple heading
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Skin Journal is a personal skin health tracker designed for users aged 16-30. "
              "It helps you track your skin symptoms, routines, and progress over time, "
              "so you can reflect and improve your skincare habits.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Developed by:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple heading
              ),
            ),
            const SizedBox(height: 5),
            const Text("Ruth Ann", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text(
              "Contact / Support:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple heading
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "support@skinjournal.app",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7B1FA2),
              ), // Purple accent
            ),
          ],
        ),
      ),
    );
  }
}
