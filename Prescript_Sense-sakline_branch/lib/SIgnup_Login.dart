import 'package:flutter/material.dart';
import 'auth_service.dart'; 
import 'dashboard_page.dart'; 
import 'medical_profile_setup.dart';
import 'app_colors.dart'; 

// ---------------- LOGIN PAGE ----------------
class LoginPage extends StatefulWidget {
  // Made optional so existing LandingPage routing doesn't break
  final bool? isDark;
  final VoidCallback? onToggleTheme;

  const LoginPage({super.key, this.isDark, this.onToggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    bool success = await _authService.login(_emailController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardPage()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Login failed. Please check your credentials."),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Welcome Back",
      subtitle: "Login to your account",
      buttonText: "Login",
      isLoading: _isLoading,
      emailController: _emailController,
      passwordController: _passwordController,
      onButtonPressed: _handleLogin,
      onSwitch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
      switchText: "Don't have an account? Sign Up",
    );
  }
}

// ---------------- SIGNUP PAGE ----------------
class SignupPage extends StatefulWidget {
  final bool? isDark;
  final VoidCallback? onToggleTheme;

  const SignupPage({super.key, this.isDark, this.onToggleTheme});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    setState(() => _isLoading = true);
    bool success = await _authService.signup(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MedicalProfileSetupPage()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup failed. Please try again."), backgroundColor: AppColors.alertRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Create Account",
      subtitle: "Sign up to get started",
      buttonText: "Sign Up",
      isLoading: _isLoading,
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      onButtonPressed: _handleSignup,
      onSwitch: () => Navigator.pop(context),
      switchText: "Already have an account? Login",
      showExtraField: true,
    );
  }
}

// ---------------- SHARED AUTH UI ----------------
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onSwitch;
  final VoidCallback onButtonPressed;
  final String switchText;
  final bool showExtraField;

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? nameController;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.isLoading = false,
    required this.onSwitch,
    required this.onButtonPressed,
    required this.switchText,
    required this.emailController,
    required this.passwordController,
    this.nameController,
    this.showExtraField = false,
  });

  @override
  Widget build(BuildContext context) {
    // Read the true theme state from context
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink : AppColors.cloud,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate : AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: isDark ? Border.all(color: AppColors.ash.withOpacity(0.2)) : null,
                boxShadow: [
                  if (!isDark) BoxShadow(color: AppColors.ink.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: isDark ? AppColors.white : AppColors.deepTeal,
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                      ),
                      // --- GLOBAL THEME TOGGLE BUTTON ---
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        color: isDark ? AppColors.mist : AppColors.teal,
                        onPressed: () {
                          themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? AppColors.white : AppColors.deepTeal, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, style: TextStyle(color: isDark ? AppColors.ash : AppColors.slate, fontSize: 16)),
                  const SizedBox(height: 32),
                  
                  if (showExtraField && nameController != null) _inputField(Icons.person_outline, "Full Name", isDark, nameController!),
                  if (showExtraField) const SizedBox(height: 16),
                  _inputField(Icons.email_outlined, "Email", isDark, emailController),
                  const SizedBox(height: 16),
                  _inputField(Icons.lock_outline, "Password", isDark, passwordController, obscure: true),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isLoading ? null : onButtonPressed,
                      child: isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5))
                          : Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: isLoading ? null : onSwitch,
                    child: Text(switchText, style: TextStyle(color: isDark ? AppColors.mist : AppColors.teal, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(IconData icon, String hint, bool isDark, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? AppColors.white : AppColors.ink),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.ink : AppColors.mist,
        prefixIcon: Icon(icon, color: AppColors.teal),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? AppColors.ash : AppColors.slate.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.deepTeal, width: 2)),
      ),
    );
  }
}