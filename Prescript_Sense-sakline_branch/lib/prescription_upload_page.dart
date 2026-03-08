// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'prescription_result_page.dart';
// import 'dashboard_page.dart';

// class PrescriptionUploadPage extends StatefulWidget {
//   const PrescriptionUploadPage({super.key});

//   @override
//   State<PrescriptionUploadPage> createState() => _PrescriptionUploadPageState();
// }

// class _PrescriptionUploadPageState extends State<PrescriptionUploadPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Prescription'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const DashboardPage()),
//             );
//           },
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromRGBO(103, 184, 246, 1),
//               Color(0xFFDDF2FF),
//               Color(0xFFF8FCFF),
//               Color.fromARGB(255, 166, 214, 240),
//             ],
//             stops: [0.0, 0.3, 0.6, 1.0],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _selectedImage != null
//                     ? Container(
//                         height: 300,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.blueAccent),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.file(_selectedImage!, fit: BoxFit.cover),
//                         ),
//                       )
//                     : Container(
//     height: MediaQuery.of(context).size.height * 0.25,
//     width: MediaQuery.of(context).size.width * 0.6,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Image.asset(
//       'assets/image/upload_prescription.png',
//       fit: BoxFit.contain,
//     ),
//   ),


//                 const SizedBox(height: 20),

//                 Text(
//                   _selectedImage != null
//                       ? 'Prescription Selected'
//                       : 'Upload your prescription image',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 10),

//                 if (_selectedImage == null)
//                   const Text(
//                     'Our app will read, analyze, and check safety issues.',
//                     textAlign: TextAlign.center,
//                   ),

//                 const SizedBox(height: 40),

//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text('Take Photo'),
//                   onPressed: () => _pickImage(ImageSource.camera),
//                 ),

//                 const SizedBox(height: 15),

//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.photo_library),
//                   label: const Text('Choose from Gallery'),
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                 ),

//                 const SizedBox(height: 30),

//                 ElevatedButton(
//                   onPressed: _selectedImage == null
//                       ? null
//                       : () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PrescriptionResultPage(
//                                 imagePath: _selectedImage!.path,
//                               ),
//                             ),
//                           );
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _selectedImage == null ? Colors.grey : null,
//                   ),
//                   child: const Text('Analyze Prescription'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart'; // Your minimal color palette
import 'prescription_result_page.dart';

class PrescriptionUploadPage extends StatefulWidget {
  const PrescriptionUploadPage({super.key});

  @override
  State<PrescriptionUploadPage> createState() => _PrescriptionUploadPageState();
}

class _PrescriptionUploadPageState extends State<PrescriptionUploadPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Ensure high quality for OCR
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to pick image. Please try again.'),
          backgroundColor: AppColors.alertRed, // Semantic danger color
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _analyzePrescription() {
    if (_image == null) return;
    
    // Show a brief loading state before navigating
    setState(() => _isLoading = true);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionResultPage(imagePath: _image!.path),
        ),
      );
    });
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Clean minimal background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        title: const Text(
          'Upload Prescription',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Let's read your prescription",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Snap a clear photo of your handwritten or printed prescription, or upload one from your gallery.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.slate,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // --- IMAGE PREVIEW AREA ---
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _image == null ? AppColors.mist : AppColors.teal.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _image != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: IconButton(
                                onPressed: _clearImage,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.white.withOpacity(0.9),
                                  foregroundColor: AppColors.alertRed,
                                ),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: "Remove Image",
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.mist,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.document_scanner_outlined,
                                size: 48,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No prescription selected",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // --- SELECTION BUTTONS ---
              if (_image == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: "Camera",
                        onTap: () => _pickImage(ImageSource.camera),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_outlined,
                        label: "Gallery",
                        onTap: () => _pickImage(ImageSource.gallery),
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // --- ANALYZE BUTTON (Only visible when image is selected) ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _analyzePrescription,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      _isLoading ? "Processing..." : "Analyze Prescription",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal, // Primary Action color
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the Camera/Gallery buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.deepTeal : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? AppColors.deepTeal : AppColors.mist,
            width: 1.5,
          ),
          boxShadow: [
            if (!isPrimary)
              BoxShadow(
                color: AppColors.ink.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? AppColors.white : AppColors.teal,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppColors.white : AppColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}