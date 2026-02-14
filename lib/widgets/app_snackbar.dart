import 'package:flutter/material.dart';
import 'package:billing_app/theme/theme_helper.dart';
import 'package:billing_app/constants/app_constants.dart';

/// Centralized SnackBar helper for consistent messaging throughout the app
class AppSnackBar {
  AppSnackBar._();

  /// Show a generic SnackBar with a message
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppDuration.snackbar,
      ),
    );
  }

  /// Show a success SnackBar (green background)
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.successColor,
        duration: AppDuration.snackbar,
      ),
    );
  }

  /// Show an error SnackBar (red background)
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.errorColor,
        duration: AppDuration.snackbar,
      ),
    );
  }

  /// Show a warning SnackBar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.warningColor,
        duration: AppDuration.snackbar,
      ),
    );
  }
}
