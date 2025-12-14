import 'package:flutter/material.dart';

class PrescriptionResultPage extends StatelessWidget {
  const PrescriptionResultPage({super.key});

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE8EEF5)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ---------------- Hero: Extracted Text ----------------
              const Text(
                'Extracted Prescription Text',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2), // Soft blue for main content
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFE3F2FD)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.medication_liquid, color: Color(0xFF4A90E2), size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Prescribed Medicines',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      '• Paracetamol 500mg\n'
                      '• Amoxicillin 500mg\n'
                      '• Take twice daily after food\n'
                      '• Duration: 5 days',
                      style: TextStyle(fontSize: 17, height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ---------------- Safety Summary ----------------
              const Text(
                'Safety Summary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Green for safety
                ),
              ),
              const SizedBox(height: 16),
              _buildSafetyTile(Icons.check_circle, Colors.green, 'Dosage appears within safe limits'),
              _buildSafetyTile(Icons.warning_amber, Colors.orange, 'Avoid alcohol during medication'),
              _buildSafetyTile(Icons.info, Colors.blue, 'Mild side effects may occur'),

              const SizedBox(height: 32),

              // ---------------- Detailed AI Analysis ----------------
              const Text(
                'Detailed AI Analysis',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A), // Deep purple for AI depth
                ),
              ),
              const SizedBox(height: 16),

              _buildGradientExpansionTile(
                icon: Icons.medication,
                title: 'Drug Dose Checker',
                gradientColors: [Colors.green.shade100, Colors.green.shade50],
                accentColor: Colors.green.shade700,
                content: '• Paracetamol 500mg: Safe (Max 4000mg/day)\n'
                         '• Amoxicillin 500mg: Safe (Standard adult dose)',
              ),
              _buildGradientExpansionTile(
                icon: Icons.pregnant_woman,
                title: 'Pregnancy & Breastfeeding Safety',
                gradientColors: [Colors.purple.shade100, Colors.purple.shade50],
                accentColor: Colors.purple.shade700,
                content: '• Paracetamol: Generally safe\n'
                         '• Amoxicillin: Low risk\n'
                         '⚠ Consult a doctor for confirmation',
              ),
              _buildGradientExpansionTile(
                icon: Icons.restaurant,
                title: 'Food Interaction Check',
                gradientColors: [Colors.orange.shade100, Colors.orange.shade50],
                accentColor: Colors.orange.shade700,
                content: '• Take after meals\n'
                         '• Avoid alcohol\n'
                         '• Maintain hydration',
              ),
              _buildGradientExpansionTile(
                icon: Icons.healing,
                title: 'Possible Side Effects',
                gradientColors: [Colors.red.shade100, Colors.red.shade50],
                accentColor: Colors.red.shade700,
                content: '• Nausea\n'
                         '• Diarrhea\n'
                         '• Skin rash (rare)',
              ),
              _buildGradientExpansionTile(
                icon: Icons.attach_money,
                title: 'Medicine Price Checker',
                gradientColors: [Colors.blue.shade100, Colors.blue.shade50],
                accentColor: Colors.blue.shade700,
                content: '• Paracetamol: ৳2–3 per tablet\n'
                         '• Amoxicillin: ৳25–30 per capsule\n'
                         '(Prices may vary by pharmacy)',
              ),
              _buildGradientExpansionTile(
                icon: Icons.swap_horiz,
                title: 'Brand → Generic Converter',
                gradientColors: [Colors.indigo.shade100, Colors.indigo.shade50],
                accentColor: Colors.indigo.shade700,
                content: '• Napa → Paracetamol\n'
                         '• Moxacil → Amoxicillin',
              ),
              _buildGradientExpansionTile(
                icon: Icons.verified_user,
                title: 'Prescription Authenticity Check',
                gradientColors: [Colors.cyan.shade100, Colors.cyan.shade50],
                accentColor: Colors.cyan.shade700,
                content: '✔ Doctor signature detected\n'
                         '✔ Hospital stamp detected\n'
                         '✔ Format appears valid\n'
                         '⚠ AI confidence: 92%',
              ),

              const SizedBox(height: 40),

              // ---------------- Text to Speech ----------------
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up, size: 28),
                label: const Text('Listen to Prescription', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  shadowColor: const Color.fromARGB(255, 254, 254, 254).withOpacity(0.4),
                  backgroundColor: const Color.fromARGB(255, 209, 250, 255),
                ),
                onPressed: () {
                  // Text-to-speech placeholder
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyTile(IconData icon, Color color, String text) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildGradientExpansionTile({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required Color accentColor,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.7),
            child: Icon(icon, color: accentColor),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}