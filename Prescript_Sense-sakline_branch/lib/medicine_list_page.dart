import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'database_helper.dart';

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

  final Color _primaryColor = const Color(0xFF1E3A8A);
  final Color _accentColor = const Color(0xFF3B82F6);
  final Color _warningColor = const Color(0xFFD97706);

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
    setState(() {});
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
    setState(() {
      _medicines = data;
      _isLoading = false;
    });
  }

  void _searchMedicines(String query) async {
    final data = await DatabaseHelper().searchMedicines(query);
    setState(() => _medicines = data);
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
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: _primaryColor,
            child: TextField(
              controller: _searchController,
              onChanged: _searchMedicines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _isListening ? 'Listening...' : 'Search medicines...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.redAccent : Colors.white,
                    size: 28,
                  ),
                ),
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

          // Medicine List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _medicines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication_outlined,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("No medicines found",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: _accentColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              medicine['generic_name'] ?? "Unnamed",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
            ),
            const SizedBox(height: 12),

            // Instant info
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _infoChip("Adult Dosage", medicine['dosage_adult'] ?? "N/A", Colors.blue),
                _infoChip("Child Dosage", medicine['dosage_child'] ?? "N/A", Colors.teal),
                _infoChip("Cautions", medicine['cautions'] ?? "N/A", _warningColor),
                _infoChip("Price", medicine['price'] ?? "N/A", Colors.green),
              ],
            ),

            const SizedBox(height: 12),

            // Expandable extra info
            ExpansionTile(
              title: const Text("More Info", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                _extraInfoRow("Common Brands", medicine['brand_names_bd'] ?? "N/A", _accentColor),
                _extraInfoRow("Side Effects", medicine['side_effects'] ?? "N/A", Colors.orange),
                _extraInfoRow("Pregnancy Risk", medicine['pregnancy_risk'] ?? "N/A", Colors.pink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _extraInfoRow(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text("$label: $value", style: TextStyle(fontSize: 14, color: Colors.black87)),
    );
  }
}
