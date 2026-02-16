import 'package:flutter/material.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

/// Reusable confirmation dialog
class ConfirmDialog {
  ConfirmDialog._();

  /// Show a confirmation dialog and return true if confirmed, false/null otherwise
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxxl),
        ),
        title: Text(
          title,
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          message,
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? context.errorColor : context.accent,
              foregroundColor: context.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
