// import 'package:flutter/material.dart';
// import 'history_service.dart';

// /// Displays the local "Recent Checks" history.
// ///
// /// Records are loaded from [HistoryService]; any entry older than 30 days is
// /// discarded automatically before the list is rendered.
// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   final HistoryService _service = HistoryService();

//   List<HistoryRecord> _records = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   // ── Data loading ───────────────────────────────────────────────────────────

//   Future<void> _loadHistory() async {
//     final records = await _service.getHistory();
//     if (mounted) {
//       setState(() {
//         _records = records;
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _confirmClearHistory() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Clear History'),
//         content: const Text(
//           'Are you sure you want to delete all recent checks? '
//           'This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Clear'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       await _service.clearHistory();
//       await _loadHistory();
//     }
//   }

//   // ── Helpers ────────────────────────────────────────────────────────────────

//   /// Returns the accent colour for a given status string.
//   Color _statusColor(String status) {
//     return status.toUpperCase() == 'SAFE'
//         ? const Color(0xFF10B981) // emerald-green
//         : const Color(0xFFEF4444); // vivid-red
//   }

//   /// Returns the background chip colour (lighter tint).
//   Color _statusBackground(String status) {
//     return status.toUpperCase() == 'SAFE'
//         ? const Color(0xFFD1FAE5) // light green
//         : const Color(0xFFFEE2E2); // light red
//   }

//   /// Formats the timestamp for display, e.g. "Mar 07, 2026 · 14:32".
//   String _formatDate(DateTime dt) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//     ];
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year} · $h:$m';
//   }

//   // ── Build ──────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ── App bar ────────────────────────────────────────────────────────────
//       appBar: AppBar(
//         title: const Text('Recent Checks'),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF1E3A8A),
//         foregroundColor: Colors.white,
//         actions: [
//           if (_records.isNotEmpty)
//             IconButton(
//               tooltip: 'Clear all history',
//               icon: const Icon(Icons.delete_sweep_outlined),
//               onPressed: _confirmClearHistory,
//             ),
//         ],
//       ),

//       // ── Background gradient matching dashboard style ────────────────────
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromRGBO(103, 184, 246, 1),
//               Color(0xFFDDF2FF),
//               Color(0xFFF8FCFF),
//             ],
//             stops: [0.0, 0.35, 1.0],
//           ),
//         ),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _records.isEmpty
//                 ? _buildEmptyState()
//                 : _buildHistoryList(),
//       ),
//     );
//   }

//   // ── Empty state ────────────────────────────────────────────────────────────

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.history_rounded,
//             size: 72,
//             color: Colors.blueGrey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No recent checks yet',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.blueGrey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your medicine dose checks will appear here.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.blueGrey.shade400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── History list ───────────────────────────────────────────────────────────

//   Widget _buildHistoryList() {
//     return RefreshIndicator(
//       // Pull-to-refresh re-runs the cleanup + reload.
//       onRefresh: _loadHistory,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         itemCount: _records.length,
//         itemBuilder: (context, index) => _HistoryTile(
//           record: _records[index],
//           statusColor: _statusColor(_records[index].status),
//           statusBackground: _statusBackground(_records[index].status),
//           formattedDate: _formatDate(_records[index].timestamp),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // PRIVATE TILE WIDGET
// // ─────────────────────────────────────────────────────────────────────────────

// /// A single card in the history list. Extracted as a private widget to keep
// /// [_HistoryScreenState.build] lean and to avoid unnecessary rebuilds.
// class _HistoryTile extends StatelessWidget {
//   final HistoryRecord record;
//   final Color statusColor;
//   final Color statusBackground;
//   final String formattedDate;

//   const _HistoryTile({
//     required this.record,
//     required this.statusColor,
//     required this.statusBackground,
//     required this.formattedDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 10,
//         ),

//         // ── Left accent bar ────────────────────────────────────────────────
//         leading: Container(
//           width: 5,
//           height: 52,
//           decoration: BoxDecoration(
//             color: statusColor,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),

//         // ── Medicine name + dose ───────────────────────────────────────────
//         title: Text(
//           record.medicineName,
//           style: const TextStyle(
//             fontWeight: FontWeight.w700,
//             fontSize: 15,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 3),
//             Text(
//               'Dose: ${record.dose}',
//               style: const TextStyle(fontSize: 13),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               formattedDate,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),

//         // ── Status badge ───────────────────────────────────────────────────
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: statusBackground,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: statusColor.withOpacity(0.4)),
//           ),
//           child: Text(
//             record.status.toUpperCase(),
//             style: TextStyle(
//               color: statusColor,
//               fontWeight: FontWeight.w700,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'history_service.dart';
import 'app_colors.dart'; // Ensure you import your new color palette

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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
            SizedBox(width: 10),
            Text('Clear History', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all recent checks? '
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.slate, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.slate)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softRed,
              foregroundColor: AppColors.alertRed,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
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

  /// Returns the accent colour for a given status string using AppColors semantic palette.
  Color _statusColor(String status) {
    return status.toUpperCase() == 'SAFE'
        ? AppColors.safeGreen 
        : AppColors.alertRed; 
  }

  /// Returns the background chip colour (lighter tint) using AppColors semantic palette.
  Color _statusBackground(String status) {
    return status.toUpperCase() == 'SAFE'
        ? AppColors.softGreen 
        : AppColors.softRed; 
  }

  /// Formats the timestamp for display, e.g. "Mar 07, 2026 · 14:32".
  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}  •  $h:$m';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Minimal background
      // ── App bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Recent Checks'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        titleTextStyle: const TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w700, 
          color: AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
        actions: [
          if (_records.isNotEmpty)
            IconButton(
              tooltip: 'Clear all history',
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.alertRed),
              onPressed: _confirmClearHistory,
            ),
          const SizedBox(width: 8),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.deepTeal))
          : _records.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 56,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No recent checks yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your medicine dose checks will appear here.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  // ── History list ───────────────────────────────────────────────────────────

  Widget _buildHistoryList() {
    return RefreshIndicator(
      color: AppColors.deepTeal,
      backgroundColor: AppColors.white,
      // Pull-to-refresh re-runs the cleanup + reload.
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14), // Slightly less than container to fit inside border
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ────────────────────────────────────────────────
              Container(
                width: 6,
                color: statusColor,
              ),
              
              // ── Main Content ───────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              record.medicineName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Dose: ${record.dose}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.slate,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.ash,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),

                      // ── Status badge ───────────────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          record.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}