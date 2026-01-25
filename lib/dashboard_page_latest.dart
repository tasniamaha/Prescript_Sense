import 'package:flutter/material.dart';
import 'prescription_upload_page.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'reminder_list_page.dart'; // Add this import
import 'profile_page.dart';
import 'medicine_list_page.dart';

// Calming & Welcoming Palette – matching the Landing Page's futuristic yet soothing vibe
const Color _deepIndigo = Color(0xFF1E3A8A);
const Color _softBlue = Color(0xFF3B82F6);
const Color _emerald = Color(0xFF10B981);
const Color _lightBackground = Color(0xFFF8FAFF); 
const Color _cardBackground = Colors.white;
const Color _textPrimary = Color(0xFF1E293B); 
const Color _textSecondary = Color(0xFF64748B); 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
                    'Good morning!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saturday, December 13, 2025',
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

            const SizedBox(height: 40),

            // Comment box section
            Text(
              'Tell us your problem, we will try to help',
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
                border: Border.all(color: _softBlue.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _softBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                maxLines: 4,
                controller: TextEditingController(text: "I am 26 years old with severe headache"),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Describe your problem here...",
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescriptionUploadPage(),
                    ),
                  );
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

            const SizedBox(height: 40),

            Text(
              'Your Recent Prescriptions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _PrescriptionHistoryCard(
                    date: '12 Sep 2025',
                    medicines: 'Paracetamol, Amoxicillin',
                    status: 'Reviewed',
                  ),
                  _PrescriptionHistoryCard(
                    date: '05 Sep 2025',
                    medicines: 'Napa Extra, Seclo 20',
                    status: 'Reviewed',
                  ),
                  _PrescriptionHistoryCard(
                    date: '28 Aug 2025',
                    medicines: 'Azithromycin, Oral Saline',
                    status: 'Reviewed',
                  ),
                  const SizedBox(height: 30),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

                  const SizedBox(height: 40),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _emerald.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _emerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: _textSecondary, size: 18),
        ],
      ),
    );
  }
}
