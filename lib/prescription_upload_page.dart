import 'package:flutter/material.dart';
import 'prescription_result_page.dart';

class PrescriptionUploadPage extends StatelessWidget {
  const PrescriptionUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription'),
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
                onPressed: () {
                  // Placeholder
                },
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                onPressed: () {
                  // Placeholder
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescriptionResultPage(),
                    ),
                  );
                },
                child: const Text('Analyze Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
