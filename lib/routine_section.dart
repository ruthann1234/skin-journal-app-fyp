import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_routine_page.dart'; // since both are under lib

class RoutineSection extends StatefulWidget {
  const RoutineSection({super.key});

  @override
  State<RoutineSection> createState() => _RoutineSectionState();
}

class _RoutineSectionState extends State<RoutineSection> {
  // Sample routine items (replace with dynamic data later)
  List<RoutineItem> morning = [
    RoutineItem(name: "Cleanser"),
    RoutineItem(name: "Serum"),
    RoutineItem(name: "Moisturizer"),
    RoutineItem(name: "Sunscreen"),
  ];

  List<RoutineItem> night = [
    RoutineItem(name: "Cleanser"),
    RoutineItem(name: "Retinol (2x weekly)"),
    RoutineItem(name: "Night Cream"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          "Today's Routine",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Morning Routine
        const Text(
          "Morning",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...morning.map((item) => _routineCheckbox(item)),

        const SizedBox(height: 20),

        // Night Routine
        const Text(
          "Night",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...night.map((item) => _routineCheckbox(item)),

        const SizedBox(height: 16),

        // View Full Routine button
        GestureDetector(
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewRoutinePage(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not logged in')),
              );
            }
          },
          child: const Text(
            "View Full Routine →",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  // Checkbox item UI
  Widget _routineCheckbox(RoutineItem item) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: item.done,
      onChanged: (value) {
        setState(() {
          item.done = value ?? false;
        });
      },
      title: Text(item.name),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

// Simple data model for routine items
class RoutineItem {
  String name;
  bool done;

  RoutineItem({required this.name, this.done = false});
}
