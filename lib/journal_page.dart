import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<String> selectedFeelings = [];
  final TextEditingController dietController = TextEditingController();
  final TextEditingController letterController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Map<String, Map<String, dynamic>> productTracker = {
    'Cleanser': {'selected': false, 'reaction': '', 'opened': null},
    'Toner': {'selected': false, 'reaction': '', 'opened': null},
    'Moisturizer': {'selected': false, 'reaction': '', 'opened': null},
    'Sunscreen': {'selected': false, 'reaction': '', 'opened': null},
  };

  final List<Map<String, String>> skinFeelings = [
    {'label': 'Great', 'emoji': '😄'},
    {'label': 'Okay', 'emoji': '🙂'},
    {'label': 'Irritated', 'emoji': '😣'},
    {'label': 'Dry', 'emoji': '😕'},
    {'label': 'Oily', 'emoji': '😅'},
    {'label': 'Breaking out', 'emoji': '😖'},
    {'label': 'Sensitive', 'emoji': '😬'},
    {'label': 'Red', 'emoji': '🟥'},
    {'label': 'Itchy', 'emoji': '🤧'},
    {'label': 'Tight', 'emoji': '😣'},
    {'label': 'Bumpy', 'emoji': '🟤'},
    {'label': 'Uneven tone', 'emoji': '🎨'},
    {'label': 'Shiny', 'emoji': '✨'},
  ];

  final List<String> productReactions = [
    'No change 😐',
    'Redness 🔴',
    'Burning 🔥',
    'Irritation 😣',
    'Soothing 😌',
  ];

  final cloudinary = CloudinaryPublic(
    'duzlvvkdc',
    'journal_unsigned',
    cache: false,
  );

  File? _selectedImage;
  String? _uploadedImageUrl;

  // ---------------------- Auto 7-day comparison ----------------------
  Future<void> _saveForComparison(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('comparison')
        .doc('7day')
        .set({'latest': url, 'date': todayKey}, SetOptions(merge: true));
  }

  Future<String?> _fetchImageFromDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final key = DateFormat('yyyy-MM-dd').format(date);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(key)
        .get();

    if (doc.exists && doc.data()?['imageUrls'] != null) {
      List list = doc.data()?['imageUrls'];
      if (list.isNotEmpty) return list.last;
    }
    return null;
  }

  // ---------------------- Image picker & upload ----------------------
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path); // local variable, safe
    setState(() => _selectedImage = file);

    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'journal_unsigned',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      if (!mounted) return;
      setState(() => _uploadedImageUrl = response.secureUrl);

      // Auto save for 7-day comparison
      await _saveForComparison(response.secureUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  // ---------------------- Severity ----------------------
  String _calculateSeverity(List<String> feelings) {
    if (feelings.contains('Irritated') || feelings.contains('Breaking out')) {
      return 'red';
    } else if (feelings.contains('Dry') || feelings.contains('Oily')) {
      return 'yellow';
    }
    return 'green';
  }

  // ---------------------- Save journal ----------------------
  Future<void> saveJournalEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(dateKey);

    try {
      await docRef.set({
        'date': Timestamp.fromDate(selectedDate),
        'symptoms': FieldValue.arrayUnion(selectedFeelings),
        'severity': _calculateSeverity(selectedFeelings),
        'dietNote': FieldValue.arrayUnion([dietController.text]),
        'letter': FieldValue.arrayUnion([letterController.text]),
        'products': productTracker,
        'imageUrls': _uploadedImageUrl != null
            ? FieldValue.arrayUnion([_uploadedImageUrl!])
            : [],
      }, SetOptions(merge: true));

      // Auto 7-day comparison
      if (_uploadedImageUrl != null) {
        DateTime sevenDaysAgo = selectedDate.subtract(const Duration(days: 7));
        String? oldImage = await _fetchImageFromDate(sevenDaysAgo);
        if (oldImage != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('comparison')
              .doc('weekly')
              .collection('pairs')
              .doc(dateKey)
              .set({
                'today': _uploadedImageUrl!,
                'previous': oldImage,
                'todayDate': dateKey,
                'previousDate': DateFormat('yyyy-MM-dd').format(sevenDaysAgo),
              });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Journal saved!")));

      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save journal: $e")));
    }
  }

  // ---------------------- Pick custom date ----------------------
  Future<void> pickCustomDate() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (newDate != null) setState(() => selectedDate = newDate);
  }

  Future<void> _pickOpenedDate(String product) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (newDate != null) {
      setState(() {
        productTracker[product]!['opened'] = newDate;
      });
    }
  }

  // ---------------------- Build UI ----------------------
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Entry"),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Journal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // DATE PICKER
            Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: pickCustomDate,
                  child: const Text(
                    "Change Date",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // IMAGE UPLOAD
            GestureDetector(
              onTap: pickAndUploadImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Center(child: Text("Upload today's skin photo"))
                    : null,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "How's your skin feeling?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skinFeelings.map((feeling) {
                final label = feeling['label']!;
                final isSelected = selectedFeelings.contains(label);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? selectedFeelings.remove(label)
                          : selectedFeelings.add(label);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF9C27B0)
                            : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF9C27B0).withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          feeling['emoji']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 5),
                        Text(label),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              "Product Tracker",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...productTracker.keys.map((product) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: productTracker[product]!['selected'],
                            activeColor: const Color(0xFF9C27B0),
                            onChanged: (value) {
                              setState(() {
                                productTracker[product]!['selected'] =
                                    value ?? false;
                              });
                            },
                          ),
                          Text(
                            product,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _pickOpenedDate(product),
                            child: Text(
                              productTracker[product]!['opened'] != null
                                  ? DateFormat('yyyy-MM-dd').format(
                                      productTracker[product]!['opened']!,
                                    )
                                  : 'Opened on',
                              style: const TextStyle(color: Color(0xFF9C27B0)),
                            ),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: productTracker[product]!['reaction'].isEmpty
                            ? null
                            : productTracker[product]!['reaction'],
                        isExpanded: true,
                        hint: const Text("Reaction"),
                        items: productReactions.map((reaction) {
                          return DropdownMenuItem(
                            value: reaction,
                            child: Text(reaction),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            productTracker[product]!['reaction'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            const Text(
              "Diet and Lifestyle Log",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: dietController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your diet/lifestyle notes...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Letter to My Skin",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: letterController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write a letter to your skin...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: saveJournalEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
