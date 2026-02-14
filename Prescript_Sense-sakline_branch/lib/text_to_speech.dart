import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  Future<void> _pickAndExtractText(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognizedText.text;
    });
    textRecognizer.close();

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
      appBar: AppBar(title: const Text('Text to Speech'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.text_snippet_outlined, size: 120, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _pickAndExtractText(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Prescription'),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _pickAndExtractText(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOcrResult(BuildContext context) {
    final TextEditingController textController = TextEditingController(text: _extractedText);

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
                  icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.volume_up,
                      color: Theme.of(context).colorScheme.primary),
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