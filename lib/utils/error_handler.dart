import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Centralized error handling for the application
class ErrorHandler {
  ErrorHandler._();

  /// Handle Firebase errors and return user-friendly messages
  static String handleFirebaseError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        // Auth Errors
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'operation-not-allowed':
          return 'This operation is not allowed';

        // Firestore Errors
        case 'permission-denied':
          return 'You don\'t have permission to access this data';
        case 'unavailable':
          return 'Service unavailable. Please check your connection';
        case 'deadline-exceeded':
          return 'Request timeout. Please try again';
        case 'already-exists':
          return 'This item already exists';
        case 'not-found':
          return 'The requested item was not found';
        case 'resource-exhausted':
          return 'Too many requests. Please try again later';
        case 'failed-precondition':
          return 'Operation cannot be completed in current state';
        case 'aborted':
          return 'Operation aborted. Please try again';
        case 'out-of-range':
          return 'Invalid operation parameter';
        case 'unimplemented':
          return 'This feature is not implemented yet';
        case 'internal':
          return 'Internal server error. Please try again';
        case 'data-loss':
          return 'Data loss detected. Please contact support';
        case 'unauthenticated':
          return 'Please sign in to continue';

        default:
          return error.message ?? 'An error occurred: ${error.code}';
      }
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return 'Network error. Please check your internet connection';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'requires-recent-login':
          return 'Please sign in again to complete this action';
        default:
          return error.message ?? 'Authentication error: ${error.code}';
      }
    }

    // Generic errors
    if (error is FormatException) {
      return 'Invalid data format: ${error.message}';
    }

    if (error is TypeError) {
      return 'Data type error. Please check your input';
    }

    return error.toString();
  }

  /// Log error for debugging (can be extended to send to analytics)
  static void logError(dynamic error, StackTrace? stackTrace,
      {String? context}) {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('ERROR ${context != null ? "in $context" : ""}');
    debugPrint('Time: ${DateTime.now()}');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack Trace:');
      debugPrint(stackTrace.toString());
    }
    debugPrint('═══════════════════════════════════════════════════════');

    // TODO: Send to crash analytics (Firebase Crashlytics, Sentry, etc.)
  }
}

/// Extension for easy error handling in widgets
extension ErrorHandlingExtension on dynamic {
  String toUserMessage() => ErrorHandler.handleFirebaseError(this);
}

/// Validation errors
class ValidationError implements Exception {
  final String message;
  ValidationError(this.message);

  @override
  String toString() => message;
}

/// Common validation utilities
class Validators {
  Validators._();

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate number
  static String? number(
    String? value, {
    String fieldName = 'This field',
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }

    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value,
      {String fieldName = 'This field'}) {
    return number(value, fieldName: fieldName, min: 0);
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int length,
      {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < length) {
      return '$fieldName must be at least $length characters';
    }

    return null;
  }

  /// Validate GST number (Indian format)
  static String? gst(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final gstRegex =
        RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$');
    if (!gstRegex.hasMatch(value.trim())) {
      return 'Please enter a valid GST number';
    }

    return null;
  }
}
