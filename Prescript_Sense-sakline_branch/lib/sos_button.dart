import 'package:flutter/material.dart';
import 'sos_service.dart';
import 'app_colors.dart';

class SosFab extends StatefulWidget {
  const SosFab({super.key});

  @override
  State<SosFab> createState() => _SosFabState();
}

class _SosFabState extends State<SosFab> {
  final SosService _service = SosService();

  void _onCallPressed() => _service.call(context);

  Future<void> _onSettingsPressed() async {
    final current = await _service.loadNumber();
    if (!mounted) return;
    await _showSettingsDialog(current);
  }

  Future<void> _showSettingsDialog(String currentNumber) async {
    final controller = TextEditingController(text: currentNumber);

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.settings_phone_rounded, color: AppColors.alertRed),
            SizedBox(width: 10),
            Text(
              'Emergency Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a custom emergency contact (e.g. your doctor). Leave as "911/999" for the default emergency service.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              autofocus: true,
              style: const TextStyle(color: AppColors.ink),
              decoration: InputDecoration(
                labelText: 'Emergency Number',
                labelStyle: const TextStyle(color: AppColors.slate),
                prefixIcon: const Icon(Icons.phone, color: AppColors.teal),
                filled: true,
                fillColor: AppColors.mist,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.deepTeal,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.slate),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed, // Semantic Danger Color
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                await _service.saveNumber(trimmed);
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      trimmed.isEmpty
                          ? 'No number entered — keeping previous value.'
                          : 'Emergency number saved: $trimmed',
                    ),
                    backgroundColor: trimmed.isEmpty
                        ? AppColors.cautionAmber
                        : AppColors.safeGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Small settings FAB (Using Neutral colors)
        Tooltip(
          message: 'Change emergency number',
          child: FloatingActionButton.small(
            heroTag: 'sos_settings_fab',
            onPressed: _onSettingsPressed,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.slate,
            elevation: 2,
            child: const Icon(Icons.settings_phone_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        // Primary SOS FAB (Semantic Danger)
        Tooltip(
          message: 'Call emergency contact',
          child: FloatingActionButton.extended(
            heroTag: 'sos_call_fab',
            onPressed: _onCallPressed,
            backgroundColor: AppColors.alertRed,
            foregroundColor: AppColors.white,
            elevation: 4,
            icon: const Icon(Icons.emergency_rounded),
            label: const Text(
              'SOS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
