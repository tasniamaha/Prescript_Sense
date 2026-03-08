// import 'package:flutter/material.dart';
// import 'auth_service.dart'; // Import your new auth service
// import 'dashboard_page.dart'; // Import dashboard for navigation
// import 'medical_profile_setup.dart';

// // ---------------- LOGIN PAGE ----------------
// class LoginPage extends StatefulWidget {
//   final bool isDark;
//   final VoidCallback onToggleTheme;

//   const LoginPage({
//     super.key,
//     required this.isDark,
//     required this.onToggleTheme,
//   });

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin() async {
//     setState(() => _isLoading = true);

//     // Call the mock auth service
//     bool success = await _authService.login(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );

//     if (!mounted) return;

//     setState(() => _isLoading = false);

//     if (success) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const DashboardPage()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(
//             "Login failed. Please enter any email and password.",
//           ),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AuthScaffold(
//       title: "Welcome Back",
//       subtitle: "Login to your account",
//       buttonText: "Login",
//       isLoading: _isLoading,
//       isDark: widget.isDark,
//       onToggleTheme: widget.onToggleTheme,
//       emailController: _emailController,
//       passwordController: _passwordController,
//       onButtonPressed: _handleLogin,
//       onSwitch: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => SignupPage(
//               isDark: widget.isDark,
//               onToggleTheme: widget.onToggleTheme,
//             ),
//           ),
//         );
//       },
//       switchText: "Don't have an account? Sign Up",
//     );
//   }
// }

// // ---------------- SIGNUP PAGE ----------------
// class SignupPage extends StatefulWidget {
//   final bool isDark;
//   final VoidCallback onToggleTheme;

//   const SignupPage({
//     super.key,
//     required this.isDark,
//     required this.onToggleTheme,
//   });

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // void _handleSignup() async {
//   //   setState(() => _isLoading = true);

//   //   bool success = await _authService.signup(
//   //     _nameController.text.trim(),
//   //     _emailController.text.trim(),
//   //     _passwordController.text.trim(),
//   //   );

//   //   if (!mounted) return;

//   //   setState(() => _isLoading = false);

//   //   if (success) {
//   //     Navigator.pushAndRemoveUntil(
//   //       context,
//   //       MaterialPageRoute(builder: (_) => const DashboardPage()),
//   //       (route) => false,
//   //     );
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text("Signup failed. Please try again.")),
//   //     );
//   //   }
//   // }

//   void _handleSignup() async {
//     setState(() => _isLoading = true);

//     bool success = await _authService.signup(
//       _nameController.text.trim(),
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );

//     if (!mounted) return;

//     setState(() => _isLoading = false);

//     if (success) {
//       // ---> CHANGED HERE: Navigate to MedicalProfileSetupPage instead of DashboardPage
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const MedicalProfileSetupPage()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Signup failed. Please try again.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AuthScaffold(
//       title: "Create Account",
//       subtitle: "Sign up to get started",
//       buttonText: "Sign Up",
//       isLoading: _isLoading,
//       isDark: widget.isDark,
//       onToggleTheme: widget.onToggleTheme,
//       nameController: _nameController,
//       emailController: _emailController,
//       passwordController: _passwordController,
//       onButtonPressed: _handleSignup,
//       onSwitch: () => Navigator.pop(context),
//       switchText: "Already have an account? Login",
//       showExtraField: true,
//     );
//   }
// }

// // ---------------- SHARED AUTH UI ----------------
// class AuthScaffold extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String buttonText;
//   final bool isDark;
//   final bool isLoading;
//   final VoidCallback onToggleTheme;
//   final VoidCallback onSwitch;
//   final VoidCallback onButtonPressed;
//   final String switchText;
//   final bool showExtraField;

//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final TextEditingController? nameController;

//   const AuthScaffold({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.buttonText,
//     required this.isDark,
//     this.isLoading = false,
//     required this.onToggleTheme,
//     required this.onSwitch,
//     required this.onButtonPressed,
//     required this.switchText,
//     required this.emailController,
//     required this.passwordController,
//     this.nameController,
//     this.showExtraField = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Custom 4-color gradient
//     final gradient = [
//       const Color.fromRGBO(103, 184, 246, 1),
//       const Color(0xFFDDF2FF),
//       const Color.fromARGB(255, 166, 214, 240),
//       const Color(0xFFF8FCFF),
//     ];

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradient,
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 margin: const EdgeInsets.symmetric(horizontal: 22),
//                 decoration: BoxDecoration(
//                   color: isDark
//                       ? Colors.grey[900]
//                       : Colors.white.withOpacity(0.95),
//                   borderRadius: BorderRadius.circular(22),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 15,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//                           color: isDark ? Colors.white70 : Colors.blue[700],
//                           onPressed: () {
//                             if (Navigator.canPop(context))
//                               Navigator.pop(context);
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             isDark ? Icons.light_mode : Icons.dark_mode,
//                           ),
//                           color: isDark ? Colors.white70 : Colors.blue[700],
//                           onPressed: onToggleTheme,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       subtitle,
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                     ),
//                     const SizedBox(height: 22),
//                     if (showExtraField && nameController != null)
//                       _inputField(
//                         Icons.person_outline,
//                         "Full Name",
//                         isDark,
//                         nameController!,
//                       ),
//                     if (showExtraField) const SizedBox(height: 14),
//                     _inputField(
//                       Icons.email_outlined,
//                       "Email",
//                       isDark,
//                       emailController,
//                     ),
//                     const SizedBox(height: 14),
//                     _inputField(
//                       Icons.lock_outline,
//                       "Password",
//                       isDark,
//                       passwordController,
//                       obscure: true,
//                     ),
//                     const SizedBox(height: 22),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         onPressed: isLoading ? null : onButtonPressed,
//                         child: isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : Text(
//                                 buttonText,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     GestureDetector(
//                       onTap: isLoading ? null : onSwitch,
//                       child: Text(
//                         switchText,
//                         style: const TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _inputField(
//     IconData icon,
//     String hint,
//     bool isDark,
//     TextEditingController controller, {
//     bool obscure = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
//         prefixIcon: Icon(icon, color: Colors.blue),
//         hintText: hint,
//         hintStyle: TextStyle(
//           color: isDark ? Colors.grey[500] : Colors.grey[600],
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Colors.blue, width: 2),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'dashboard_page.dart';
import 'medical_profile_setup.dart'; // Preserved from our recent onboarding update
import 'app_colors.dart'; // Your new color palette

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

    bool success = await _authService.login(
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
        SnackBar(
          content: const Text("Login failed. Please check your credentials."),
          backgroundColor: AppColors.alertRed, // Updated to semantic color
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      isDark: widget.isDark,
      onToggleTheme: widget.onToggleTheme,
      emailController: _emailController,
      passwordController: _passwordController,
      onButtonPressed: _handleLogin,
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
      // Preserved functionality: Route to setup page instead of dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MedicalProfileSetupPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup failed. Please try again."),
          backgroundColor: AppColors.alertRed,
        ),
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
  final bool isDark;
  final bool isLoading;
  final VoidCallback onToggleTheme;
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
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.ink
          : AppColors.cloud, // Minimal background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.slate
                    : AppColors.white, // Clean card surface
                borderRadius: BorderRadius.circular(24),
                border: isDark
                    ? Border.all(color: AppColors.ash.withOpacity(0.2))
                    : null,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: AppColors.ink.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
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
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        color: isDark ? AppColors.mist : AppColors.teal,
                        onPressed: onToggleTheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.deepTeal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? AppColors.ash : AppColors.slate,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (showExtraField && nameController != null)
                    _inputField(
                      Icons.person_outline,
                      "Full Name",
                      isDark,
                      nameController!,
                    ),
                  if (showExtraField) const SizedBox(height: 16),

                  _inputField(
                    Icons.email_outlined,
                    "Email",
                    isDark,
                    emailController,
                  ),
                  const SizedBox(height: 16),

                  _inputField(
                    Icons.lock_outline,
                    "Password",
                    isDark,
                    passwordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isLoading ? null : onButtonPressed,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: isLoading ? null : onSwitch,
                    child: Text(
                      switchText,
                      style: TextStyle(
                        color: isDark ? AppColors.mist : AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    IconData icon,
    String hint,
    bool isDark,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? AppColors.white : AppColors.ink),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark
            ? AppColors.ink
            : AppColors.mist, // Mist for subtle backgrounds
        prefixIcon: Icon(icon, color: AppColors.teal),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.ash : AppColors.slate.withOpacity(0.7),
        ),
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
          borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
        ),
      ),
    );
  }
}
