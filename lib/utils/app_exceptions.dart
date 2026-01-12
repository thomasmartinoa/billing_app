/// Custom exception classes for better error handling
library;

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

/// Thrown when user registration fails
class RegistrationException extends AppException {
  RegistrationException(String message) : super(message);
}

/// Thrown when login fails
class LoginException extends AppException {
  LoginException(String message) : super(message);
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

/// Thrown when field value is invalid
class InvalidFieldException extends ValidationException {
  final String fieldName;
  final String? expectedFormat;

  InvalidFieldException(
    this.fieldName, {
    String? message,
    this.expectedFormat,
  }) : super(
          message ?? 'Invalid $fieldName${expectedFormat != null ? ". Expected format: $expectedFormat" : ""}',
          code: 'invalid-field',
        );
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

/// Thrown when trying to create duplicate entry
class DuplicateEntryException extends AppException {
  final String entityType;
  final String identifier;

  DuplicateEntryException(this.entityType, this.identifier)
      : super(
          '$entityType with identifier "$identifier" already exists.',
          code: 'duplicate-entry',
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

// ==================== Network Exceptions ====================

/// Thrown when network operation fails
class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'Network error. Please check your internet connection.');
}

/// Thrown when operation times out
class TimeoutException extends AppException {
  TimeoutException([String? message])
      : super(message ?? 'Operation timed out. Please try again.');
}

// ==================== Printing Exceptions ====================

/// Thrown when printer operation fails
class PrinterException extends AppException {
  PrinterException(String message, {String? code})
      : super(message, code: code);
}

/// Thrown when printer is not connected
class PrinterNotConnectedException extends PrinterException {
  PrinterNotConnectedException()
      : super(
          'Printer is not connected. Please connect a printer first.',
          code: 'printer-not-connected',
        );
}

/// Thrown when printer connection fails
class PrinterConnectionException extends PrinterException {
  final String deviceName;

  PrinterConnectionException(this.deviceName)
      : super(
          'Failed to connect to printer "$deviceName". Please try again.',
          code: 'printer-connection-failed',
        );
}

// ==================== File Operation Exceptions ====================

/// Thrown when file operation fails
class FileOperationException extends AppException {
  final String operation;
  final String? filePath;

  FileOperationException(
    this.operation, {
    this.filePath,
    String? message,
  }) : super(
          message ??
              'Failed to $operation${filePath != null ? " file: $filePath" : ""}',
          code: 'file-operation-failed',
        );
}

/// Thrown when PDF generation fails
class PdfGenerationException extends FileOperationException {
  PdfGenerationException([String? message])
      : super(
          'generate PDF',
          message: message ?? 'Failed to generate PDF document.',
        );
}
