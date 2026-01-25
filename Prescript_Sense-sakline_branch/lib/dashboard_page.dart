import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'prescription_upload_page.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'reminder_list_page.dart';
import 'profile_page.dart';
import 'medicine_list_page.dart';
import 'text_to_speech.dart';
import 'prescription_result_page.dart';
import 'medicine_checker_page.dart'; // NEW PAGE

const Color _deepIndigo = Color(0xFF1E3A8A);
const Color _softBlue = Color(0xFF3B82F6);
const Color _emerald = Color(0xFF10B981);
const Color _lightBackground = Color(0xFFF8FAFF);
const Color _cardBackground = Colors.white;
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _problemController =
      TextEditingController(text: "I am 26 years old with severe headache");

  String _geminiResponse = "";
  bool _isLoading = false;

  Future<void> sendToGemini(String userText) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://your-gemini-api-endpoint.com/ask"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": userText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _geminiResponse = data['answer'] ?? "No response found.";
        });
      } else {
        setState(() {
          _geminiResponse = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _geminiResponse = "Error: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PrescriptSense',
          style: TextStyle(
            color: _deepIndigo,
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: _softBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: _softBlue),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// COMMENT BOX
            Text(
              'Tell us your problem, we will try to help',
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
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => sendToGemini(_problemController.text),
              icon: const Icon(Icons.send),
              label: Text(_isLoading ? "Sending..." : "Send"),
            ),
            if (_geminiResponse.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_geminiResponse),
            ],

            const SizedBox(height: 30),

            /// GRID VIEW SECTION
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

                /// 1. Upload Prescription
                _DashboardTile(
                  icon: Icons.upload_file,
                  label: 'Upload Prescription',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PrescriptionUploadPage()),
                    );
                  },
                ),

                /// 2. Medicine Database
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

                /// 3. Medicine Checker
                _DashboardTile(
                  icon: Icons.medical_services,
                  label: 'Medicine Checker',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MedicineCheckerPage()),
                    );
                  },
                ),

                /// 4. Text to Speech
                _DashboardTile(
                  icon: Icons.record_voice_over,
                  label: 'Text to Speech',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HandwrittenToTextPage()),
                    );
                  },
                ),

                /// 5. Medicine Reminder
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

                /// 6. Prescription History
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
    );
  }
}

/// GRID TILE WIDGET
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
              color: Colors.black.withOpacity(0.06),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
