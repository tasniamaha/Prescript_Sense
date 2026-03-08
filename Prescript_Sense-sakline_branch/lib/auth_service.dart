import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _storedEmailKey = 'storedEmail';
  static const String _storedPasswordKey = 'storedPassword';
  static const String _storedNameKey = 'storedName';
  static const String _storedImageKey =
      'storedImage'; // NEW: For Profile Picture
  static const String _storedAgeKey = 'storedAge';
  static const String _storedGenderKey = 'storedGender';
  static const String _storedHeightKey = 'storedHeight';
  static const String _storedWeightKey = 'storedWeight';
  static const String _storedAllergiesKey = 'storedAllergies';
  static const String _storedMedicationsKey = 'storedMedications';
  static const String _isProfileCompleteKey = 'isProfileComplete';

  // --- Getters ---
  Future<Map<String, String>> getMedicalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'age': prefs.getString(_storedAgeKey) ?? 'N/A',
      'gender': prefs.getString(_storedGenderKey) ?? 'N/A',
      'height': prefs.getString(_storedHeightKey) ?? 'N/A',
      'weight': prefs.getString(_storedWeightKey) ?? 'N/A',
      'allergies': prefs.getString(_storedAllergiesKey) ?? 'None',
      'medications': prefs.getString(_storedMedicationsKey) ?? 'None',
    };
  }

  Future<void> saveMedicalProfile({
    required String age,
    required String gender,
    required String height,
    required String weight,
    required String allergies,
    required String medications,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storedAgeKey, age.trim());
    await prefs.setString(_storedGenderKey, gender);
    await prefs.setString(_storedHeightKey, height.trim());
    await prefs.setString(_storedWeightKey, weight.trim());
    await prefs.setString(_storedAllergiesKey, allergies);
    await prefs.setString(_storedMedicationsKey, medications.trim());
    await prefs.setBool(_isProfileCompleteKey, true);
  }

  Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProfileCompleteKey) ?? false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storedEmailKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storedNameKey);
  }

  // NEW: Get Profile Picture Path
  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storedImageKey);
  }

  // --- Actions ---

  // LOGIN
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();

    final String? registeredEmail = prefs.getString(_storedEmailKey);
    final String? registeredPassword = prefs.getString(_storedPasswordKey);

    if (registeredEmail == null || registeredPassword == null) return false;

    if (email.trim() == registeredEmail &&
        password.trim() == registeredPassword) {
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    }
    return false;
  }

  // SIGNUP
  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_storedNameKey, name.trim());
    await prefs.setString(_storedEmailKey, email.trim());
    await prefs.setString(_storedPasswordKey, password.trim());
    await prefs.setBool(_isLoggedInKey, true);

    return true;
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  // NEW: Update Profile Data
  Future<void> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_storedNameKey, name);
    if (email != null) await prefs.setString(_storedEmailKey, email);
    if (imagePath != null) await prefs.setString(_storedImageKey, imagePath);
  }
}
