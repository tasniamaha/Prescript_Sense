import 'package:flutter/material.dart';

class HandwrittenToTextPage extends StatelessWidget {
  const HandwrittenToTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwritten to Text (OCR)'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // OCR Icon
              Icon(
                Icons.text_snippet_outlined,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Convert Handwritten Prescription',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Our AI will read handwritten or printed prescriptions and convert them into clear digital text.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              // Upload / Scan Button
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add OCR logic here
                  _showDummyResult(context);
                },
                icon: const Icon(Icons.document_scanner),
                label: const Text('Scan Prescription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Upload from gallery
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Gallery OCR
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dummy OCR Result Dialog (for demo)
  void _showDummyResult(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Extracted Text'),
        content: const Text(
          '• Paracetamol 500mg\n'
          '• Amoxicillin 500mg\n'
          '• Take twice daily after food\n'
          '• Duration: 5 days',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
