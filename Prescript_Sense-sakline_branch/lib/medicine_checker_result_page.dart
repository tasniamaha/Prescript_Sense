import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'auth_service.dart';
import 'history_service.dart'; // Added HistoryService
import 'medicine_checker_service.dart';

class MedicineCheckerResultPage extends StatefulWidget {
  final String imagePath;

  const MedicineCheckerResultPage({super.key, required this.imagePath});

  @override
  State<MedicineCheckerResultPage> createState() => _MedicineCheckerResultPageState();
}

class _MedicineCheckerResultPageState extends State<MedicineCheckerResultPage> {
  final MedicineCheckerService _service = MedicineCheckerService();
  final AuthService _authService = AuthService();
  final HistoryService _historyService = HistoryService(); // Initialize HistoryService
  
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    try {
      // 1. Fetch user medical context
      final profile = await _authService.getMedicalProfile();
      
      // 2. Analyze with Gemini
      final jsonString = await _service.analyzeMedicine(widget.imagePath, profile);
      
      if (mounted) {
        setState(() {
          _data = json.decode(jsonString);
          if (_data!.containsKey('error')) {
            _hasError = true;
          } else {
            // 3. Save to history automatically on success
            _logToHistory(_data!);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _data = {"error": "Failed to parse analysis: $e"};
          _isLoading = false;
        });
      }
    }
  }

  /// Automatically logs the analyzed medicine to the Recent Checks screen
  Future<void> _logToHistory(Map<String, dynamic> data) async {
    final allergyWarning = data['allergyWarning'];
    final interactionWarning = data['interactionWarning'];
    
    // Determine safety status based on Gemini's warnings
    final String status = (allergyWarning != null || interactionWarning != null) 
        ? 'UNSAFE' 
        : 'SAFE';

    await _historyService.saveCheckToHistory(
      name: data['medicineName'] ?? 'Unknown Medicine',
      dose: data['personalizedDosage'] ?? 'Standard Dose',
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        title: const Text(
          'Medicine Insights',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(color: AppColors.teal),
          ),
          const SizedBox(height: 24),
          const Text(
            "Analyzing Medicine...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.teal),
          ),
          const SizedBox(height: 8),
          const Text(
            "Checking for allergies and interactions",
            style: TextStyle(color: AppColors.slate),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_data?['error'] ?? 'Unknown error', style: const TextStyle(color: AppColors.alertRed)),
        ),
      );
    }

    final allergyWarning = _data?['allergyWarning'];
    final interactionWarning = _data?['interactionWarning'];
    final fitnessImpact = _data?['fitnessImpact'];
    final sideEffects = _data?['sideEffects'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mist),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data?['medicineName'] ?? 'Unknown Medicine',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  _data?['genericName'] ?? '',
                  style: const TextStyle(fontSize: 16, color: AppColors.slate),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.mist),
                ),
                _buildInfoRow(Icons.health_and_safety_outlined, "Purpose", _data?['purpose'] ?? 'N/A'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person_outline, "Personalized Dosage", _data?['personalizedDosage'] ?? 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Safety Warnings
          if (allergyWarning != null || interactionWarning != null) ...[
            const Text("Critical Warnings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 12),
            if (allergyWarning != null) _buildAlertCard(Icons.warning_amber_rounded, "Allergy Alert", allergyWarning, AppColors.softRed, AppColors.alertRed),
            if (interactionWarning != null) ...[
              const SizedBox(height: 12),
              _buildAlertCard(Icons.medication_liquid_rounded, "Interaction Alert", interactionWarning, AppColors.softAmber, AppColors.cautionAmber),
            ],
            const SizedBox(height: 24),
          ] else ...[
             _buildAlertCard(Icons.check_circle_outline, "Safe to Use", "No conflicts found with your allergies or current medications.", AppColors.softGreen, AppColors.safeGreen),
             const SizedBox(height: 24),
          ],

          // Fitness Impact
          if (fitnessImpact != null) ...[
            const Text("Fitness Impact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 12),
            _buildAlertCard(Icons.fitness_center_rounded, "Body Composition", fitnessImpact, AppColors.softLavender, AppColors.lavenderBlue),
            const SizedBox(height: 24),
          ],

          // Side Effects
          if (sideEffects.isNotEmpty) ...[
            const Text("Common Side Effects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mist),
              ),
              child: Column(
                children: sideEffects.map((effect) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: AppColors.teal),
                      const SizedBox(width: 12),
                      Expanded(child: Text(effect.toString(), style: const TextStyle(color: AppColors.slate, fontSize: 15))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, color: AppColors.ink, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(IconData icon, String title, String message, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 16)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: AppColors.ink.withOpacity(0.8), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}