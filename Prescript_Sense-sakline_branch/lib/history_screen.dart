import 'package:flutter/material.dart';
import 'history_service.dart';

/// Displays the local "Recent Checks" history.
///
/// Records are loaded from [HistoryService]; any entry older than 30 days is
/// discarded automatically before the list is rendered.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _service = HistoryService();

  List<HistoryRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    final records = await _service.getHistory();
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all recent checks? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.clearHistory();
      await _loadHistory();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the accent colour for a given status string.
  Color _statusColor(String status) {
    return status.toUpperCase() == 'SAFE'
        ? const Color(0xFF10B981) // emerald-green
        : const Color(0xFFEF4444); // vivid-red
  }

  /// Returns the background chip colour (lighter tint).
  Color _statusBackground(String status) {
    return status.toUpperCase() == 'SAFE'
        ? const Color(0xFFD1FAE5) // light green
        : const Color(0xFFFEE2E2); // light red
  }

  /// Formats the timestamp for display, e.g. "Mar 07, 2026 · 14:32".
  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year} · $h:$m';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── App bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Recent Checks'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          if (_records.isNotEmpty)
            IconButton(
              tooltip: 'Clear all history',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _confirmClearHistory,
            ),
        ],
      ),

      // ── Background gradient matching dashboard style ────────────────────
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(103, 184, 246, 1),
              Color(0xFFDDF2FF),
              Color(0xFFF8FCFF),
            ],
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent checks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your medicine dose checks will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── History list ───────────────────────────────────────────────────────────

  Widget _buildHistoryList() {
    return RefreshIndicator(
      // Pull-to-refresh re-runs the cleanup + reload.
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _records.length,
        itemBuilder: (context, index) => _HistoryTile(
          record: _records[index],
          statusColor: _statusColor(_records[index].status),
          statusBackground: _statusBackground(_records[index].status),
          formattedDate: _formatDate(_records[index].timestamp),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE TILE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// A single card in the history list. Extracted as a private widget to keep
/// [_HistoryScreenState.build] lean and to avoid unnecessary rebuilds.
class _HistoryTile extends StatelessWidget {
  final HistoryRecord record;
  final Color statusColor;
  final Color statusBackground;
  final String formattedDate;

  const _HistoryTile({
    required this.record,
    required this.statusColor,
    required this.statusBackground,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        // ── Left accent bar ────────────────────────────────────────────────
        leading: Container(
          width: 5,
          height: 52,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // ── Medicine name + dose ───────────────────────────────────────────
        title: Text(
          record.medicineName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              'Dose: ${record.dose}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        // ── Status badge ───────────────────────────────────────────────────
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Text(
            record.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
