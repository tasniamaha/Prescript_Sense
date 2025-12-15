import 'package:flutter/material.dart';
import 'prescription_upload_page.dart';

// Calming & Welcoming Palette – matching the Landing Page's futuristic yet soothing vibe
// Deep indigo to soft blue with emerald accents, light backgrounds for calm readability
const Color _deepIndigo = Color(0xFF1E3A8A);
const Color _softBlue = Color(0xFF3B82F6);
const Color _emerald = Color(0xFF10B981);
const Color _lightBackground = Color(0xFFF8FAFF); // Very pale blue-ish white
const Color _cardBackground = Colors.white;
const Color _textPrimary = Color(0xFF1E293B); // Slate dark
const Color _textSecondary = Color(0xFF64748B); // Soft gray

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
              // Navigate to Profile later
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

            // Warm, personalized welcome card with subtle gradient accent
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _cardBackground,
                    _cardBackground.withOpacity(0.95),
                  ],
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

            // Primary action – Upload new prescription
            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  PrescriptionUploadPage(),
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

            // Section title
            Text(
              'Your Recent Prescriptions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Prescription history list
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
                  const SizedBox(height: 40), // Extra bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Unique calming prescription card with soft emerald accent and glass-like feel
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
        border: Border.all(
          color: _emerald.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Soft circular icon with subtle gradient
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
            child: Icon(
              Icons.medication_rounded,
              color: _emerald,
              size: 28,
            ),
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
                    Text(
                      'Last reviewed: $date',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
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