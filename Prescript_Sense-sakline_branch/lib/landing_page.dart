import 'package:flutter/material.dart';
import 'SIgnup_Login.dart';       
import 'dashboard_page.dart';     
import 'app_colors.dart'; // Ensure you import the new color palette

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
      backgroundColor: AppColors.cloud, // Minimal background
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle modern background wave
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              height: 340,
              child: Opacity(
                opacity: 0.05, // Very faint watermark effect
                child: CustomPaint(painter: SoftWavePainter()),
              ),
            ),

            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 90)),

                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeroImage(context, isNarrow),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeroContent(context, isNarrow),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),

                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFeaturesSection(context, isNarrow),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildGetStartedSection(context, isNarrow),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
    );
  }

  Widget _buildTopBar(BuildContext context, bool isNarrow) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95), // Frosted clean look
        border: const Border(
          bottom: BorderSide(color: AppColors.mist, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // The Expanded + ellipsis fix we discussed earlier!
          Expanded(
            child: Text(
              'PrescriptSense',
              style: TextStyle(
                fontSize: isNarrow ? 24 : 32,
                fontWeight: FontWeight.w800,
                color: AppColors.deepTeal,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
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
              foregroundColor: AppColors.deepTeal,
              side: const BorderSide(color: AppColors.mist, width: 2),
              backgroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 20 : 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size(140, 54),
            ),
            child: const Text(
              'Sign In / Join',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: desiredMaxHeight,
            minHeight: effectiveMinHeight,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withOpacity(0.06), // Minimal shadow
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/image/stethoscope_blue.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 110,
                  color: AppColors.lightTeal,
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
              fontSize: isNarrow ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We turn hard-to-read handwritten prescriptions into clear text.\n'
            'Listen to your plan. Get gentle reminders.\n'
            'Feel safer and more confident every day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isNarrow ? 15 : 17,
              height: 1.60,
              color: AppColors.slate,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_downward_rounded, size: 20),
            label: const Text('See How It Helps You'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              minimumSize: const Size(260, 64),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
        'color': AppColors.teal,
      },
      {
        'icon': Icons.record_voice_over_outlined,
        'title': 'Voice That Reads Aloud',
        'desc': 'Clear voice readout of medicine times and instructions — very helpful.',
        'color': AppColors.lavenderBlue, // Accent color for AI/Voice features
      },
      {
        'icon': Icons.notifications_none_rounded,
        'title': 'Gentle Reminders',
        'desc': 'Friendly, calm notifications so you never miss a dose.',
        'color': AppColors.deepTeal,
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Safety Support',
        'desc': 'Gentle warnings if we detect possible medicine concerns.',
        'color': AppColors.safeGreen, // Semantic color for safety
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Features Made for You',
            style: TextStyle(
              fontSize: isNarrow ? 26 : 32,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Simple • Clear • Caring',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.slate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mist, width: 1.5), // Clean borders instead of heavy shadows
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.03),
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
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: accentColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isNarrow ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isNarrow ? 15 : 16,
                    height: 1.5,
                    color: AppColors.slate,
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
              backgroundColor: AppColors.deepTeal,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              minimumSize: const Size(300, 70),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            child: const Text('Start Today – It’s Free'),
          ),
          const SizedBox(height: 24),
          const Text(
            'No payment • Very easy to start • Always here to help',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.slate,
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
      color: AppColors.ink, // Using strict neutral Ink
      child: Column(
        children: [
          Text(
            '© A Software Development Project by IUT',
            style: TextStyle(
              color: AppColors.mist,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Helping you take your medicines calmly and safely every day',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ash,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Made with care by Team 404',
            style: TextStyle(
              color: AppColors.slate,
              fontSize: 14,
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
      ..color = AppColors.teal // Swapped to brand color for the faint watermark
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