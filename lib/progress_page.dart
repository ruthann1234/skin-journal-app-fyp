import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _journalStream;

  @override
  void initState() {
    super.initState();
    if (uid != null) {
      _journalStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('journals')
          .orderBy('date', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) return _notLoggedIn();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _journalStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) return _emptyState();

          final docs = snap.data!.docs;

          final entries = docs.map((d) {
            final data = d.data();
            final ts = data['date'] as Timestamp?;
            final date = ts?.toDate() ?? DateTime.now();

            // Images
            final List<String> images = [];
            if (data['imageUrls'] != null) {
              if (data['imageUrls'] is List) {
                images.addAll(
                  (data['imageUrls'] as List).map((e) => e.toString()),
                );
              } else if (data['imageUrls'] is Map) {
                images.addAll(
                  (data['imageUrls'] as Map).values.map((e) => e.toString()),
                );
              } else if (data['imageUrls'] is String) {
                images.add(data['imageUrls']);
              }
            }

            // Symptoms
            final List<String> symptoms =
                (data['symptoms'] as List<dynamic>?)
                    ?.map((s) => s.toString())
                    .toList() ??
                [];

            return {
              'date': date,
              'photos': images,
              'score': _calculateScore(data),
              'symptoms': symptoms,
            };
          }).toList();

          // Sort oldest to newest
          entries.sort(
            (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
          );

          final last7 = entries.reversed.take(7).toList().reversed.toList();
          final streak = _uniqueLoggedDays(last7);
          final consistency = last7.isEmpty
              ? "0 / 0 days"
              : "$streak / ${last7.length} days";

          // Most logged symptom
          final mostSymptomList = last7
              .map((e) => (e['symptoms'] as List<String>))
              .expand((list) => list)
              .toList();
          final mostSymptom = _mostCommon(mostSymptomList);

          // Chart
          final chartPoints = _prepareChartPoints(last7);

          // Before/After Photos
          List<String> allPhotos = [];
          for (var entry in last7) {
            final photosRaw = entry['photos'];
            if (photosRaw != null &&
                photosRaw is List<String> &&
                photosRaw.isNotEmpty) {
              allPhotos.addAll(photosRaw.where((p) => p.isNotEmpty));
            }
          }
          String? beforePhoto = allPhotos.isNotEmpty ? allPhotos.first : null;
          String? afterPhoto = allPhotos.isNotEmpty ? allPhotos.last : null;

          final highlight = _generateHighlight(last7, streak);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Progress",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Track your skin journey over time",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryPill(
                      title: 'Skin Trend\nSummary',
                      subtitle: 'See recent trend',
                    ),
                    _summaryPill(
                      title: 'Most logged\nsymptom',
                      subtitle: mostSymptom.isNotEmpty ? mostSymptom : 'N/A',
                    ),
                    _summaryPill(
                      title: 'Logging\nConsistency',
                      subtitle: consistency,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  "Skin Progress Over Time",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomPaint(
                        painter: _LineChartPainter(points: chartPoints),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Photo Comparison",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _photoCard("Before\n(Week start)", beforePhoto),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _photoCard("After\n(Week end)", afterPhoto),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Highlight of the week",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.purple[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      highlight,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _photoCard(String label, String? photoUrl) => Column(
    children: [
      Text(label, textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
          image: photoUrl != null
              ? DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: photoUrl == null
            ? const Icon(Icons.image, size: 40, color: Colors.purple)
            : null,
      ),
    ],
  );

  int _calculateScore(Map<String, dynamic> data) {
    final products = data['products'] as Map<String, dynamic>? ?? {};
    int score = 0;

    products.forEach((key, value) {
      if (value is Map && (value['selected'] ?? false)) {
        final reaction = (value['reaction'] ?? '').toString();
        score += reaction.isEmpty ? 2 : 1;
      }
    });

    return score.clamp(0, 5);
  }

  Widget _summaryPill({required String title, required String subtitle}) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      );

  Widget _notLoggedIn() => Scaffold(
    appBar: AppBar(
      title: const Text('Progress'),
      backgroundColor: const Color(0xFF9C27B0),
    ),
    body: const Center(child: Text('Please sign in to see progress')),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.show_chart, size: 64, color: Colors.purple),
          SizedBox(height: 12),
          Text("No logs yet", style: TextStyle(fontSize: 18)),
          SizedBox(height: 6),
          Text(
            "Add your first journal entry to see progress here.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  String _mostCommon(List<String> items) {
    if (items.isEmpty) return '';
    final freq = <String, int>{};
    for (var it in items) {
      freq[it] = (freq[it] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  int _uniqueLoggedDays(List<Map<String, dynamic>> entries) {
    final daysSet = <String>{};
    for (var e in entries) {
      final d = e['date'] as DateTime;
      daysSet.add(DateFormat('yyyy-MM-dd').format(d));
    }
    return daysSet.length;
  }

  List<double> _prepareChartPoints(List<Map<String, dynamic>> entries) =>
      entries.isEmpty
      ? [3.0]
      : entries.map((e) => (e['score'] as num).toDouble()).toList();

  String _generateHighlight(List<Map<String, dynamic>> entries, int streak) {
    final messages = [
      "Well done! You logged ${entries.length} times this week.",
      "Keep it up! You have a $streak-day streak.",
      "Great! Keep consistency this week.",
      "You're on track! Keep logging daily.",
      "Awesome! Keep maintaining your skin journal.",
    ];

    if (entries.isEmpty) {
      return "No highlights yet — keep logging to see insights.";
    }

    return messages[Random().nextInt(messages.length)];
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> points;
  _LineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paintLine = Paint()
      ..color = const Color(0xFF9C27B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    if (points.isEmpty) return;

    final minv = points.reduce(min);
    final maxv = points.reduce(max);
    final range = (maxv - minv) == 0 ? 1.0 : (maxv - minv);

    final stepX = points.length == 1
        ? size.width / 2
        : size.width / (points.length - 1);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalized = (points[i] - minv) / range;
      final y = size.height - normalized * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill under line
    final fillPaint = Paint()..color = const Color(0xFF9C27B0).withOpacity(0.2);
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paintLine);

    // Draw dots
    final dotPaint = Paint()..color = const Color(0xFF9C27B0);
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalized = (points[i] - minv) / range;
      final y = size.height - normalized * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points;
}
