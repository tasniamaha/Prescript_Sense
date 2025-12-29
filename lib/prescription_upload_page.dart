import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'prescription_result_page.dart';
import 'dashboard_page.dart';

class PrescriptionUploadPage extends StatefulWidget {
  const PrescriptionUploadPage({super.key});

  @override
  State<PrescriptionUploadPage> createState() => _PrescriptionUploadPageState();
}

class _PrescriptionUploadPageState extends State<PrescriptionUploadPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _selectedImage != null
                  ? Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    )
                  : Icon(
                      Icons.document_scanner,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),

              const SizedBox(height: 20),

              Text(
                _selectedImage != null
                    ? 'Prescription Selected'
                    : 'Upload your prescription image',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              if (_selectedImage == null)
                const Text(
                  'Our AI will read, analyze, and check safety issues.',
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                onPressed: () => _pickImage(ImageSource.camera),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),

              const SizedBox(height: 30),

              // This is the button that was causing issues
              ElevatedButton(
                onPressed: _selectedImage == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Note: No 'const' here because imagePath is dynamic
                            builder: (context) => PrescriptionResultPage(
                              imagePath: _selectedImage!.path,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedImage == null ? Colors.grey : null,
                ),
                child: const Text('Analyze Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
