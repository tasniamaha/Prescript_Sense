import 'dart:io';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:image_picker/image_picker.dart'; 
import 'package:prescript_sense/image_input/image_model.dart';
import 'package:prescript_sense/selected_prescription_image.dart';
import 'image_input/image_source_service.dart'; 

import 'prescription_result_page.dart';
import 'dashboard_page.dart';

class PrescriptionUploadPage extends StatelessWidget {
  PrescriptionUploadPage({super.key});
  
  final ImageSourceService _imageSourceService = ImageSourceService();

  Future<void> _pickImage(BuildContext context, ImageOrigin origin) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing image...')),
      );

      final image = origin == ImageOrigin.camera
          ? await _imageSourceService.pickFromCamera()
          : await _imageSourceService.pickFromGallery();

      if (image == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selection cancelled')),
        );
        return;
      }

      // Store the selected image
      SelectedPrescriptionImage.image = image;

      // Hide loading and navigate
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrescriptionResultPage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
=======
import 'package:image_picker/image_picker.dart';
import 'prescription_result_page.dart';
import 'dashboard_page.dart';

class PrescriptionUploadPage extends StatefulWidget {
  const PrescriptionUploadPage({super.key});
>>>>>>> sakline_branch

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
<<<<<<< HEAD
              MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              ),
=======
              MaterialPageRoute(builder: (context) => const DashboardPage()),
>>>>>>> sakline_branch
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
<<<<<<< HEAD
              Icon(
                Icons.document_scanner,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload your prescription image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
=======
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
>>>>>>> sakline_branch
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
<<<<<<< HEAD
              const Text(
                'Our AI will read, analyze, and check safety issues.',
                textAlign: TextAlign.center,
              ),
=======

              if (_selectedImage == null)
                const Text(
                  'Our AI will read, analyze, and check safety issues.',
                  textAlign: TextAlign.center,
                ),

>>>>>>> sakline_branch
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
<<<<<<< HEAD
                onPressed: () => _pickImage(context, ImageOrigin.camera),
=======
                onPressed: () => _pickImage(ImageSource.camera),
>>>>>>> sakline_branch
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
<<<<<<< HEAD
                onPressed: () => _pickImage(context, ImageOrigin.gallery),
=======
                onPressed: () => _pickImage(ImageSource.gallery),
>>>>>>> sakline_branch
              ),
              const SizedBox(height: 30),
<<<<<<< HEAD
              ElevatedButton(
                onPressed: SelectedPrescriptionImage.image != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrescriptionResultPage(),
                          ),
                        );
                      }
                    : null, // Disabled if no image selected
=======

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
>>>>>>> sakline_branch
                child: const Text('Analyze Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}