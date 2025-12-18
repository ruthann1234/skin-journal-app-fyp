import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Sample data model (replace with Firebase later)
class SkinLog {
  final String symptom;
  final String note;
  final bool routineCompleted;

  SkinLog({
    required this.symptom,
    required this.note,
    required this.routineCompleted,
  });
}

// Sample logs for demonstration
final Map<String, List<SkinLog>> logsByDate = {
  "2025-11-21": [
    SkinLog(
      symptom: "Redness on cheeks",
      note: "Used new cream",
      routineCompleted: true,
    ),
    SkinLog(
      symptom: "Dry patches",
      note: "Applied moisturizer twice",
      routineCompleted: true,
    ),
  ],
  "2025-11-20": [
    SkinLog(
      symptom: "Acne breakout",
      note: "Skipped night routine",
      routineCompleted: false,
    ),
  ],
};

class DailySummaryPage extends StatefulWidget {
  const DailySummaryPage({super.key});

  @override
  State<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends State<DailySummaryPage> {
  // Default to today
  DateTime _selectedDate = DateTime.now();

  List<SkinLog> getLogsForDate(DateTime date) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    return logsByDate[key] ?? [];
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100), // allow future dates if needed
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = getLogsForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Summary"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Summary for: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: _pickDate,
                  child: const Text("Change Date"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Logs
            Expanded(
              child: logs.isEmpty
                  ? const Center(
                      child: Text(
                        "No skin logs for this day.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              log.routineCompleted
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: log.routineCompleted
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              log.symptom,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(log.note),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
