import 'package:flutter/material.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

class QuickButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
                color:
                    context.accent.withValues(alpha: OpacityConstants.medium)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.accent, size: 28),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                    color: context.textSecondary, fontSize: AppFontSize.md),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
