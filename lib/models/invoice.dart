import 'package:billing_app/models/customer.dart';

class Invoice {
  final int? id;
  final String? invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final InvoiceCustomerInfo? customer;
  final List<InvoiceItem> items;
  final double subtotal;
  final double discountAmount;
  final double discountPercentage;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double? balanceDue;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    this.id,
    this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    this.customer,
    required this.items,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.discountPercentage = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.balanceDue,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      customer: json['customer'] != null 
          ? InvoiceCustomerInfo.fromJson(json['customer']) 
          : null,
      items: (json['items'] as List?)
          ?.map((item) => InvoiceItem.fromJson(item))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      balanceDue: json['balanceDue']?.toDouble(),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus']),
      paymentMethod: json['paymentMethod'] != null 
          ? PaymentMethod.fromString(json['paymentMethod']) 
          : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'invoiceDate': invoiceDate.toIso8601String(),
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (customer?.id != null) 'customerId': customer!.id,
    'items': items.map((item) => item.toJson()).toList(),
    'discountAmount': discountAmount,
    'discountPercentage': discountPercentage,
    if (paymentMethod != null) 'paymentMethod': paymentMethod!.toApiString(),
    'markAsPaid': paymentStatus == PaymentStatus.paid,
    if (notes != null) 'notes': notes,
  };
}

class InvoiceCustomerInfo {
  final int? id;
  final String customerName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? gstNumber;

  InvoiceCustomerInfo({
    this.id,
    required this.customerName,
    this.phoneNumber,
    this.email,
    this.address,
    this.gstNumber,
  });

  factory InvoiceCustomerInfo.fromJson(Map<String, dynamic> json) {
    return InvoiceCustomerInfo(
      id: json['id'],
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      gstNumber: json['gstNumber'],
    );
  }
}

class InvoiceItem {
  final int? id;
  final int productId;
  final String productName;
  final String? description;
  final int quantity;
  final String? unit;
  final double unitPrice;
  final double discountAmount;
  final double lineTotal;

  InvoiceItem({
    this.id,
    required this.productId,
    required this.productName,
    this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    this.discountAmount = 0,
    this.lineTotal = 0,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      unit: json['unit'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      lineTotal: (json['lineTotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    if (unitPrice > 0) 'unitPrice': unitPrice,
    'discountAmount': discountAmount,
  };
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  overdue,
  cancelled;

  static PaymentStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return PaymentStatus.pending;
      case 'PARTIAL':
        return PaymentStatus.partial;
      case 'PAID':
        return PaymentStatus.paid;
      case 'OVERDUE':
        return PaymentStatus.overdue;
      case 'CANCELLED':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  String toApiString() => name.toUpperCase();
}

enum PaymentMethod {
  cash,
  card,
  upi,
  bankTransfer,
  cheque,
  credit,
  other;

  static PaymentMethod fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CASH':
        return PaymentMethod.cash;
      case 'CARD':
        return PaymentMethod.card;
      case 'UPI':
        return PaymentMethod.upi;
      case 'BANK_TRANSFER':
        return PaymentMethod.bankTransfer;
      case 'CHEQUE':
        return PaymentMethod.cheque;
      case 'CREDIT':
        return PaymentMethod.credit;
      case 'OTHER':
        return PaymentMethod.other;
      default:
        return PaymentMethod.cash;
    }
  }

  String toApiString() {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return 'BANK_TRANSFER';
      default:
        return name.toUpperCase();
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.credit:
        return 'Credit';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}
