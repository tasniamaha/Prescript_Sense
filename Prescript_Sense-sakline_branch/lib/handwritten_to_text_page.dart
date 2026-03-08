import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HandwrittenToTextPage extends StatefulWidget {
  const HandwrittenToTextPage({super.key});

  @override
  State<HandwrittenToTextPage> createState() => _HandwrittenToTextPageState();
}

class _HandwrittenToTextPageState extends State<HandwrittenToTextPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  bool _isSpeaking = false;
  String _extractedText = "";

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  /// Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  /// Speak or stop speaking the text
  Future<void> _speakText(String text) async {
    if (text.trim().isEmpty) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    } else {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
    }
  }

  /// Pick image from camera or gallery and extract text
  Future<void> _pickAndExtractText(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    setState(() {
      _extractedText = recognizedText.text.isEmpty
          ? "No text detected."
          : recognizedText.text;
    });

    _showOcrResult(context);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

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
                'Our AI will read handwritten or printed prescriptions and convert them into clear digital text with audio support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Scan from camera
              ElevatedButton.icon(
                onPressed: () => _pickAndExtractText(ImageSource.camera),
                icon: const Icon(Icons.document_scanner),
                label: const Text('Scan Prescription'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upload from gallery
              OutlinedButton.icon(
                onPressed: () => _pickAndExtractText(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  /// Show dialog with extracted text and TTS option
  void _showOcrResult(BuildContext context) {
    final TextEditingController textController =
        TextEditingController(text: _extractedText);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Text('Extracted Text'),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: _isSpeaking ? 'Stop Reading' : 'Read Aloud',
                  onPressed: () async {
                    await _speakText(textController.text);
                    setDialogState(() {});
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: TextField(
                controller: textController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Edit text before reading',
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _flutterTts.stop();
                  if (mounted) setState(() => _isSpeaking = false);
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}
