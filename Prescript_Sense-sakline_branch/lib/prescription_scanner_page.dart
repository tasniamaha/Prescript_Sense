import 'package:flutter/material.dart';
import 'app_colors.dart'; // Ensure you import your new color palette

class PrescriptionScannerPage extends StatelessWidget {
  const PrescriptionScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Minimal clean background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        title: const Text(
          'Scan Prescription',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- SCANNER VIEWFINDER ---
            Center(
              child: Container(
                height: 360,
                width: 280,
                decoration: BoxDecoration(
                  color: AppColors
                      .white, // Clean white surface for the placeholder
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.mist, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Corner accents
                    _scannerCorner(Alignment.topLeft),
                    _scannerCorner(Alignment.topRight),
                    _scannerCorner(Alignment.bottomLeft),
                    _scannerCorner(Alignment.bottomRight),

                    // Center Placeholder Icon & Text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_outlined,
                            size: 80,
                            color: AppColors.teal.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Camera Preview",
                            style: TextStyle(
                              color: AppColors.ash,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- INSTRUCTIONS ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Align prescription inside the frame',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Make sure the text is clear and well-lit for accurate AI analysis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.slate,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // --- ACTION BUTTONS ---

            // Scan Button (Primary Action)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Camera scan placeholder logic
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text(
                    'Scan Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Gallery Button (Secondary Action)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Gallery placeholder logic
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text(
                    'Upload from Gallery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.mist, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to draw the crisp camera frame corners
  Widget _scannerCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          border: Border(
            top:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: AppColors.teal, width: 4)
                : BorderSide.none,
            bottom:
                alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.teal, width: 4)
                : BorderSide.none,
            left:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: AppColors.teal, width: 4)
                : BorderSide.none,
            right:
                alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.teal, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
