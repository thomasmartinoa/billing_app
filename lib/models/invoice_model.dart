import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.unit = 'pcs',
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? 'pcs',
    );
  }
}

enum PaymentMethod {
  cash,
  card,
  upi,
  bankTransfer,
  cheque,
  credit,
  other,
}

enum InvoiceStatus {
  pending,
  paid,
  cancelled,
}

class InvoiceModel {
  final String? id;
  final String invoiceNumber;
  final String? customerId;
  final String? customerName;
  final List<InvoiceItem> items;
  final double subtotal;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double total;
  final PaymentMethod paymentMethod;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? paidAt;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
    this.paidAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return InvoiceModel(
      id: docId,
      invoiceNumber: map['invoiceNumber'] ?? '',
      customerId: map['customerId'],
      customerName: map['customerName'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      taxRate: (map['taxRate'] ?? 0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InvoiceStatus.pending,
      ),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
    );
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    List<InvoiceItem>? items,
    double? subtotal,
    double? discount,
    double? taxRate,
    double? taxAmount,
    double? total,
    PaymentMethod? paymentMethod,
    InvoiceStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? paidAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  /// Total items count
  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);
}
