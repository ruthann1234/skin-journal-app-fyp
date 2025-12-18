import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  final List<Map<String, dynamic>> colors = const [
    {"name": "Purple", "color": Color(0xFF9C27B0)},
    {"name": "Pink", "color": Colors.pinkAccent},
    {"name": "Blue", "color": Colors.blueAccent},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appearance"),
        backgroundColor: const Color(0xFF9C27B0), // Purple AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Theme",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple heading
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Switch between light and dark theme."),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleDarkMode(val),
              activeThumbColor: const Color(0xFF9C27B0),
            ),
            const SizedBox(height: 20),
            const Text(
              "Accent Color",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple heading
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: colors.map((c) {
                final color = c["color"] as Color;
                final isSelected =
                    themeProvider.accentColor.value == color.value;
                return GestureDetector(
                  onTap: () => themeProvider.setAccentColor(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(radius: 15, backgroundColor: color),
                        const SizedBox(height: 5),
                        Text(
                          c["name"] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? color : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            const Text(
              "Preview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0), // Purple heading
              ),
            ),
            const SizedBox(height: 15),
            _buildPreviewCard(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeProvider themeProvider) {
    Color accent = themeProvider.accentColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Skin Journal App",
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            width: 120,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "This is how your theme will look.",
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
