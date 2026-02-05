import 'package:flutter/material.dart';

class PrescriptionScannerPage extends StatelessWidget {
  const PrescriptionScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Prescription'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanner Frame
            Container(
              height: 320,
              width: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Corner accents
                  _scannerCorner(Alignment.topLeft),
                  _scannerCorner(Alignment.topRight),
                  _scannerCorner(Alignment.bottomLeft),
                  _scannerCorner(Alignment.bottomRight),

                  // Scan icon
                  const Center(
                    child: Icon(
                      Icons.document_scanner_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Instruction
            const Text(
              'Align prescription inside the frame',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              'Make sure the text is clear and well-lit for accurate AI analysis.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Scan button
            ElevatedButton.icon(
              onPressed: () {
                // Camera scan placeholder
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Now'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gallery button
            TextButton.icon(
              onPressed: () {
                // Gallery placeholder
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Upload from Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scannerCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: Colors.blue, width: 3)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.blue, width: 3)
                : BorderSide.none,
            left: alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: Colors.blue, width: 3)
                : BorderSide.none,
            right: alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.blue, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
