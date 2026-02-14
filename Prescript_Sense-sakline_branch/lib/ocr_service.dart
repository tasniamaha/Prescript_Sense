import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  // 1. Create the recognizer instance (Latin script for English)
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Processes an image path and returns the extracted text as a String.
  Future<String> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );
      return recognizedText.text;
    } catch (e) {
      return "Error processing image: $e";
    }
  }

  /// MUST call this when the app is closing or the service is no longer needed
  /// to free up native resources.
  void dispose() {
    _textRecognizer.close();
  }
} 