// import 'dart:io';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class OcrService {
//   // We use the same API key you already have in dashboard_page.dart
//   static const String _geminiApiKey = 'AIzaSyAusk8j5dVYldxmDKdM2tQsFTwEoyeuSN0';

//   late final GenerativeModel _model;

//   OcrService() {
//     // We configure Gemini to STRICTLY return a specific JSON structure
//     _model = GenerativeModel(
//       model: 'gemini-3.1-pro-preview',
//       apiKey: _geminiApiKey,
//       generationConfig: GenerationConfig(
//         responseMimeType: 'application/json',
//         responseSchema: Schema.object(
//           properties: {
//             'patientName': Schema.string(
//               nullable: true,
//               description: "The patient's name if written on the prescription",
//             ),
//             'patientAge': Schema.string(
//               nullable: true,
//               description: "The patient's age if written",
//             ),
//             'medicines': Schema.array(
//               items: Schema.object(
//                 properties: {
//                   'brandName': Schema.string(
//                     nullable: true,
//                     description: "The commercial brand name of the medicine",
//                   ),
//                   'genericName': Schema.string(
//                     nullable: true,
//                     description: "The generic chemical name of the medicine",
//                   ),
//                   'dosage': Schema.string(
//                     nullable: true,
//                     description:
//                         "The strength or amount, e.g., 500mg, 1 tablet",
//                   ),
//                   'timing': Schema.string(
//                     nullable: true,
//                     description: "When to take it, e.g., 1-0-1, after meals",
//                   ),
//                 },
//               ),
//             ),
//           },
//         ),
//       ),
//     );
//   }

//   /// Processes an image path using Gemini Vision and returns structured JSON.
//   Future<String> processImage(String imagePath) async {
//     try {
//       final file = File(imagePath);
//       final bytes = await file.readAsBytes();

//       // Determine basic mime type for Gemini
//       final extension = imagePath.split('.').last.toLowerCase();
//       final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';

//       // The exact prompt you requested
//       // final prompt = TextPart(
//       //   "Read this prescription image. Extract the patient's name (if present), "
//       //   "age (if present), names of medicine (both generic and brand names), "
//       //   "dosages and timings. Format it in json."
//       // );

//       final prompt = TextPart(
//         "Read this prescription image. Extract the patient's name (if present), "
//         "age (if present), names of medicine (both generic and brand names), "
//         "dosages and timings. Format it in json.\n"
//         "CRITICAL RULE: Do NOT use literal newlines, carriage returns, or control characters inside the JSON string values. "
//         "If a text value spans multiple lines on the image, combine them into a single string separated by spaces.",
//       );

//       final imagePart = DataPart(mimeType, bytes);

//       final response = await _model.generateContent([
//         Content.multi([prompt, imagePart]),
//       ]);

//       // Return the clean JSON string
//       return response.text ?? '{"error": "No data extracted"}';
//     } catch (e) {
//       return '{"error": "Failed to process image: $e"}';
//     }
//   }

//   /// Kept for backward compatibility with your existing codebase,
//   /// though Gemini doesn't require native memory cleanup like ML Kit did.
//   void dispose() {
//     // No native ML Kit resources to close anymore!
//   }
// }


// import 'dart:io';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class OcrService {
//   static const String _geminiApiKey = 'AIzaSyAusk8j5dVYldxmDKdM2tQsFTwEoyeuSN0';
//   late final GenerativeModel _model;

//   OcrService() {
//     _model = GenerativeModel(
//       model: 'gemini-2.5-flash',  // ✅ FIXED: Valid model name
//       apiKey: _geminiApiKey,
//       generationConfig: GenerationConfig(
//         responseMimeType: 'application/json',
//         responseSchema: Schema.object(
//           properties: {
//             'patientName': Schema.string(
//               nullable: true,
//               description: "The patient's name if written on the prescription",
//             ),
//             'patientAge': Schema.string(
//               nullable: true,
//               description: "The patient's age if written",
//             ),
//             'medicines': Schema.array(
//               items: Schema.object(
//                 properties: {
//                   'brandName': Schema.string(
//                     nullable: true,
//                     description: "The commercial brand name of the medicine",
//                   ),
//                   'genericName': Schema.string(
//                     nullable: true,
//                     description: "The generic chemical name of the medicine",
//                   ),
//                   'dosage': Schema.string(
//                     nullable: true,
//                     description: "The strength or amount, e.g., 500mg, 1 tablet",
//                   ),
//                   'timing': Schema.string(
//                     nullable: true,
//                     description: "When to take it, e.g., 1-0-1, after meals",
//                   ),
//                 },
//               ),
//             ),
//           },
//         ),
//       ),
//     );
//   }

//   Future<String> processImage(String imagePath) async {
//     try {
//       final file = File(imagePath);
//       final bytes = await file.readAsBytes();

//       final extension = imagePath.split('.').last.toLowerCase();
//       final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';

//       final prompt = TextPart(
//         "Read this prescription image. Extract the patient's name (if present), "
//         "age (if present), names of medicine (both generic and brand names), "
//         "dosages and timings. Return ONLY valid JSON with no extra text. "
//         "All string values must be on a single line with no newlines or control characters.",
//       );

//       final imagePart = DataPart(mimeType, bytes);

//       final response = await _model.generateContent([
//         Content.multi([prompt, imagePart]),
//       ]);

//       final raw = response.text ?? '{"error": "No data extracted"}';
//       return _sanitize(raw);
//     } catch (e) {
//       return '{"error": "Failed to process image: ${e.toString().replaceAll('"', "'")}"}';
//     }
//   }

//   /// Strips all control characters that break JSON parsing
//   String _sanitize(String input) {
//     // Remove markdown code fences
//     String result = input.trim();
//     result = result.replaceAll(RegExp(r'^```(json)?\s*'), '');
//     result = result.replaceAll(RegExp(r'\s*```$'), '');
//     result = result.trim();

//     // ✅ KEY FIX: Remove ALL ASCII control characters (0x00–0x1F) except
//     // the ones JSON allows inside strings: we'll replace them with a space.
//     // This catches \r, \n, \t, and any other rogue control chars.
//     result = result.replaceAllMapped(
//       RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), // excludes \t(\x09) \n(\x0A) \r(\x0D)
//       (_) => ' ',
//     );

//     // Normalize remaining whitespace within string values
//     result = result.replaceAll('\r\n', ' ');
//     result = result.replaceAll('\r', ' ');
//     result = result.replaceAll('\n', ' ');
//     result = result.replaceAll('\t', ' ');

//     return result;
//   }

//   void dispose() {}
// }

import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class OcrService {
  static const String _geminiApiKey = 'AIzaSyAusk8j5dVYldxmDKdM2tQsFTwEoyeuSN0';
  late final GenerativeModel _model;

  OcrService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'patientName': Schema.string(
              nullable: true,
              description: "The patient's name if written on the prescription",
            ),
            'patientAge': Schema.string(
              nullable: true,
              description: "The patient's age if written",
            ),
            'medicines': Schema.array(
              items: Schema.object(
                properties: {
                  'brandName': Schema.string(nullable: true),
                  'genericName': Schema.string(nullable: true),
                  'dosage': Schema.string(nullable: true),
                  'timing': Schema.string(nullable: true),
                  'dosageSafety': Schema.string(
                    nullable: true,
                    description: "Strict evaluation: Is this extracted dosage safe for the user's specific age and weight? Return a warning string if unsafe, or null if safe."
                  ),
                  'frequencySafety': Schema.string(
                    nullable: true,
                    description: "Strict evaluation: Is the extracted timing/frequency safe? Return a warning string if unsafe, or null if safe."
                  ),
                  'interactionWarning': Schema.string(
                    nullable: true,
                    description: "Warning if this medicine conflicts with the user's reported allergies or current medications. Return null if safe."
                  ),
                },
              ),
            ),
          },
        ),
      ),
    );
  }

  Future<String> processImage(String imagePath, Map<String, String> profile) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      final extension = imagePath.split('.').last.toLowerCase();
      final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';

      final prompt = TextPart('''
        Read this prescription image. Extract the patient's name, age, medicines, dosages, and timings.
        
        CRITICAL SAFETY CHECK: Cross-reference the extracted medicines, dosages, and timings with the user's medical profile:
        - Age: ${profile['age']}
        - Gender: ${profile['gender']}
        - Weight: ${profile['weight']} kg
        - Height: ${profile['height']} cm
        - Allergies: ${profile['allergies']}
        - Current Medications: ${profile['medications']}
        
        Evaluate if the exact dosage and frequency written on the prescription are safe for this specific user profile.
        Return ONLY valid JSON with no extra text. All string values must be on a single line with no control characters.
      ''');

      final imagePart = DataPart(mimeType, bytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final raw = response.text ?? '{"error": "No data extracted"}';
      return _sanitize(raw);
    } catch (e) {
      return '{"error": "Failed to process image: ${e.toString().replaceAll('"', "'")}"}';
    }
  }

  String _sanitize(String input) {
    String result = input.trim();
    result = result.replaceAll(RegExp(r'^```(json)?\s*'), '');
    result = result.replaceAll(RegExp(r'\s*```$'), '');
    result = result.trim();

    result = result.replaceAllMapped(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), 
      (_) => ' ',
    );

    result = result.replaceAll('\r\n', ' ');
    result = result.replaceAll('\r', ' ');
    result = result.replaceAll('\n', ' ');
    result = result.replaceAll('\t', ' ');

    return result;
  }
}