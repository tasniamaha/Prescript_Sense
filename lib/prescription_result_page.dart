import 'package:flutter/material.dart';
import 'ocr_service.dart'; // Import the service

class PrescriptionResultPage extends StatefulWidget {
  final String imagePath; // Receive the image path

  const PrescriptionResultPage({super.key, required this.imagePath});

  @override
  State<PrescriptionResultPage> createState() => _PrescriptionResultPageState();
}

class _PrescriptionResultPageState extends State<PrescriptionResultPage> {
  final OcrService _ocrService = OcrService();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  @override
  void dispose() {
    _ocrService.dispose(); // Clean up ML Kit resources
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    // Run the OCR
    final text = await _ocrService.processImage(widget.imagePath);

    if (mounted) {
      setState(() {
        _textController.text = text;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Prescription Result'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A90E2), Colors.transparent],
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity, // Ensure background covers full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE8EEF5)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Analyzing Prescription..."),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- Editable Text Section ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Extracted Text',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          Icon(Icons.edit_note, color: Color(0xFF4A90E2)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // The Editable Text Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: null, // Allows infinite vertical expansion
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "No text detected. Try scanning again.",
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ---------------- Action Buttons ----------------
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Logic to Copy to Clipboard can go here
                                // Clipboard.setData(ClipboardData(text: _textController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to Clipboard!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy Text"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Save logic placeholder
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Changes Saved!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text("Save Edits"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}