// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'app_colors.dart'; // Your minimal color palette

// // Ensure you use your actual API key or environment variable here
// const String GEMINI_API_KEY = 'AIzaSyCEthUPyxgV5btJ_yV-ue0XV62ldrWfobE';

// class PrescriptionResultPage extends StatefulWidget {
//   final String imagePath;

//   const PrescriptionResultPage({super.key, required this.imagePath});

//   @override
//   State<PrescriptionResultPage> createState() => _PrescriptionResultPageState();
// }

// class _PrescriptionResultPageState extends State<PrescriptionResultPage> {
//   bool _isLoading = true;
//   String _extractedText = "";
//   String _geminiAnalysis = "";
//   bool _hasError = false;

//   late GenerativeModel _model;
//   late FlutterTts _tts;
//   bool _isSpeaking = false;

//   @override
//   void initState() {
//     super.initState();
//     _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
//     _tts = FlutterTts();
//     _tts.setCompletionHandler(() {
//       if (mounted) setState(() => _isSpeaking = false);
//     });
//     _processImage();
//   }

//   @override
//   void dispose() {
//     _tts.stop();
//     super.dispose();
//   }

//   Future<void> _processImage() async {
//     try {
//       // 1. OCR Extraction
//       final inputImage = InputImage.fromFilePath(widget.imagePath);
//       final textRecognizer = TextRecognizer(
//         script: TextRecognitionScript.latin,
//       );
//       final RecognizedText recognizedText = await textRecognizer.processImage(
//         inputImage,
//       );
//       await textRecognizer.close();

//       _extractedText = recognizedText.text;

//       if (_extractedText.trim().isEmpty) {
//         throw Exception("No text could be read from the image.");
//       }

//       // 2. Gemini Analysis
//       final prompt =
//           '''
// You are a medical assistant analyzing a raw OCR scan of a prescription.
// Extract the medicines, dosages, and instructions clearly.
// Format the output nicely with bullet points.
// If it doesn't look like a prescription, say so politely.

// Raw OCR Text:
// $_extractedText
// ''';

//       final response = await _model.generateContent([Content.text(prompt)]);

//       if (mounted) {
//         setState(() {
//           _geminiAnalysis =
//               response.text ?? "Could not analyze the prescription.";
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _geminiAnalysis = "Error processing prescription: ${e.toString()}";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _toggleSpeech() async {
//     if (_isSpeaking) {
//       await _tts.stop();
//       setState(() => _isSpeaking = false);
//     } else {
//       if (_geminiAnalysis.isNotEmpty) {
//         setState(() => _isSpeaking = true);
//         await _tts.speak(_geminiAnalysis);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cloud, // Minimal background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: AppColors.deepTeal,
//         title: const Text(
//           'Analysis Result',
//           style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
//         ),
//         centerTitle: true,
//         actions: [
//           if (!_isLoading && _geminiAnalysis.isNotEmpty)
//             IconButton(
//               icon: Icon(
//                 _isSpeaking
//                     ? Icons.stop_circle_rounded
//                     : Icons.volume_up_rounded,
//                 color: _isSpeaking ? AppColors.alertRed : AppColors.teal,
//                 size: 28,
//               ),
//               onPressed: _toggleSpeech,
//               tooltip: _isSpeaking ? "Stop Reading" : "Read Aloud",
//             ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: _isLoading ? _buildLoadingState() : _buildResultContent(),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: AppColors.softLavender,
//               shape: BoxShape.circle,
//             ),
//             child: const CircularProgressIndicator(
//               color: AppColors.lavenderBlue,
//               strokeWidth: 3,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             "Scanning & Analyzing...",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: AppColors.lavenderBlue,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Reading handwriting and extracting medicines",
//             style: TextStyle(color: AppColors.slate, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- IMAGE PREVIEW ---
//           const Text(
//             "Original Scan",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.slate,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             height: 180,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: AppColors.mist, width: 2),
//               image: DecorationImage(
//                 image: FileImage(File(widget.imagePath)),
//                 fit: BoxFit.cover,
//                 alignment: Alignment.topCenter,
//               ),
//             ),
//           ),

//           const SizedBox(height: 32),

//           // --- AI ANALYSIS RESULTS (Using Accent Colors) ---
//           Row(
//             children: [
//               const Icon(
//                 Icons.auto_awesome,
//                 color: AppColors.lavenderBlue,
//                 size: 24,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 "Prescription Details",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.ink,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: _hasError ? AppColors.softRed : AppColors.softLavender,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: _hasError
//                     ? AppColors.alertRed
//                     : AppColors.lavenderBlue.withOpacity(0.5),
//                 width: 1.5,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.ink.withOpacity(0.03),
//                   blurRadius: 16,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (!_hasError)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: AppColors.white.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       "AI Verified Text",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.lavenderBlue,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 Text(
//                   _geminiAnalysis,
//                   style: TextStyle(
//                     fontSize: 16,
//                     height: 1.6,
//                     color: _hasError ? AppColors.alertRed : AppColors.ink,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 32),

//           // --- RAW OCR TEXT (Collapsible/Secondary) ---
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               tilePadding: EdgeInsets.zero,
//               title: const Text(
//                 "View Raw Extracted Text",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.slate,
//                 ),
//               ),
//               iconColor: AppColors.teal,
//               collapsedIconColor: AppColors.slate,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: AppColors.mist),
//                   ),
//                   child: Text(
//                     _extractedText,
//                     style: const TextStyle(
//                       fontFamily: 'monospace',
//                       fontSize: 13,
//                       color: AppColors.slate,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'app_colors.dart';
// import 'ocr_service.dart'; // Make sure this points to the new service we just wrote!

// class PrescriptionResultPage extends StatefulWidget {
//   final String imagePath;

//   const PrescriptionResultPage({super.key, required this.imagePath});

//   @override
//   State<PrescriptionResultPage> createState() => _PrescriptionResultPageState();
// }

// class _PrescriptionResultPageState extends State<PrescriptionResultPage> {
//   bool _isLoading = true;
//   bool _hasError = false;

//   String _rawJson = "";
//   Map<String, dynamic>? _parsedData;

//   late FlutterTts _tts;
//   bool _isSpeaking = false;

//   // Initialize our new Gemini-powered OCR Service
//   final OcrService _ocrService = OcrService();

//   @override
//   void initState() {
//     super.initState();
//     _tts = FlutterTts();
//     _tts.setCompletionHandler(() {
//       if (mounted) setState(() => _isSpeaking = false);
//     });
//     _processImage();
//   }

//   @override
//   void dispose() {
//     _tts.stop();
//     super.dispose();
//   }

//   Future<void> _processImage() async {
//     try {
//       // 1. Send the image directly to Gemini via our new service
//       String jsonString = await _ocrService.processImage(widget.imagePath);

//       // --- JSON SANITIZATION ---
//       jsonString = jsonString.trim();

//       // Strip Markdown code blocks if Gemini accidentally included them
//       if (jsonString.startsWith('```')) {
//         jsonString = jsonString.replaceAll(RegExp(r'^```(json)?\n?'), '');
//         jsonString = jsonString.replaceAll(RegExp(r'\n?```$'), '');
//       }

//       // Replace any remaining literal unescaped tabs with spaces
//       jsonString = jsonString.replaceAll('\t', ' ');
//       // -------------------------

//       if (mounted) {
//         setState(() {
//           _rawJson = jsonString;
//           // 2. Parse the sanitized JSON string
//           try {
//             _parsedData = json.decode(jsonString);
//             if (_parsedData!.containsKey('error')) {
//               _hasError = true;
//             }
//           } catch (e) {
//             _hasError = true;
//             _parsedData = {"error": "Failed to parse JSON: $e"};
//           }
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _rawJson = '{"error": "${e.toString()}"}';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _toggleSpeech() async {
//     if (_isSpeaking) {
//       await _tts.stop();
//       setState(() => _isSpeaking = false);
//     } else {
//       if (_parsedData != null && !_hasError) {
//         setState(() => _isSpeaking = true);

//         // Build a readable string for the TTS to speak
//         String speechText = "Prescription Analysis. ";
//         final name = _parsedData!['patientName'];
//         if (name != null) speechText += "Patient name: $name. ";

//         final meds = _parsedData!['medicines'] as List<dynamic>?;
//         if (meds != null && meds.isNotEmpty) {
//           speechText += "Medicines prescribed are: ";
//           for (var med in meds) {
//             final medName =
//                 med['brandName'] ?? med['genericName'] ?? 'Unknown medicine';
//             final dose = med['dosage'] ?? '';
//             final timing = med['timing'] ?? '';
//             speechText += "$medName, $dose, $timing. ";
//           }
//         } else {
//           speechText += "No medicines were found.";
//         }

//         await _tts.speak(speechText);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cloud,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: AppColors.deepTeal,
//         title: const Text(
//           'Analysis Result',
//           style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
//         ),
//         centerTitle: true,
//         actions: [
//           if (!_isLoading && !_hasError)
//             IconButton(
//               icon: Icon(
//                 _isSpeaking
//                     ? Icons.stop_circle_rounded
//                     : Icons.volume_up_rounded,
//                 color: _isSpeaking ? AppColors.alertRed : AppColors.teal,
//                 size: 28,
//               ),
//               onPressed: _toggleSpeech,
//               tooltip: _isSpeaking ? "Stop Reading" : "Read Aloud",
//             ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: _isLoading ? _buildLoadingState() : _buildResultContent(),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: const BoxDecoration(
//               color: AppColors.softLavender,
//               shape: BoxShape.circle,
//             ),
//             child: const CircularProgressIndicator(
//               color: AppColors.lavenderBlue,
//               strokeWidth: 3,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             "Gemini is Analyzing...",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: AppColors.lavenderBlue,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Extracting patient info and medicines directly from image",
//             style: TextStyle(color: AppColors.slate, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultContent() {
//     final meds = _parsedData?['medicines'] as List<dynamic>? ?? [];

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- IMAGE PREVIEW ---
//           Container(
//             height: 180,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: AppColors.mist, width: 2),
//               image: DecorationImage(
//                 image: FileImage(File(widget.imagePath)),
//                 fit: BoxFit.cover,
//                 alignment: Alignment.topCenter,
//               ),
//             ),
//           ),

//           const SizedBox(height: 32),

//           if (_hasError)
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: AppColors.softRed,
//               child: Text(
//                 _parsedData?['error'] ?? "An unknown error occurred",
//                 style: const TextStyle(color: AppColors.alertRed),
//               ),
//             )
//           else ...[
//             // --- PATIENT INFO CARD ---
//             const Text(
//               "Patient Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.ink,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: AppColors.mist),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildInfoItem(
//                       Icons.person_outline,
//                       "Name",
//                       _parsedData?['patientName'],
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildInfoItem(
//                       Icons.cake_outlined,
//                       "Age",
//                       _parsedData?['patientAge'],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // --- MEDICINES LIST ---
//             const Text(
//               "Prescribed Medicines",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.ink,
//               ),
//             ),
//             const SizedBox(height: 12),

//             if (meds.isEmpty)
//               const Text(
//                 "No medicines could be extracted.",
//                 style: TextStyle(color: AppColors.slate),
//               )
//             else
//               ...meds.map((med) => _buildMedicineCard(med)),

//             const SizedBox(height: 40),

//             // --- RAW JSON VIEWER (For Debugging) ---
//             Theme(
//               data: Theme.of(
//                 context,
//               ).copyWith(dividerColor: Colors.transparent),
//               child: ExpansionTile(
//                 tilePadding: EdgeInsets.zero,
//                 title: const Text(
//                   "View Raw JSON Output",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.slate,
//                   ),
//                 ),
//                 iconColor: AppColors.teal,
//                 collapsedIconColor: AppColors.slate,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppColors.ink, // Dark background for code
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       _rawJson,
//                       style: const TextStyle(
//                         fontFamily: 'monospace',
//                         fontSize: 13,
//                         color: AppColors.softGreen,
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoItem(IconData icon, String label, String? value) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.teal, size: 20),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(color: AppColors.slate, fontSize: 12),
//             ),
//             Text(
//               value ?? "Not found",
//               style: const TextStyle(
//                 color: AppColors.ink,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMedicineCard(dynamic med) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.softLavender.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.lavenderBlue.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.medication, color: AppColors.lavenderBlue),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   med['brandName'] ?? med['genericName'] ?? 'Unknown Medicine',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.ink,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           if (med['genericName'] != null && med['brandName'] != null) ...[
//             const SizedBox(height: 4),
//             Text(
//               "Generic: ${med['genericName']}",
//               style: const TextStyle(color: AppColors.slate, fontSize: 13),
//             ),
//           ],
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: Divider(color: AppColors.white, height: 1),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildInfoItem(
//                   Icons.monitor_weight_outlined,
//                   "Dosage",
//                   med['dosage'],
//                 ),
//               ),
//               Expanded(
//                 child: _buildInfoItem(
//                   Icons.access_time_rounded,
//                   "Timing",
//                   med['timing'],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_colors.dart';
import 'auth_service.dart';
import 'ocr_service.dart';

class PrescriptionResultPage extends StatefulWidget {
  final String imagePath;

  const PrescriptionResultPage({super.key, required this.imagePath});

  @override
  State<PrescriptionResultPage> createState() => _PrescriptionResultPageState();
}

class _PrescriptionResultPageState extends State<PrescriptionResultPage> {
  bool _isLoading = true;
  bool _hasError = false;

  String _rawJson = "";
  Map<String, dynamic>? _parsedData;

  late FlutterTts _tts;
  bool _isSpeaking = false;

  final OcrService _ocrService = OcrService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _processImage();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _processImage() async {
    try {
      // 1. Fetch user medical context
      final profile = await _authService.getMedicalProfile();

      // 2. Send image and context to Gemini
      String jsonString = await _ocrService.processImage(widget.imagePath, profile);

      jsonString = jsonString.trim();
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.replaceAll(RegExp(r'^```(json)?\n?'), '');
        jsonString = jsonString.replaceAll(RegExp(r'\n?```$'), '');
      }
      jsonString = jsonString.replaceAll('\t', ' ');

      if (mounted) {
        setState(() {
          _rawJson = jsonString;
          try {
            _parsedData = json.decode(jsonString);
            if (_parsedData!.containsKey('error')) {
              _hasError = true;
            }
          } catch (e) {
            _hasError = true;
            _parsedData = {"error": "Failed to parse JSON: $e"};
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _rawJson = '{"error": "${e.toString()}"}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      if (_parsedData != null && !_hasError) {
        setState(() => _isSpeaking = true);

        String speechText = "Prescription Analysis. ";
        final meds = _parsedData!['medicines'] as List<dynamic>?;
        
        if (meds != null && meds.isNotEmpty) {
          speechText += "Medicines prescribed are: ";
          for (var med in meds) {
            final medName = med['brandName'] ?? med['genericName'] ?? 'Unknown medicine';
            final dose = med['dosage'] ?? '';
            final timing = med['timing'] ?? '';
            speechText += "$medName, $dose, $timing. ";
            
            // Add safety warnings to TTS
            if (med['dosageSafety'] != null) speechText += "Warning: ${med['dosageSafety']}. ";
            if (med['frequencySafety'] != null) speechText += "Warning: ${med['frequencySafety']}. ";
            if (med['interactionWarning'] != null) speechText += "Warning: ${med['interactionWarning']}. ";
          }
        } else {
          speechText += "No medicines were found.";
        }

        await _tts.speak(speechText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        title: const Text(
          'Analysis Result',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && !_hasError)
            IconButton(
              icon: Icon(
                _isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                color: _isSpeaking ? AppColors.alertRed : AppColors.teal,
                size: 28,
              ),
              onPressed: _toggleSpeech,
              tooltip: _isSpeaking ? "Stop Reading" : "Read Aloud",
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildResultContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.softLavender,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.lavenderBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Gemini is Analyzing...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lavenderBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Verifying dosages against your profile",
            style: TextStyle(color: AppColors.slate, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final meds = _parsedData?['medicines'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.mist, width: 2),
              image: DecorationImage(
                image: FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: 32),

          if (_hasError)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.softRed,
              child: Text(
                _parsedData?['error'] ?? "An unknown error occurred",
                style: const TextStyle(color: AppColors.alertRed),
              ),
            )
          else ...[
            const Text(
              "Prescribed Medicines & Safety Checks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink),
            ),
            const SizedBox(height: 12),

            if (meds.isEmpty)
              const Text("No medicines could be extracted.", style: TextStyle(color: AppColors.slate))
            else
              ...meds.map((med) => _buildMedicineCard(med)),

            const SizedBox(height: 40),

            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  "View Raw JSON Output",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.slate),
                ),
                iconColor: AppColors.teal,
                collapsedIconColor: AppColors.slate,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _rawJson,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.softGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.slate, fontSize: 12)),
              Text(value ?? "Not found", style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(dynamic med) {
    final dosageWarning = med['dosageSafety'];
    final frequencyWarning = med['frequencySafety'];
    final interactionWarning = med['interactionWarning'];
    
    final bool hasWarnings = dosageWarning != null || frequencyWarning != null || interactionWarning != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasWarnings ? AppColors.alertRed.withOpacity(0.5) : AppColors.mist, width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasWarnings ? AppColors.softRed : AppColors.softLavender,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(Icons.medication, color: hasWarnings ? AppColors.alertRed : AppColors.lavenderBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    med['brandName'] ?? med['genericName'] ?? 'Unknown Medicine',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: hasWarnings ? AppColors.alertRed : AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
          
          // Prescription Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (med['genericName'] != null) ...[
                  Text("Generic: ${med['genericName']}", style: const TextStyle(color: AppColors.slate, fontSize: 14)),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.monitor_weight_outlined, "Prescribed Dose", med['dosage'])),
                    Expanded(child: _buildInfoItem(Icons.access_time_rounded, "Timing", med['timing'])),
                  ],
                ),
                
                // Safety Warnings
                if (hasWarnings) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.mist, height: 1),
                  ),
                  const Text("Safety Alerts", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  if (dosageWarning != null) _buildAlertRow(Icons.warning_amber_rounded, "Dosage: $dosageWarning"),
                  if (frequencyWarning != null) _buildAlertRow(Icons.timer_off_outlined, "Frequency: $frequencyWarning"),
                  if (interactionWarning != null) _buildAlertRow(Icons.medical_information_outlined, "Interaction: $interactionWarning"),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.mist, height: 1),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.safeGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text("Dosage and frequency appear safe for your profile.", style: TextStyle(color: AppColors.safeGreen.withOpacity(0.9), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.alertRed, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.alertRed, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}