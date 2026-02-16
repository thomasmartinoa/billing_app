import 'package:flutter/material.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

/// Reusable empty state widget with icon, title, subtitle, and optional action button
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: OpacityConstants.light),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: context.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: AppFontSize.xxxl,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: AppFontSize.lg,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null && onButtonPressed != null) ...[
            const SizedBox(height: AppSpacing.xxxl),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: Icon(Icons.add, color: context.textPrimary),
              label: Text(
                buttonLabel!,
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.xl,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xxxl),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
