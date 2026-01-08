import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
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
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: Icon(
                Icons.receipt_long,
                color: colorScheme.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            // App Name
            Text(
              'Billing App',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.6)),
              ),
              child: Text(
                'A comprehensive billing and invoice management solution designed to help businesses streamline their sales process, manage inventory, track customers, and generate professional invoices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Features
            _buildSectionTitle('Features', context),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.inventory_2, 'Product Management', context),
            _buildFeatureItem(Icons.people, 'Customer Management', context),
            _buildFeatureItem(Icons.receipt, 'Invoice Generation', context),
            _buildFeatureItem(Icons.analytics, 'Sales Analytics', context),
            _buildFeatureItem(Icons.category, 'Category Management', context),
            _buildFeatureItem(Icons.cloud, 'Cloud Sync', context),
            const SizedBox(height: 30),
            // Support Section
            _buildSectionTitle('Support', context),
            const SizedBox(height: 16),
            _buildSupportCard(
              icon: Icons.bug_report,
              title: 'Report a Bug',
              subtitle: 'Found an issue? Let us know',
              onTap: () => _launchEmail(),
              context: context,
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.help,
              title: 'Help & FAQ',
              subtitle: 'Get answers to common questions',
              onTap: () => _showComingSoonDialog(context),
              context: context,
            ),
            const SizedBox(height: 12),
            _buildSupportCard(
              icon: Icons.star,
              title: 'Rate Us',
              subtitle: 'Enjoying the app? Leave a review',
              onTap: () => _showComingSoonDialog(context),
              context: context,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        color: colorScheme.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.onSurface,
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
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.4), size: 16),
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
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline),
        ),
        title: Text(
          'Coming Soon',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This feature will be available in a future update.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
