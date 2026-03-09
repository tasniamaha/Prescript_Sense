import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class MedicineCheckerService {
  // Using the same key from your dashboard_page.dart
  static const String _geminiApiKey = 'AIzaSyAusk8j5dVYldxmDKdM2tQsFTwEoyeuSN0';
  late final GenerativeModel _model;

  MedicineCheckerService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'medicineName': Schema.string(description: "Brand name of the medicine"),
            'genericName': Schema.string(description: "Generic/chemical name"),
            'purpose': Schema.string(description: "Primary use of this medicine"),
            'personalizedDosage': Schema.string(
                description: "Recommended standard dosage tailored strictly to the user's age and gender."
            ),
            'allergyWarning': Schema.string(
                nullable: true,
                description: "Critical warning if the medicine conflicts with the user's reported allergies. Return null if safe."
            ),
            'interactionWarning': Schema.string(
                nullable: true,
                description: "Critical warning if the medicine interacts negatively with the user's current medications. Return null if safe."
            ),
            'fitnessImpact': Schema.string(
                nullable: true,
                description: "How this medication might affect muscle building and fat loss goals (e.g., fluid retention, fatigue, metabolic changes). Return null if no significant impact."
            ),
            'sideEffects': Schema.array(
                items: Schema.string(),
                description: "List of common side effects"
            ),
          },
        ),
      ),
    );
  }

  Future<String> analyzeMedicine(String imagePath, Map<String, String> profile) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final mimeType = imagePath.toLowerCase().endsWith('png') ? 'image/png' : 'image/jpeg';

      final prompt = TextPart('''
        Analyze this medicine packaging.
        
        User Context:
        - Age: ${profile['age']}
        - Gender: ${profile['gender']}
        - Known Allergies: ${profile['allergies']}
        - Current Medications: ${profile['medications']}
        - Fitness Goals: Absolute beginner in muscle building, prioritizing muscle gain while minimizing fat gain.

        Based on the image, identify the medicine and provide a personalized safety report. Cross-reference the medicine ingredients with the user's allergies and current medications.
        Return ONLY valid JSON with no extra text or markdown blocks. All string values must be on a single line.
      ''');

      final imagePart = DataPart(mimeType, bytes);
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      return _sanitize(response.text ?? '{"error": "No data extracted"}');
    } catch (e) {
      return '{"error": "Failed to process image: ${e.toString().replaceAll('"', "'")}"}';
    }
  }

  String _sanitize(String input) {
    String result = input.trim();
    result = result.replaceAll(RegExp(r'^```(json)?\s*'), '');
    result = result.replaceAll(RegExp(r'\s*```$'), '');
    result = result.replaceAllMapped(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'),
      (_) => ' ',
    );
    return result;
  }
}