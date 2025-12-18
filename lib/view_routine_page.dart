import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewRoutinePage extends StatefulWidget {
  const ViewRoutinePage({super.key}); // No userId required

  @override
  State<ViewRoutinePage> createState() => _ViewRoutinePageState();
}

class _ViewRoutinePageState extends State<ViewRoutinePage> {
  late final String uid;
  late Stream<QuerySnapshot> _journalStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in
      throw Exception("User not logged in");
    }
    uid = user.uid;

    _journalStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journals')
        .orderBy('date', descending: true)
        .snapshots();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Not set";
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String nextExpiry(DateTime? lastUsed, {int monthsValid = 6}) {
    if (lastUsed == null) return "Not set";
    final expiry = DateTime(
      lastUsed.year,
      lastUsed.month + monthsValid,
      lastUsed.day,
    );
    return DateFormat('yyyy-MM-dd').format(expiry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Routine"),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _journalStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
            );
          }

          final logs = snapshot.data!.docs;

          if (logs.isEmpty) {
            return const Center(
              child: Text(
                "No routine logged yet.",
                style: TextStyle(color: Color(0xFF9C27B0)),
              ),
            );
          }

          final Map<String, Map<String, dynamic>> productMap = {};

          for (var doc in logs) {
            final data = doc.data()! as Map<String, dynamic>;
            final timestamp = data['date'] as Timestamp?;
            if (timestamp == null) continue;

            final date = timestamp.toDate();

            final products =
                (data['products'] as Map?)?.cast<String, dynamic>() ?? {};

            for (var entry in products.entries) {
              final name = entry.key;

              if (entry.value is! Map) continue;

              final prodData = (entry.value as Map).cast<String, dynamic>();
              final selected = prodData['selected'] ?? false;
              final reaction = prodData['reaction'] ?? 'No reaction';

              if (!selected) continue;

              final storedDate = productMap[name]?['lastUsed'] as DateTime?;
              if (storedDate == null || date.isAfter(storedDate)) {
                productMap[name] = {'lastUsed': date, 'reaction': reaction};
              }
            }
          }

          if (productMap.isEmpty) {
            return const Center(
              child: Text(
                "No products used yet in journals.",
                style: TextStyle(color: Color(0xFF9C27B0)),
              ),
            );
          }

          final sortedProducts = productMap.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: sortedProducts.map((entry) {
              final name = entry.key;
              final lastUsed = entry.value['lastUsed'] as DateTime?;
              final reaction = entry.value['reaction'] as String?;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF9C27B0), width: 1),
                ),
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Last reaction: ${reaction ?? 'No reaction'}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "Last used: ${formatDate(lastUsed)}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "Expiry (6 months): ${nextExpiry(lastUsed)}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
