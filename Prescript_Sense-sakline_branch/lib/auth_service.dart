import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _storedEmailKey = 'storedEmail';
  static const String _storedPasswordKey = 'storedPassword';
  static const String _storedNameKey = 'storedName';
  static const String _storedImageKey = 'storedImage'; // NEW: For Profile Picture

  // --- Getters ---
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

    if (email.trim() == registeredEmail && password.trim() == registeredPassword) {
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
  Future<void> updateProfile({String? name, String? email, String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_storedNameKey, name);
    if (email != null) await prefs.setString(_storedEmailKey, email);
    if (imagePath != null) await prefs.setString(_storedImageKey, imagePath);
  }
}