import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single medicine dosage check saved to local history.
class HistoryRecord {
  final String medicineName;
  final String dose;
  final String status; // "SAFE" | "UNSAFE"
  final DateTime timestamp;

  const HistoryRecord({
    required this.medicineName,
    required this.dose,
    required this.status,
    required this.timestamp,
  });

  // ── Serialisation ──────────────────────────────────────────────────────────

  /// Converts this record to a JSON-encodable map.
  Map<String, dynamic> toJson() => {
        'medicine_name': medicineName,
        'dose': dose,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Reconstructs a [HistoryRecord] from a JSON map.
  factory HistoryRecord.fromJson(Map<String, dynamic> json) => HistoryRecord(
        medicineName: json['medicine_name'] as String,
        dose: json['dose'] as String,
        status: json['status'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

/// Manages the "Recent Checks" history using [SharedPreferences].
///
/// All records older than [_expirationDays] days are automatically purged
/// every time history is read or written.
class HistoryService {
  // The SharedPreferences key under which the list is stored.
  static const String _storageKey = 'medicine_check_history';

  // Maximum age (in days) a record is kept before being discarded.
  static const int _expirationDays = 30;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Saves a new dosage-check result to local history.
  ///
  /// Call this from your result screen after a check completes:
  /// ```dart
  /// await HistoryService().saveCheckToHistory(
  ///   name:   'Paracetamol 500mg',
  ///   dose:   '2 tablets',
  ///   status: 'SAFE',
  /// );
  /// ```
  Future<void> saveCheckToHistory({
    required String name,
    required String dose,
    required String status,
  }) async {
    final record = HistoryRecord(
      medicineName: name,
      dose: dose,
      status: status,
      timestamp: DateTime.now(),
    );

    final history = await _loadRaw();
    history.insert(0, record); // newest first
    await _persist(_removeExpired(history));
  }

  /// Loads history from storage, automatically removing any expired records.
  ///
  /// Returns records sorted newest-first.
  Future<List<HistoryRecord>> getHistory() async {
    final history = _removeExpired(await _loadRaw());
    // Persist the cleaned-up list so expired entries don't linger on disk.
    await _persist(history);
    return history;
  }

  /// Permanently deletes all saved history records.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Reads the raw JSON string list from SharedPreferences and deserialises it.
  Future<List<HistoryRecord>> _loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    // Silently skip any malformed entries to avoid crashes.
    return jsonList.fold<List<HistoryRecord>>([], (acc, jsonStr) {
      try {
        acc.add(HistoryRecord.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        ));
      } catch (_) {
        // Corrupted entry — discard it.
      }
      return acc;
    });
  }

  /// Serialises [records] and writes them back to SharedPreferences.
  Future<void> _persist(List<HistoryRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Returns a new list containing only records that are ≤ [_expirationDays] old.
  List<HistoryRecord> _removeExpired(List<HistoryRecord> records) {
    final cutoff = DateTime.now().subtract(
      const Duration(days: _expirationDays),
    );
    return records.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }
}
