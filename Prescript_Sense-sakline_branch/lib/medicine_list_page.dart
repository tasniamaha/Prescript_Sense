import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'database_helper.dart';
import 'app_colors.dart'; // Ensure you import the new color palette

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _refreshMedicineList();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    await _speech.listen(onResult: (result) {
      setState(() {
        _searchController.text = result.recognizedWords;
        _searchMedicines(result.recognizedWords);
      });
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _refreshMedicineList() async {
    final data = await DatabaseHelper().getAllMedicines();
    if (mounted) {
      setState(() {
        _medicines = data;
        _isLoading = false;
      });
    }
  }

  void _searchMedicines(String query) async {
    final data = await DatabaseHelper().searchMedicines(query);
    if (mounted) setState(() => _medicines = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Minimal background
      appBar: AppBar(
        title: const Text('Medicine Database'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w700, 
          color: AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          // --- CLEAN SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mist, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchMedicines,
                style: const TextStyle(color: AppColors.ink, fontSize: 16),
                decoration: InputDecoration(
                  hintText: _isListening ? 'Listening...' : 'Search medicines...',
                  hintStyle: const TextStyle(color: AppColors.ash),
                  prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                  suffixIcon: IconButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? AppColors.alertRed : AppColors.slate,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),

          // --- MEDICINE LIST ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.deepTeal))
                : _medicines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: AppColors.mist,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.medical_information_outlined,
                                size: 48, 
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No medicines found",
                              style: TextStyle(
                                color: AppColors.ink, 
                                fontSize: 18, 
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Try adjusting your search terms.",
                              style: TextStyle(color: AppColors.slate),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) =>
                            _buildMedicineCard(_medicines[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mist, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generic Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    medicine['generic_name'] ?? "Unnamed",
                    style: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    medicine['price'] ?? "N/A",
                    style: const TextStyle(
                      color: AppColors.safeGreen, 
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Always visible info boxes (Using Palette Semantic Colors)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _infoChip("Adult Dose", medicine['dosage_adult'] ?? "N/A", AppColors.deepTeal, AppColors.mist),
                _infoChip("Child Dose", medicine['dosage_child'] ?? "N/A", AppColors.teal, AppColors.mist),
                _infoChip("Cautions", medicine['cautions'] ?? "N/A", AppColors.cautionAmber, AppColors.softAmber),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.mist, height: 24),
            ),

            // ExpansionTile for extra info
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                iconColor: AppColors.teal,
                collapsedIconColor: AppColors.slate,
                title: const Text(
                  "More Information",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.slate),
                ),
                children: [
                  _extraInfoRow(
                    icon: Icons.local_pharmacy_outlined,
                    label: "Common Brands",
                    value: medicine['brand_names_bd'] ?? "N/A",
                    iconColor: AppColors.teal,
                    bgColor: AppColors.mist,
                  ),
                  _extraInfoRow(
                    icon: Icons.warning_amber_rounded,
                    label: "Side Effects",
                    value: medicine['side_effects'] ?? "N/A",
                    iconColor: AppColors.alertRed,
                    bgColor: AppColors.softRed,
                  ),
                  _extraInfoRow(
                    icon: Icons.pregnant_woman_outlined,
                    label: "Pregnancy Risk",
                    value: medicine['pregnancy_risk'] ?? "N/A",
                    iconColor: AppColors.cautionAmber,
                    bgColor: AppColors.softAmber,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _extraInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}