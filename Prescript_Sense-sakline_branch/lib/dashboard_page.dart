import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:prescript_sense/FindNearbyClinicPage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'prescription_upload_page.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'reminder_list_page.dart';
import 'profile_page.dart';
import 'medicine_list_page.dart';
import 'text_to_speech.dart';
import 'prescription_result_page.dart';
import 'medicine_checker_page.dart';
import 'sos_button.dart';

const Color _deepIndigo = Color(0xFF1E3A8A);
const Color _softBlue = Color(0xFF3B82F6);
const Color _emerald = Color(0xFF10B981);
const Color _lightBackground = Color(0xFFF8FAFF);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);

const String GEMINI_API_KEY = 'AIzaSyCEthUPyxgV5btJ_yV-ue0XV62ldrWfobE';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _problemController = TextEditingController(
    text: "I am 26 years old with severe headache",
  );

  late GenerativeModel _model;
  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  bool _isListening = false;
  bool _isLoading = false;
  bool _hasError = false;

  String _geminiResponse = "";

  // =========================
  // Disclaimer banner state
  // =========================
  bool _showDisclaimer = true;
  double _disclaimerOpacity = 1.0;
  Timer? _disclaimerTimer;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: GEMINI_API_KEY);
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    // Safe timer for 20s disclaimer fade
    _disclaimerTimer = Timer(const Duration(seconds: 20), () {
      if (!mounted) return;
      setState(() {
        _disclaimerOpacity = 0.0;
      });
      Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _showDisclaimer = false;
        });
      });
    });
  }

  /// =========================
  /// VOICE INPUT
  /// =========================
  Future<void> _startVoiceInput() async {
    final available = await _speech.initialize();
    if (!available) return;

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _problemController.text = result.recognizedWords;
        });
      },
    );
  }

  void _stopVoiceInput() {
    _speech.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  /// =========================
  /// GEMINI API CALL
  /// =========================
  Future<void> sendToGemini(String userText) async {
    if (userText.trim().isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _geminiResponse = "";
    });

    try {
      final prompt =
          '''
You are a medical assistant.
Provide general medical information only.
Do NOT diagnose.
Always advise consulting a qualified doctor.

User problem:
$userText
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (!mounted) return;
      setState(() {
        _geminiResponse = response.text ?? "No response received from AI.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _geminiResponse = "Unable to get response. Please try again later.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// =========================
  /// TEXT TO SPEECH
  /// =========================
  Future<void> _speakResponse() async {
    if (_geminiResponse.isEmpty) return;
    await _tts.stop();
    await _tts.speak(_geminiResponse);
  }

 @override
void dispose() {
  _problemController.dispose();
  _tts.stop(); // DO NOT call dispose() on Windows
  _speech.stop();
  _disclaimerTimer?.cancel();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 64, 129, 225),
          elevation: 0,
          title: const Text(
            'PrescriptSense',
            style: TextStyle(
              color: Color.fromARGB(255, 247, 249, 255),
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new notifications'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(103, 184, 246, 1),
                Color(0xFFDDF2FF),
                Color.fromARGB(255, 166, 214, 240),
                Color(0xFFF8FCFF),
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// =========================
                /// SAFETY DISCLAIMER BANNER
                /// =========================
                if (_showDisclaimer)
                  AnimatedOpacity(
                    opacity: _disclaimerOpacity,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "PrescriptSense provides general health information only based on available dataset and internet's source. "
                              "It does NOT replace a doctor. Always consult a qualified medical professional.",
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.orange),
                            onPressed: () {
                              if (!mounted) return;
                              setState(() {
                                _showDisclaimer = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                /// =========================
                /// CHAT INPUT
                /// =========================
                Text(
                  'Tell us your problem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _problemController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Describe your problem here...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _softBlue,
                      ),
                      onPressed: _isListening
                          ? _stopVoiceInput
                          : _startVoiceInput,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => sendToGemini(_problemController.text),
                  icon: const Icon(Icons.send),
                  label: Text(_isLoading ? "Sending..." : "Send"),
                ),

                /// =========================
                /// AI RESPONSE
                /// =========================
                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],

                if (_geminiResponse.isNotEmpty && !_isLoading) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _hasError ? Colors.red[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _hasError ? Colors.red : _softBlue,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "PrescriptSense Response",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              onPressed: _speakResponse,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _geminiResponse,
                          style: const TextStyle(fontSize: 15, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                /// =========================
                /// QUICK ACTIONS
                /// =========================
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _DashboardTile(
                      icon: Icons.upload_file,
                      label: 'Upload Prescription',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrescriptionUploadPage(),
                          ),
                        );
                      },
                    ),
                    _DashboardTile(
                      icon: Icons.library_books,
                      label: 'Medicine Database',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MedicineListPage()),
                        );
                      },
                    ),
                    _DashboardTile(
                      icon: Icons.medical_services,
                      label: 'Medicine Checker',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicineCheckerPage(),
                          ),
                        );
                      },
                    ),
                    _DashboardTile(
                      icon: Icons.record_voice_over,
                      label: 'Text to Speech',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HandwrittenToTextPage(),
                          ),
                        );
                      },
                    ),
                    _DashboardTile(
                      icon: Icons.alarm,
                      label: 'Medicine Reminder',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReminderListPage()),
                        );
                      },
                    ),
                    _DashboardTile(
                      icon: Icons.local_hospital,
                      label: 'Nearby Clinics Around You',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FindNearbyClinicPage()),
                        );
                      },
                    ),
                    _DashboardTile(
                      icon: Icons.history,
                      label: 'Prescription History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrescriptionResultPage(
                              imagePath: 'assets/sample_prescription.png',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: const SosFab(),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 2, 147, 160).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: _softBlue),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
