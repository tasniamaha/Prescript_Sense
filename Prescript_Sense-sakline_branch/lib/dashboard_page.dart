import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'FindNearbyClinicPage.dart';
import 'prescription_upload_page.dart';
import 'reminder_list_page.dart';
import 'profile_page.dart';
import 'medicine_list_page.dart';
import 'handwritten_to_text_page.dart'; // Fixed import for Text to Speech
import 'medicine_checker_page.dart';
import 'sos_button.dart';
import 'app_colors.dart'; // MUST IMPORT YOUR NEW COLORS
import 'history_screen.dart';

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

  String _geminiResponse = "";

  // Disclaimer banner state
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

  /// VOICE INPUT
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

  /// GEMINI API CALL
  Future<void> sendToGemini(String userText) async {
    if (userText.trim().isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
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
        _geminiResponse = "Unable to get response. Please try again later.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// TEXT TO SPEECH
  Future<void> _speakResponse() async {
    if (_geminiResponse.isEmpty) return;
    await _tts.stop();
    await _tts.speak(_geminiResponse);
  }

  @override
  void dispose() {
    _problemController.dispose();
    _tts.stop();
    _speech.stop();
    _disclaimerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine dynamic colors based on the current global theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.ink : AppColors.cloud;
    final cardBg = isDark ? AppColors.slate : AppColors.white;
    final textMain = isDark ? AppColors.white : AppColors.ink;
    final textMuted = isDark ? AppColors.mist : AppColors.slate;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            'PrescriptSense',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          actions: [
            // --- GLOBAL THEME TOGGLE BUTTON ---
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SAFETY DISCLAIMER
              if (_showDisclaimer)
                AnimatedOpacity(
                  opacity: _disclaimerOpacity,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate : AppColors.softAmber,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cautionAmber.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.cautionAmber,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "PrescriptSense provides general health information only. It does NOT replace a doctor.",
                            style: TextStyle(
                              color: textMain,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.cautionAmber,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _showDisclaimer = false),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              /// CHAT INPUT
              Text(
                'How can we help today?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? Border.all(color: AppColors.ash.withOpacity(0.2))
                      : null,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: AppColors.ink.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: TextField(
                  controller: _problemController,
                  maxLines: 3,
                  style: TextStyle(color: textMain),
                  decoration: InputDecoration(
                    hintText:
                        "Describe your symptoms or ask a medical question...",
                    hintStyle: TextStyle(color: textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening
                            ? AppColors.alertRed
                            : AppColors.teal,
                      ),
                      onPressed: _isListening
                          ? _stopVoiceInput
                          : _startVoiceInput,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => sendToGemini(_problemController.text),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isLoading ? "Analyzing..." : "Ask Assistant"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              /// AI RESPONSE
              if (_isLoading) ...[
                const SizedBox(height: 32),
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lavenderBlue,
                  ),
                ),
              ],

              if (_geminiResponse.isNotEmpty && !_isLoading) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate : AppColors.softLavender,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.lavenderBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: AppColors.lavenderBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "AI Analysis",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.lavenderBlue,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.lavenderBlue,
                            ),
                            onPressed: _speakResponse,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _geminiResponse,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              /// QUICK ACTIONS
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textMain,
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrescriptionUploadPage(),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.library_books,
                    label: 'Medicine Database',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicineListPage(),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.medical_services,
                    label: 'Medicine Checker',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicineCheckerPage(),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.record_voice_over,
                    label: 'Text to Speech',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HandwrittenToTextPage(),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.alarm,
                    label: 'Medicine Reminder',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReminderListPage(),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.local_hospital,
                    label: 'Nearby Clinics',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindNearbyClinicPage(),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.history,
                    label: 'Prescription History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                ],
              ),
            ],
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

  const _DashboardTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.slate : AppColors.white;
    final borderColor = isDark ? AppColors.ash.withOpacity(0.3) : AppColors.mist;
    final textMain = isDark ? AppColors.white : AppColors.slate;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            if (!isDark) BoxShadow(color: AppColors.ink.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.ink : AppColors.mist,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.teal),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}