import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles all business logic for the SOS / Emergency Call feature.
///
/// All data is stored locally in [SharedPreferences] — no backend calls.
class SosService {
  /// SharedPreferences key for the stored emergency number.
  static const String _prefsKey = 'sos_emergency_number';

  /// Shown to the user when no custom number has been saved yet.
  static const String defaultNumber = '911';

  // ── Number persistence ─────────────────────────────────────────────────────

  /// Returns the saved emergency number, or [defaultNumber] if none is stored.
  Future<String> loadNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey) ?? defaultNumber;
  }

  /// Saves [number] to [SharedPreferences].
  ///
  /// Trims whitespace before saving to avoid invalid URIs.
  Future<void> saveNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, number.trim());
  }

  // ── Dialling ───────────────────────────────────────────────────────────────

  /// Loads the saved number and opens the device's native phone dialler.
  ///
  /// If the device cannot handle `tel:` URIs (e.g. some tablets / emulators),
  /// a [SnackBar] with a descriptive error is shown instead.
  ///
  /// [context] must come from within a [Scaffold] so [ScaffoldMessenger] works.
  Future<void> call(BuildContext context) async {
    final number = await loadNumber();
    final uri = Uri(scheme: 'tel', path: number);

    // Guard: check that the platform supports phone calls before launching.
    bool canCall = false;
    try {
      canCall = await canLaunchUrl(uri);
    } catch (_) {
      canCall = false;
    }

    if (!canCall) {
      // Show an informational SnackBar; do NOT crash.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Phone calls are not supported on this device.\n'
              'Emergency number: $number',
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      return;
    }

    // Launch the dialler; catch any unexpected platform error.
    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not dial $number. Please call manually.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
