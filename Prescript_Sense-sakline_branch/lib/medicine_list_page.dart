import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'app_colors.dart';

class Medication {
  final String name;
  final String drugClass;
  final String pediatricUse;
  final String pediatricNote;
  final String adultNote;
  final String route;
  final String rxOrOtc;

  Medication({
    required this.name,
    required this.drugClass,
    required this.pediatricUse,
    required this.pediatricNote,
    required this.adultNote,
    required this.route,
    required this.rxOrOtc,
  });

  // Updated to accept List<String> since fast_csv strictly returns strings
  factory Medication.fromCsv(List<String> row) {
    return Medication(
      name: row[0],
      drugClass: row[1],
      pediatricUse: row[2],
      pediatricNote: row[3],
      adultNote: row[4],
      route: row[5],
      rxOrOtc: row[6],
    );
  }
}

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  List<Medication> _allMedications = [];
  List<Medication> _filteredMedications = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCsvData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- 2. Load and Parse CSV using fast_csv ---
  Future<void> _loadCsvData() async {
    try {
      String rawData = await rootBundle.loadString('assets/data/medications.csv');

      // Sanitize line endings
      rawData = rawData.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      // Parse the CSV directly to List<List<String>>
      final List<List<String>> listData = fast_csv.parse(rawData);

      if (listData.isNotEmpty) {
        listData.removeAt(0); // Remove header row
      }

      final meds = listData
          .where((row) => row.length >= 7)
          .map((row) => Medication.fromCsv(row))
          .toList();

      if (mounted) {
        setState(() {
          _allMedications = meds;
          _allMedications.sort((a, b) => a.name.compareTo(b.name));
          _filteredMedications = _allMedications;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading CSV: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load medications database: $e'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    }
  }

  // --- 3. Search Logic ---
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedications = _allMedications.where((med) {
        return med.name.toLowerCase().contains(query) ||
            med.drugClass.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.ink : AppColors.cloud;
    final cardBg = isDark ? AppColors.slate : AppColors.white;
    final textMain = isDark ? AppColors.white : AppColors.ink;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Medicine Database'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.teal : AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.teal : AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textMain),
              decoration: InputDecoration(
                hintText:
                    'Search by name or class (e.g., Lisinopril, Statin)...',
                hintStyle: const TextStyle(color: AppColors.ash),
                prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.ash),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // --- LIST VIEW ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.deepTeal),
                  )
                : _filteredMedications.isEmpty
                ? Center(
                    child: Text(
                      'No medications found.',
                      style: TextStyle(
                        color: isDark ? AppColors.ash : AppColors.slate,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredMedications.length,
                    itemBuilder: (context, index) {
                      final med = _filteredMedications[index];
                      return _buildMedicineCard(med, cardBg, textMain);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- 4. Beautiful Card UI ---
  Widget _buildMedicineCard(Medication med, Color cardBg, Color textMain) {
    // Determine pill tag color based on Rx/OTC
    final isRx = med.rxOrOtc.toUpperCase().contains('RX');
    final tagColor = isRx ? AppColors.softRed : AppColors.softGreen;
    final tagTextColor = isRx ? AppColors.alertRed : AppColors.deepTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.teal,
          collapsedIconColor: AppColors.ash,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      med.drugClass,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  med.rxOrOtc,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tagTextColor,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.mist),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.route_outlined, "Route", med.route),
                  _buildDetailRow(
                    Icons.person_outline,
                    "Adult Dosing",
                    med.adultNote,
                  ),
                  _buildDetailRow(
                    Icons.child_care,
                    "Pediatric Use",
                    med.pediatricUse,
                  ),
                  _buildDetailRow(
                    Icons.info_outline,
                    "Pediatric Note",
                    med.pediatricNote,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.slate,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}