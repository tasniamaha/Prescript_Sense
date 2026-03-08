import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'dashboard_page.dart';
import 'app_colors.dart'; // Ensure you import your new color palette

class MedicalProfileSetupPage extends StatefulWidget {
  const MedicalProfileSetupPage({super.key});

  @override
  State<MedicalProfileSetupPage> createState() => _MedicalProfileSetupPageState();
}

class _MedicalProfileSetupPageState extends State<MedicalProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Form Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();

  String? _selectedGender;
  String? _selectedAllergy;

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  final List<String> _allergyOptions = [
    'None (No known allergies)',
    'Peanuts',
    'Tree Nuts',
    'Milk / Dairy',
    'Eggs',
    'Wheat',
    'Soy',
    'Fish',
    'Shellfish',
    'Penicillin',
    'Sulfa Drugs',
    'Aspirin',
    'Ibuprofen',
    'Latex',
    'Pollen',
    'Dust Mites',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _selectedGender != null && _selectedAllergy != null) {
      setState(() => _isLoading = true);

      await _authService.saveMedicalProfile(
        age: _ageController.text,
        gender: _selectedGender!,
        height: _heightController.text,
        weight: _weightController.text,
        allergies: _selectedAllergy!,
        medications: _medicationsController.text.isEmpty ? 'None' : _medicationsController.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: AppColors.alertRed, // Updated to Semantic Danger
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Minimal background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white, // Clean card surface
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.mist, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        "Medical Profile",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Help us personalize your health insights.",
                        style: TextStyle(color: AppColors.slate, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Row for Age and Gender
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            controller: _ageController,
                            label: "Age",
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildDropdown(
                            value: _selectedGender,
                            items: _genderOptions,
                            label: "Gender",
                            icon: Icons.person_outline,
                            onChanged: (val) => setState(() => _selectedGender = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row for Height and Weight
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: "Height (cm)",
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: "Weight (kg)",
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Allergies Dropdown
                    _buildDropdown(
                      value: _selectedAllergy,
                      items: _allergyOptions,
                      label: "Primary Allergy",
                      icon: Icons.warning_amber_rounded,
                      onChanged: (val) => setState(() => _selectedAllergy = val),
                    ),
                    const SizedBox(height: 16),

                    // Current Medications
                    _buildTextField(
                      controller: _medicationsController,
                      label: "Current Medications",
                      icon: Icons.medication_outlined,
                      keyboardType: TextInputType.text,
                      hint: "E.g. Napa, Seclo (Optional)",
                      isRequired: false,
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepTeal,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Complete Setup",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    String? hint,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.ink),
      validator: isRequired ? (value) => value!.isEmpty ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.slate),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.ash),
        prefixIcon: Icon(icon, color: AppColors.teal),
        filled: true,
        fillColor: AppColors.mist, // Using Mist for subtle background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: AppColors.white,
      style: const TextStyle(color: AppColors.ink, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.slate),
        prefixIcon: Icon(icon, color: AppColors.teal),
        filled: true,
        fillColor: AppColors.mist,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 1.5),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Required' : null,
    );
  }
}