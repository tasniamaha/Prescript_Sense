import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import your new auth service
import 'dashboard_page.dart'; // Import dashboard for navigation

// ---------------- LOGIN PAGE ----------------
class LoginPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const LoginPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

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

    // Call the mock auth service
    bool success = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Navigate to Dashboard and remove history so user can't "back" to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Login failed. Please enter any email and password."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      isLoading: _isLoading, // Pass loading state to UI
      isDark: widget.isDark,
      onToggleTheme: widget.onToggleTheme,
      
      // Pass controllers to the generic scaffold
      emailController: _emailController,
      passwordController: _passwordController,
      onButtonPressed: _handleLogin, // Connect the button action
      
      onSwitch: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignupPage(
              isDark: widget.isDark,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      },
      switchText: "Don't have an account? Sign Up",
    );
  }
}

// ---------------- SIGNUP PAGE ----------------
class SignupPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SignupPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

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

    bool success = await _authService.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Create Account",
      subtitle: "Sign up to get started",
      buttonText: "Sign Up",
      isLoading: _isLoading,
      isDark: widget.isDark,
      onToggleTheme: widget.onToggleTheme,
      
      // Pass controllers
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      onButtonPressed: _handleSignup,
      
      onSwitch: () => Navigator.pop(context),
      switchText: "Already have an account? Login",
      showExtraField: true, // Enable the "Name" field
    );
  }
}

// ---------------- SHARED AUTH UI ----------------
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isDark;
  final bool isLoading;
  final VoidCallback onToggleTheme;
  final VoidCallback onSwitch;
  final VoidCallback onButtonPressed; // Action when button is clicked
  final String switchText;
  final bool showExtraField;
  
  // Controllers
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? nameController;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.isDark,
    this.isLoading = false,
    required this.onToggleTheme,
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
    final gradient = isDark
        ? [Colors.black87, Colors.black54]
        : [const Color(0xFF1976D2), const Color(0xFF42A5F5)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView( // Added to prevent overflow on small screens
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Back Button + Theme Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: isDark ? Colors.white70 : Colors.blue[700],
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                          color: isDark ? Colors.white70 : Colors.blue[700],
                          onPressed: onToggleTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 22),
                    
                    // Input Fields
                    if (showExtraField && nameController != null)
                      _inputField(Icons.person_outline, "Full Name", isDark, nameController!),
                    if (showExtraField) const SizedBox(height: 14),
                    
                    _inputField(Icons.email_outlined, "Email", isDark, emailController),
                    const SizedBox(height: 14),
                    _inputField(Icons.lock_outline, "Password", isDark, passwordController, obscure: true),
                    
                    const SizedBox(height: 22),
                    
                    // Main Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isLoading ? null : onButtonPressed, // Disable if loading
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                buttonText,
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: isLoading ? null : onSwitch,
                      child: Text(
                        switchText,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(IconData icon, String hint, bool isDark, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller, // Connect the controller
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        prefixIcon: Icon(icon, color: Colors.blue),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}