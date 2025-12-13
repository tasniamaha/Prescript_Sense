import 'package:flutter/material.dart';
import 'prescription_upload_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _titleController;
  late final Animation<double> _titleFade;
  late final AnimationController _contentController;
  late final Animation<Offset> _contentSlide;
  late final AnimationController _buttonController;
  late final Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    // Title fade-in
    _titleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _titleFade =
        CurvedAnimation(parent: _titleController, curve: Curves.easeOut);
    _titleController.forward();

    // Content slide-up
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    Future.delayed(
        const Duration(milliseconds: 400), () => _contentController.forward());

    // Button bounce
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _buttonScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
    Future.delayed(
        const Duration(milliseconds: 800), () => _buttonController.forward());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5A8DEE),
              Color(0xFF9D7BFF),
              Color(0xFF6EE2D5),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Title
                FadeTransition(
                  opacity: _titleFade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PrescriptSense',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI-Powered Medical Prescription Analyzer',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Hero
                FadeTransition(
                  opacity: _titleFade,
                  child: Center(
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 140,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // Description
                SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transform handwritten prescriptions into clear, safe digital insights.',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Avoid misreading, detect drug interactions, receive multilingual explanations, and more — powered by advanced AI technology.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Features
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.5,
                  children: features
                      .map((f) => _featureCard(f['icon'], f['title']))
                      .toList(),
                ),

                const SizedBox(height: 80),

                // Get Started Button
                Center(
                  child: ScaleTransition(
                    scale: _buttonScale,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PrescriptionUploadPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF5A8DEE),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 56, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 12,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> features = [
    {'icon': Icons.scanner_outlined, 'title': 'Scan & Align Prescriptions'},
    {'icon': Icons.text_fields_outlined, 'title': 'Handwriting to Text (OCR)'},
    {'icon': Icons.security_outlined, 'title': 'Detect Interactions & Safety'},
    {'icon': Icons.language_outlined, 'title': 'Multi-language Explanations'},
    {'icon': Icons.audiotrack_outlined, 'title': 'Audio Conversion'},
    {'icon': Icons.notifications_outlined, 'title': 'Medicine Reminders'},
  ];

  Widget _featureCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
