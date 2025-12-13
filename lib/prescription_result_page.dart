import 'package:flutter/material.dart';

class PrescriptionResultPage extends StatelessWidget {
  const PrescriptionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Extracted Prescription Text',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '• Paracetamol 500mg\n'
                  '• Amoxicillin 500mg\n'
                  '• Take twice daily after food\n'
                  '• Duration: 5 days',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Safety Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Dosage appears safe'),
            ),

            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: const Text('Avoid taking with alcohol'),
            ),

            ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: const Text('May cause mild stomach upset'),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text('Listen to Prescription'),
              onPressed: () {
                // Text-to-speech placeholder
              },
            ),
          ],
        ),
      ),
    );
  }
}
