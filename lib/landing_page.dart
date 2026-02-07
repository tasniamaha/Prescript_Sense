import 'package:flutter/material.dart';
import 'SIgnup_Login.dart';
import 'dashboard_page.dart';
// Import to check login status if needed

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 380;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5DD5E8), Color(0xFF6B8FF5), Color(0xFF9D7BFF)],
          ),
        ),
        child: Stack(
          children: [
            // Main Scrollable Content
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: 100, // Space for the Top Nav Bar
                bottom: 40,
              ),
              child: Column(
                children: [
                  _buildHeroSection(context, screenSize, isSmallScreen),
                  _buildFeaturesSection(context),
                  _buildFooterSection(context),
                ],
              ),
            ),

            // Fixed Top Nav Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopNavBar(context, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context, bool isSmallScreen) {
    return Container(
      // Add a slight gradient fade behind the nav for readability
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.1), Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flexible Title to prevent overflow
              Flexible(
                child: Text(
                  'PrescriptSense',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(
                        isDark: false,
                        onToggleTheme: _dummyCallback,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5A8DEE),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Login/Signup',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    Size screenSize,
    bool isSmallScreen,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Hero Image - Responsive Height
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight:
                          screenSize.height * 0.35, // Max 35% of screen height
                      minHeight: 200,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.asset(
                        'assests/image/Prescript_Sense.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title - Scaled down slightly for better fit
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'PrescriptSense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 36 : 46, // Reduced from 52
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Transforming handwritten medical prescriptions into clear, safe, and accessible digital insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  ElevatedButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        screenSize.height *
                            0.7, // Scroll down about 70% of screen
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5A8DEE),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Explore Features',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_downward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.document_scanner_rounded,
        'title': 'Scan & Align',
        'subtitle': 'Handwritten → Digital Text',
        'colors': [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)],
      },
      {
        'icon': Icons.record_voice_over_rounded,
        'title': 'Audio Reader',
        'subtitle': 'Listen to your schedule',
        'colors': [const Color(0xFF9575CD), const Color(0xFF7E57C2)],
      },
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'Reminders',
        'subtitle': 'Never miss a dose',
        'colors': [const Color(0xFF4DB6AC), const Color(0xFF26A69A)],
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Safety Checks',
        'subtitle': 'Identify drug risks',
        'colors': [const Color(0xFFEF5350), const Color(0xFFE53935)],
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Column(
        children: [
          Text(
            'Key Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 15),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Intelligent medication management',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),

          // CHANGED: Use Column instead of GridView for better mobile layout
          // This prevents "squished" cards and overflow issues.
          Column(
            children: features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildFuturisticFeatureCard(
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  subtitle: feature['subtitle'] as String,
                  gradientColors: feature['colors'] as List<Color>,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [...gradientColors, gradientColors[0].withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5A8DEE),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 12,
            ),
            child: const Text(
              'Get Started Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 60),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  '© 2025 PrescriptSense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Powered by AI • Built with Flutter',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _dummyCallback() {}
}
