import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'prescription_upload_page.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'reminder_list_page.dart';
import 'profile_page.dart';
import 'medicine_list_page.dart';
import 'database_helper.dart';

const Color _deepIndigo = Color(0xFF1E3A8A);
const Color _softBlue = Color(0xFF3B82F6);
const Color _emerald = Color(0xFF10B981);
const Color _lightBackground = Color(0xFFF8FAFF);
const Color _cardBackground = Colors.white;
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const String GEMINI_API_KEY = 'AIzaSyDGxkfcu2VxM-2x4Im8eQ2FkY2IqOhUSpY';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _problemController = TextEditingController();
  String _geminiResponse = "";
  bool _isLoading = false;
  bool _hasError = false;
  late GenerativeModel _model;

  // Prescription data
  List<Map<String, dynamic>> _recentPrescriptions = [];
  bool _isLoadingPrescriptions = true;

  @override
  void initState() {
    super.initState();
    _initGemini();
    _loadPrescriptions();
  }

  void _initGemini() {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: GEMINI_API_KEY);
  }

  Future<void> _loadPrescriptions() async {
    try {
      final data = await DatabaseHelper().getAllMedicines();
      setState(() {
        _recentPrescriptions = data;
        _isLoadingPrescriptions = false;
      });
    } catch (e) {
      print('Error loading prescriptions: $e');
      setState(() {
        _isLoadingPrescriptions = false;
      });
    }
  }

  Future<void> sendToGemini(String userText) async {
    if (userText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your problem')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prompt =
          '''
You are a medical assistant. A user has described their health problem.
Provide helpful, general medical information and suggestions.
Always remind them to consult a healthcare professional for serious issues.

User's problem: $userText
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      setState(() {
        _geminiResponse = response.text ?? "No response received";
      });
    } catch (e) {
      setState(() {
        _geminiResponse = "Error: Unable to get response. Please try again.";
        _hasError = true;
      });
      print('Gemini API Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PrescriptSense',
          style: TextStyle(
            color: _deepIndigo,
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_rounded, color: _softBlue, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout, color: _softBlue, size: 30),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingPage()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_cardBackground, _cardBackground.withOpacity(0.95)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _softBlue.withOpacity(0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: _emerald.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 18,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re here to make managing your prescriptions simple, safe, and stress-free.',
                    style: TextStyle(
                      fontSize: 16,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Gemini AI Assistant
            Text(
              'Ask Our AI Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _softBlue.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _softBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Describe your health concern...",
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => sendToGemini(_problemController.text),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.psychology),
                label: Text(
                  _isLoading ? "Getting response..." : "Ask AI Assistant",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _softBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_geminiResponse.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasError ? Colors.red[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasError
                              ? Icons.error_outline
                              : Icons.lightbulb_outline,
                          color: _hasError ? Colors.red[700] : Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasError ? 'Error' : 'AI Response',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _hasError
                                ? Colors.red[700]
                                : Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _geminiResponse,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Upload Prescription
            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescriptionUploadPage(),
                    ),
                  );
                  if (result == true) {
                    _loadPrescriptions(); // Refresh prescriptions
                  }
                },
                icon: const Icon(Icons.add_circle_rounded, size: 32),
                label: const Text(
                  'Upload New Prescription',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _softBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: _softBlue.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Recent Prescriptions
            Text(
              'Your Recent Prescriptions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            _isLoadingPrescriptions
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _recentPrescriptions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No prescriptions yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload your first prescription to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: _recentPrescriptions.map((prescription) {
                      return _PrescriptionHistoryCard(
                        date: prescription['date'] ?? 'Unknown date',
                        medicines: prescription['medicines'] ?? 'No medicines',
                        status: prescription['status'] ?? 'Pending',
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 30),

            // Reminders Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.alarm, size: 28),
                label: const Text(
                  'Medicine Reminders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _softBlue,
                  side: const BorderSide(color: _softBlue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Medicine Database Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicineListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.library_books_rounded, size: 28),
                label: const Text(
                  'Medicine Database',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }
}

class _PrescriptionHistoryCard extends StatelessWidget {
  final String date;
  final String medicines;
  final String status;

  const _PrescriptionHistoryCard({
    required this.date,
    required this.medicines,
    required this.status,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reviewed':
        return _emerald;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return _emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _emerald.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _emerald.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _emerald.withOpacity(0.25),
                  _softBlue.withOpacity(0.15),
                ],
              ),
            ),
            child: Icon(Icons.medication_rounded, color: _emerald, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicines,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Last reviewed: $date',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: _textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: _textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}
