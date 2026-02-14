// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'SIgnup_Login.dart';       // Make sure path is correct
import 'dashboard_page.dart';     // Make sure path is correct

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width < 420;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(103, 184, 246, 1),
              Color(0xFFDDF2FF),
              Color.fromARGB(255, 166, 214, 240),
              Color(0xFFF8FCFF),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                height: 340,
                child: Opacity(
                  opacity: 0.08,
                  child: CustomPaint(painter: SoftWavePainter()),
                ),
              ),

              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 90)),

                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildHeroImage(context, isNarrow),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 48)),

                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildHeroContent(context, isNarrow),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 80)),

                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFeaturesSection(context, isNarrow),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 90)),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildGetStartedSection(context, isNarrow),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 120)),
                  SliverToBoxAdapter(child: _buildFooter(context)),
                ],
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(context, isNarrow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isNarrow) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 98, 165, 242).withOpacity(0.82),
        border: Border(
          bottom: BorderSide(color:const Color.fromARGB(255, 98, 165, 242), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PrescriptSense',
            style: TextStyle(
              fontSize: isNarrow ? 28 : 34,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 247, 249, 255),
              letterSpacing: 0.3,
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(
                    isDark: false,
                    onToggleTheme: () {},
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 245, 246, 249),
              side: const BorderSide(color: Color.fromARGB(255, 235, 236, 238), width: 2),
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 24 : 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(160, 54),
            ),
            child: Text(
              'Sign In / Join',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, bool isNarrow) {
    final screenHeight = MediaQuery.of(context).size.height;
    final desiredMaxHeight = screenHeight * 0.46;
    final safeMinHeight = (isNarrow ? 260 : 320).toDouble();
    final effectiveMinHeight = safeMinHeight.clamp(0.0, desiredMaxHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: desiredMaxHeight,
            minHeight: effectiveMinHeight,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF93C5FD).withOpacity(0.16),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/image/stethoscope_blue.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 110,
                  color: const Color(0xFF93C5FD),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context, bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(
            'Peace of Mind with Every Medicine',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isNarrow ? 28:32,
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(255, 97, 149, 227),
              height: 1.14,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'We turn hard-to-read handwritten prescriptions into clear text.\n'
            'Listen to your plan. Get gentle reminders.\n'
            'Feel safer and more confident every day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isNarrow ? 14:17,
              height: 1.60,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 56),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_downward_rounded, size: 24),
            label: const Text('See How It Helps You'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              minimumSize: const Size(260, 64),
              textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isNarrow) {
    final features = [
      {
        'icon': Icons.document_scanner_outlined,
        'title': 'Easy Prescription Scan',
        'desc': 'Take a photo — we read the handwriting carefully and show you clear text.',
        'color': const Color(0xFF2563EB),
      },
      {
        'icon': Icons.record_voice_over_outlined,
        'title': 'Voice That Reads Aloud',
        'desc': 'Clear voice readout of medicine times and instructions — very helpful.',
        'color': const Color(0xFF7C3AED),
      },
      {
        'icon': Icons.notifications_none_rounded,
        'title': 'Gentle Reminders',
        'desc': 'Friendly, calm notifications so you never miss a dose.',
        'color': const Color(0xFF0EA5E9),
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Safety Support',
        'desc': 'Gentle warnings if we detect possible medicine concerns.',
        'color': const Color(0xFF059669),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Features Made for You',
            style: TextStyle(
              fontSize: isNarrow ? 26:36,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Simple • Clear • Caring',
            style: TextStyle(
              fontSize: 21,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _buildFeatureCard(
                  icon: f['icon'] as IconData,
                  title: f['title'] as String,
                  description: f['desc'] as String,
                  accentColor: f['color'] as Color,
                  isNarrow: isNarrow,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
    required bool isNarrow,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 38, color: accentColor),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isNarrow ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isNarrow ? 18 : 20,
                    height: 1.55,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedSection(BuildContext context, bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              minimumSize: const Size(300, 70),
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            child: const Text('Start Today – It’s Free'),
          ),
          const SizedBox(height: 28),
          Text(
            'No payment • Very easy to start • Always here to help',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 56),
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Text(
            '© A Software Development Project by IUT',
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Helping you take your medicines calmly and safely every day',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Made with care by Team 404',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class SoftWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.50);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.50,
      size.height * 0.48,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.70,
      size.width,
      size.height * 0.40,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}