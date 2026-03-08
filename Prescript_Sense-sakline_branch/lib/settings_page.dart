// import 'package:flutter/material.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           ListTile(
//             leading: const Icon(Icons.color_lens),
//             title: const Text('Theme'),
//             subtitle: const Text('Light / Dark Mode'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.language),
//             title: const Text('Language'),
//             subtitle: const Text('English / Bangla'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.notifications),
//             title: const Text('Notification Settings'),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'app_colors.dart'; // Ensure you import your color palette

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            "Preferences",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mist, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Theme',
                  subtitle: 'Light / Dark Mode',
                  onTap: () {},
                ),
                const Divider(color: AppColors.mist, height: 1, indent: 64),
                _buildSettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'English / Bangla',
                  onTap: () {},
                ),
                const Divider(color: AppColors.mist, height: 1, indent: 64),
                _buildSettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification Settings',
                  subtitle: 'Manage alerts and sounds',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "Support",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mist, width: 1.5),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help Center',
                  subtitle: 'FAQ and support',
                  onTap: () {},
                ),
                const Divider(color: AppColors.mist, height: 1, indent: 64),
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About PrescriptSense',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.teal, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.slate, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.ash,
      ),
    );
  }
}
