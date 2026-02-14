// Custom exception classes for better error handling
import 'package:firebase_auth/firebase_auth.dart';

/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

// ==================== Authentication Exceptions ====================

/// Thrown when user is not authenticated
class AuthenticationException extends AppException {
  AuthenticationException([String? message])
      : super(message ?? 'User is not authenticated. Please log in.');
}

// ==================== Data Validation Exceptions ====================

/// Thrown when data validation fails
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(String message, {this.fieldErrors, String? code})
      : super(message, code: code);
}

/// Thrown when required field is missing
class MissingFieldException extends ValidationException {
  final String fieldName;

  MissingFieldException(this.fieldName)
      : super('$fieldName is required', code: 'missing-field');
}

// ==================== Business Logic Exceptions ====================

/// Thrown when product is not found
class ProductNotFoundException extends AppException {
  final String productId;
  final String? productName;

  ProductNotFoundException(this.productId, [this.productName])
      : super(
          productName != null
              ? 'Product "$productName" (ID: $productId) no longer exists. It may have been deleted.'
              : 'Product with ID $productId not found.',
          code: 'product-not-found',
        );
}

/// Thrown when customer is not found
class CustomerNotFoundException extends AppException {
  final String customerId;
  final String? customerName;

  CustomerNotFoundException(this.customerId, [this.customerName])
      : super(
          customerName != null
              ? 'Customer "$customerName" (ID: $customerId) no longer exists.'
              : 'Customer with ID $customerId not found.',
          code: 'customer-not-found',
        );
}

/// Thrown when invoice is not found
class InvoiceNotFoundException extends AppException {
  final String invoiceId;

  InvoiceNotFoundException(this.invoiceId)
      : super(
          'Invoice with ID $invoiceId not found.',
          code: 'invoice-not-found',
        );
}

/// Thrown when product stock is insufficient
class InsufficientStockException extends AppException {
  final String productName;
  final int available;
  final int requested;

  InsufficientStockException(
    this.productName,
    this.available,
    this.requested,
  ) : super(
          'Insufficient stock for "$productName". Available: $available, Requested: $requested',
          code: 'insufficient-stock',
        );
}

// ==================== Firestore Exceptions ====================

/// Wrapper for Firestore exceptions with user-friendly messages
class FirestoreException extends AppException {
  FirestoreException({
    required String code,
    required String message,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);

  /// Create from Firebase exception
  factory FirestoreException.fromFirebase(FirebaseException error) {
    return FirestoreException(
      code: error.code,
      message: _getFriendlyMessage(error.code),
      originalError: error,
    );
  }

  static String _getFriendlyMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Operation timed out. Please check your internet connection.';
      case 'cancelled':
        return 'Operation was cancelled.';
      case 'data-loss':
        return 'Data may have been lost or corrupted.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
