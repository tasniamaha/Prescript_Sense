import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: LoginPage(
        isDark: isDark,
        onToggleTheme: () => setState(() => isDark = !isDark),
      ),
    );
  }
}

// ---------------- LOGIN PAGE ----------------
class LoginPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const LoginPage(
      {super.key, required this.isDark, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Welcome Back",
      subtitle: "Login to your account",
      buttonText: "Login",
      isDark: isDark,
      onToggleTheme: onToggleTheme,
      onSwitch: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignupPage(
              isDark: isDark,
              onToggleTheme: onToggleTheme,
            ),
          ),
        );
      },
      switchText: "Don't have an account? Sign Up",
    );
  }
}

// ---------------- SIGNUP PAGE ----------------
class SignupPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SignupPage(
      {super.key, required this.isDark, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Create Account",
      subtitle: "Sign up to get started",
      buttonText: "Sign Up",
      isDark: isDark,
      onToggleTheme: onToggleTheme,
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
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onSwitch;
  final String switchText;
  final bool showExtraField;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.isDark,
    required this.onToggleTheme,
    required this.onSwitch,
    required this.switchText,
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
        child: Center(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: onToggleTheme,
                    ),
                  ],
                ),
                Text(title,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 22),
                if (showExtraField)
                  _inputField(Icons.person_outline, "Full Name", isDark),
                if (showExtraField) const SizedBox(height: 14),
                _inputField(Icons.email_outlined, "Email", isDark),
                const SizedBox(height: 14),
                _inputField(Icons.lock_outline, "Password", isDark,
                    obscure: true),
                const SizedBox(height: 22),
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
                    onPressed: () {},
                    child: Text(buttonText,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onSwitch,
                  child: Text(switchText,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(IconData icon, String hint, bool isDark,
      {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        prefixIcon: Icon(icon, color: Colors.blue),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
