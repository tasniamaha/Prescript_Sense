import 'package:flutter/material.dart';
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
              MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              ),
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
              Icon(
                Icons.document_scanner,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload your prescription image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Our AI will read, analyze, and check safety issues.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                onPressed: () => _pickImage(context, ImageOrigin.camera),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                onPressed: () => _pickImage(context, ImageOrigin.gallery),
              ),
              const SizedBox(height: 30),
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
                child: const Text('Analyze Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}