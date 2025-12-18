import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewProgressPage extends StatefulWidget {
  const ViewProgressPage({super.key});

  @override
  State<ViewProgressPage> createState() => _ViewProgressPageState();
}

class _ViewProgressPageState extends State<ViewProgressPage> {
  final user = FirebaseAuth.instance.currentUser;

  /// Calculates current consecutive streak from a list of sorted dates
  int calculateStreak(List<DateTime> sortedDates) {
    if (sortedDates.isEmpty) return 0;

    int streak = 1;
    DateTime previousDate = sortedDates[0];

    for (int i = 1; i < sortedDates.length; i++) {
      DateTime currentDate = sortedDates[i];
      if (previousDate.difference(currentDate).inDays == 1) {
        streak++;
        previousDate = currentDate;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view progress')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Progress'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('journals')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No logs yet'));
          }

          // Group entries by date
          Map<String, Set<String>> dailySymptoms = {};
          List<DateTime> dateList = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['date'] as Timestamp?;
            if (timestamp == null) continue;

            final dateKey = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
            dateList.add(DateTime.parse(dateKey));

            final symptoms =
                (data['symptoms'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toSet() ??
                {};

            if (dailySymptoms.containsKey(dateKey)) {
              dailySymptoms[dateKey]!.addAll(symptoms);
            } else {
              dailySymptoms[dateKey] = symptoms;
            }
          }

          // Sort dates descending for display
          final sortedDates = dailySymptoms.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          // Sort dates ascending for streak calculation
          dateList.sort((a, b) => b.compareTo(a));
          final streak = calculateStreak(dateList);

          return Column(
            children: [
              // Streak display
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "Current Streak: ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$streak days",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final symptoms = dailySymptoms[date]!.toList();

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: symptoms.map((symptom) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    border: Border.all(color: Colors.purple),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    symptom,
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
