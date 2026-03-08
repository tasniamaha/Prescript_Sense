import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_colors.dart'; // Your minimal color palette

// Ensure you use your actual API key or environment variable here
const String GEMINI_API_KEY = 'AIzaSyCEthUPyxgV5btJ_yV-ue0XV62ldrWfobE';

class PrescriptionResultPage extends StatefulWidget {
  final String imagePath;

  const PrescriptionResultPage({super.key, required this.imagePath});

  @override
  State<PrescriptionResultPage> createState() => _PrescriptionResultPageState();
}

class _PrescriptionResultPageState extends State<PrescriptionResultPage> {
  bool _isLoading = true;
  String _extractedText = "";
  String _geminiAnalysis = "";
  bool _hasError = false;

  late GenerativeModel _model;
  late FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
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
      // 1. OCR Extraction
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      _extractedText = recognizedText.text;

      if (_extractedText.trim().isEmpty) {
        throw Exception("No text could be read from the image.");
      }

      // 2. Gemini Analysis
      final prompt =
          '''
You are a medical assistant analyzing a raw OCR scan of a prescription.
Extract the medicines, dosages, and instructions clearly.
Format the output nicely with bullet points.
If it doesn't look like a prescription, say so politely.

Raw OCR Text:
$_extractedText
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (mounted) {
        setState(() {
          _geminiAnalysis =
              response.text ?? "Could not analyze the prescription.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _geminiAnalysis = "Error processing prescription: ${e.toString()}";
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
      if (_geminiAnalysis.isNotEmpty) {
        setState(() => _isSpeaking = true);
        await _tts.speak(_geminiAnalysis);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Minimal background
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
          if (!_isLoading && _geminiAnalysis.isNotEmpty)
            IconButton(
              icon: Icon(
                _isSpeaking
                    ? Icons.stop_circle_rounded
                    : Icons.volume_up_rounded,
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
            decoration: BoxDecoration(
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
            "Scanning & Analyzing...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lavenderBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Reading handwriting and extracting medicines",
            style: TextStyle(color: AppColors.slate, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE PREVIEW ---
          const Text(
            "Original Scan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 12),
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

          // --- AI ANALYSIS RESULTS (Using Accent Colors) ---
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.lavenderBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "Prescription Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _hasError ? AppColors.softRed : AppColors.softLavender,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasError
                    ? AppColors.alertRed
                    : AppColors.lavenderBlue.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_hasError)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "AI Verified Text",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lavenderBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Text(
                  _geminiAnalysis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: _hasError ? AppColors.alertRed : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- RAW OCR TEXT (Collapsible/Secondary) ---
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                "View Raw Extracted Text",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
              iconColor: AppColors.teal,
              collapsedIconColor: AppColors.slate,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mist),
                  ),
                  child: Text(
                    _extractedText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppColors.slate,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
