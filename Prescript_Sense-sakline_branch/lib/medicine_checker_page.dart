// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'app_colors.dart';
// class MedicineCheckerPage extends StatefulWidget {
//   const MedicineCheckerPage({super.key});

//   @override
//   State<MedicineCheckerPage> createState() => _MedicineCheckerPageState();
// }

// class _MedicineCheckerPageState extends State<MedicineCheckerPage> {
//   final ImagePicker _picker = ImagePicker();
//   String _extractedText = "";
//   bool _isLoading = false;

//   Future<void> _processImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(source: source);
//       if (image == null) return;

//       setState(() => _isLoading = true);

//       final inputImage = InputImage.fromFilePath(image.path);
//       final textRecognizer = TextRecognizer(
//         script: TextRecognitionScript.latin,
//       );

//       final recognizedText = await textRecognizer.processImage(inputImage);
//       await textRecognizer.close();

//       if (!mounted) return;

//       setState(() {
//         _extractedText = recognizedText.text.isEmpty
//             ? "No text detected. Please try a clearer image."
//             : recognizedText.text;
//         _isLoading = false;
//       });

//       _showTextDialog(_extractedText);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Failed to process image.'),
//           backgroundColor: AppColors.alertRed,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }

//   void _showTextDialog(String text) {
//     final TextEditingController textController = TextEditingController(
//       text: text,
//     );

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppColors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             const Icon(Icons.document_scanner_outlined, color: AppColors.teal),
//             const SizedBox(width: 10),
//             const Text(
//               "Extracted Text",
//               style: TextStyle(
//                 color: AppColors.ink,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: TextField(
//             controller: textController,
//             maxLines: null,
//             style: const TextStyle(color: AppColors.ink, height: 1.5),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: AppColors.mist,
//               labelText: "Review or edit text",
//               labelStyle: const TextStyle(color: AppColors.slate),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(
//                   color: AppColors.deepTeal,
//                   width: 2,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               "Close",
//               style: TextStyle(color: AppColors.slate),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.deepTeal,
//               foregroundColor: AppColors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Done"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cloud,
//       appBar: AppBar(
//         title: const Text('Medicine Checker'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: AppColors.deepTeal,
//         centerTitle: true,
//         titleTextStyle: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//           color: AppColors.deepTeal,
//           letterSpacing: -0.5,
//         ),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // --- CLEAN TEXT HERO SECTION ---
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: const BoxDecoration(
//                   color: AppColors.mist,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.document_scanner_outlined,
//                   size: 56,
//                   color: AppColors.teal,
//                 ),
//               ),

//               const SizedBox(height: 32),

//               const Text(
//                 "Read the Label",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.ink,
//                   letterSpacing: -0.5,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   "Extract text directly from your medicine packaging. We'll digitize it so you can quickly search our database or check for warnings.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: AppColors.slate,
//                     height: 1.6,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 56),

//               // --- ACTION BUTTONS ---
//               if (_isLoading)
//                 const Padding(
//                   padding: EdgeInsets.all(32.0),
//                   child: CircularProgressIndicator(color: AppColors.deepTeal),
//                 )
//               else ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _processImage(ImageSource.camera),
//                     icon: const Icon(Icons.camera_alt_outlined),
//                     label: const Text(
//                       "Scan with Camera",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.deepTeal,
//                       foregroundColor: AppColors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () => _processImage(ImageSource.gallery),
//                     icon: const Icon(Icons.photo_library_outlined),
//                     label: const Text(
//                       "Upload from Gallery",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.teal,
//                       side: const BorderSide(color: AppColors.mist, width: 2),
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart';
import 'medicine_checker_result_page.dart';

class MedicineCheckerPage extends StatefulWidget {
  const MedicineCheckerPage({super.key});

  @override
  State<MedicineCheckerPage> createState() => _MedicineCheckerPageState();
}

class _MedicineCheckerPageState extends State<MedicineCheckerPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isLoading = true);

      // Brief delay for a smooth UX transition before navigating
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigate to the new personalized analysis page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineCheckerResultPage(imagePath: image.path),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to process image.'),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        title: const Text('Medicine Checker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- CLEAN TEXT HERO SECTION ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.mist,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 56,
                  color: AppColors.teal,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Read the Label",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Extract text directly from your medicine packaging. We'll digitize it so you can quickly search our database or check for warnings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.slate,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 56),

              // --- ACTION BUTTONS ---
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.deepTeal),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _processImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text(
                      "Scan with Camera",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _processImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text(
                      "Upload from Gallery",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      side: const BorderSide(color: AppColors.mist, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
}