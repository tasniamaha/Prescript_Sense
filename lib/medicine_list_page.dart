import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Import the package
import 'database_helper.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  // Database State
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Voice Search State
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  // Theme Colors
  final Color _primaryColor = const Color(0xFF1E3A8A);
  final Color _accentColor = const Color(0xFF3B82F6);
  final Color _warningColor = const Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _refreshMedicineList();
    _initSpeech(); // Initialize speech engine
  }

  // 1. Initialize Speech Engine
  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (errorNotification) => print('Speech Error: $errorNotification'),
    );
    setState(() {});
  }

  // 2. Start Listening
  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available")),
      );
      return;
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          // Update the text field with spoken words
          _searchController.text = result.recognizedWords;

          // Trigger the existing search logic immediately
          _searchMedicines(result.recognizedWords);
        });
      },
    );

    setState(() {
      _isListening = true;
    });
  }

  // 3. Stop Listening
  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Fetch all medicines
  void _refreshMedicineList() async {
    final data = await DatabaseHelper().getAllMedicines();
    setState(() {
      _medicines = data;
      _isLoading = false;
    });
  }

  // Filter medicines via search query
  void _searchMedicines(String query) async {
    final data = await DatabaseHelper().searchMedicines(query);
    setState(() {
      _medicines = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Medicine Database'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- Search Bar Section ---
          Container(
            padding: const EdgeInsets.all(16),
            color: _primaryColor,
            child: TextField(
              controller: _searchController,
              onChanged: _searchMedicines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Listening...'
                    : 'Search (Say "Fever")...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),

                // --- VOICE SEARCH BUTTON ---
                suffixIcon: IconButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.redAccent : Colors.white,
                    size: 28, // Make it slightly larger
                  ),
                ),

                // ---------------------------
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),

          // --- List of Medicines ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _medicines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No medicines found",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = _medicines[index];
                      return _buildMedicineCard(medicine);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: _accentColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Generic Name & Indications (Always Visible) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine['generic_name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      if (medicine['indications'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Used for: ${medicine['indications']}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30, thickness: 1),

            // --- Expandable Sections (Tap to View) ---
            ExpansionTile(
              title: const Text(
                "Common Brands",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: false,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(medicine['brand_names_bd'] ?? "N/A"),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text(
                "Adult Dosage",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: false,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(medicine['dosage_adult'] ?? "N/A"),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text(
                "Child Dosage",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: false,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(medicine['dosage_child'] ?? "N/A"),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text(
                "Cautions",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: false,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(medicine['cautions'] ?? "N/A"),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text(
                "Side Effects",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: false,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(medicine['side_effects'] ?? "N/A"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
      ],
    );
  }
}
