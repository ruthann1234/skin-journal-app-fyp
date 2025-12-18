import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:intl/intl.dart';

class AddLogPage extends StatefulWidget {
  const AddLogPage({super.key});

  @override
  State<AddLogPage> createState() => _AddLogPageState();
}

class _AddLogPageState extends State<AddLogPage> {
  final TextEditingController noteController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  final cloudinary = CloudinaryPublic(
    'duzlvvkdc',
    'journal_unsigned',
    cache: false,
  );

  List<String> selectedFeelings = [];
  final List<String> skinFeelings = [
    'Great',
    'Okay',
    'Irritated',
    'Dry',
    'Oily',
    'Breaking out',
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: ${e.message}')));
      return null;
    }
  }

  String _calculateSeverity(List<String> feelings) {
    if (feelings.contains('Irritated') || feelings.contains('Breaking out')) {
      return 'red';
    }
    if (feelings.contains('Dry') || feelings.contains('Oily')) return 'yellow';
    return 'green';
  }

  Future<void> saveLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a log')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl;
    if (_imageFile != null) imageUrl = await uploadImage(_imageFile!);

    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(dateKey);

    await docRef.set({
      'date': FieldValue.serverTimestamp(),
      'symptoms': FieldValue.arrayUnion(selectedFeelings),
      'severity': _calculateSeverity(selectedFeelings),
      'notes': FieldValue.arrayUnion([noteController.text]),
      'imageUrls': imageUrl != null ? FieldValue.arrayUnion([imageUrl]) : [],
    }, SetOptions(merge: true));

    setState(() => _isUploading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Log saved!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Quick Log"),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? const Center(child: Text("Upload skin photo"))
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "How's your skin feeling?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: skinFeelings.map((f) {
                final isSelected = selectedFeelings.contains(f);
                return FilterChip(
                  label: Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF9C27B0),
                  backgroundColor: Colors.grey[200],
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedFeelings.add(f);
                      } else {
                        selectedFeelings.remove(f);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: "Add a quick note (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Center(
              child: _isUploading
                  ? const CircularProgressIndicator(color: Color(0xFF9C27B0))
                  : ElevatedButton(
                      onPressed: saveLog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                      ),
                      child: const Text(
                        "Save Log",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
