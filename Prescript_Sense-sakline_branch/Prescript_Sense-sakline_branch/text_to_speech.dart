import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HandwrittenToTextPage extends StatefulWidget {
  const HandwrittenToTextPage({super.key});

  @override
  State<HandwrittenToTextPage> createState() => _HandwrittenToTextPageState();
}

class _HandwrittenToTextPageState extends State<HandwrittenToTextPage> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  /// Initialize Text-to-Speech settings
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

  /// Speak the extracted text
  Future<void> _speakText(String text) async {
    if (text.trim().isEmpty) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _flutterTts.shutdown();
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
              Icon(
                Icons.text_snippet_outlined,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 30),

              const Text(
                'Convert Handwritten Prescription',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Our AI will read handwritten or printed prescriptions and convert them into clear digital text with audio support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () {
                  _showOcrResult(context);
                },
                icon: const Icon(Icons.document_scanner),
                label: const Text('Scan Prescription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {
                  _showOcrResult(context);
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
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

  /// Show OCR Result Dialog with Text-to-Speech
  void _showOcrResult(BuildContext context) {
    const extractedText =
        'Paracetamol 500 milligrams. '
        'Amoxicillin 500 milligrams. '
        'Take twice daily after food. '
        'Duration: 5 days.';

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
                    await _speakText(extractedText);
                    setDialogState(() {});
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• Paracetamol 500mg\n'
                  '• Amoxicillin 500mg\n'
                  '• Take twice daily after food\n'
                  '• Duration: 5 days',
                ),
                const SizedBox(height: 16),
                if (_isSpeaking)
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reading...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _flutterTts.stop();
                  if (mounted) {
                    setState(() {
                      _isSpeaking = false;
                    });
                  }
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
