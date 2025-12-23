import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color backgroundColor = Color(0xFF050608);
  static const Color surfaceColor = Color(0x14181818);
  static const Color accentColor = Color(0xFF00C59E);
  static const Color borderColor = Color(0xFF12332D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor, width: 2),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: accentColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'Billing App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor.withOpacity(0.6)),
              ),
              child: const Text(
                'A comprehensive billing and invoice management solution designed to help businesses streamline their sales process, manage inventory, track customers, and generate professional invoices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Features
            _buildSectionTitle('Features'),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.inventory_2, 'Product Management'),
            _buildFeatureItem(Icons.people, 'Customer Management'),
            _buildFeatureItem(Icons.receipt, 'Invoice Generation'),
            _buildFeatureItem(Icons.analytics, 'Sales Analytics'),
            _buildFeatureItem(Icons.category, 'Category Management'),
            _buildFeatureItem(Icons.cloud, 'Cloud Sync'),
            const SizedBox(height: 30),
            // Support Section
            _buildSectionTitle('Support'),
            const SizedBox(height: 16),
            _buildSupportCard(
              icon: Icons.bug_report,
              title: 'Report a Bug',
              subtitle: 'Found an issue? Let us know',
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.help,
              title: 'Help & FAQ',
              subtitle: 'Get answers to common questions',
              onTap: () => _showComingSoonDialog(context),
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.star,
              title: 'Rate Us',
              subtitle: 'Enjoying the app? Leave a review',
              onTap: () => _showComingSoonDialog(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: accentColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@billingapp.com',
      query: 'subject=Bug Report - Billing App',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor),
        ),
        title: const Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This feature will be available in a future update.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
