import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id;
  final String name;
  final String? description;
  final String? category;
  final double sellingPrice;
  final double? costPrice;
  final bool trackInventory;
  final int currentStock;
  final String unit;
  final int? lowStockAlert;
  final String? sku;
  final String? barcode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id,
    required this.name,
    this.description,
    this.category,
    required this.sellingPrice,
    this.costPrice,
    this.trackInventory = true,
    this.currentStock = 0,
    this.unit = 'pcs',
    this.lowStockAlert,
    this.sku,
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'trackInventory': trackInventory,
      'currentStock': currentStock,
      'unit': unit,
      'lowStockAlert': lowStockAlert,
      'sku': sku,
      'barcode': barcode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
      costPrice: map['costPrice']?.toDouble(),
      trackInventory: map['trackInventory'] ?? true,
      currentStock: map['currentStock'] ?? 0,
      unit: map['unit'] ?? 'pcs',
      lowStockAlert: map['lowStockAlert'],
      sku: map['sku'],
      barcode: map['barcode'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? sellingPrice,
    double? costPrice,
    bool? trackInventory,
    int? currentStock,
    String? unit,
    int? lowStockAlert,
    String? sku,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      trackInventory: trackInventory ?? this.trackInventory,
      currentStock: currentStock ?? this.currentStock,
      unit: unit ?? this.unit,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if stock is low based on lowStockAlert threshold
  bool get isLowStock {
    if (!trackInventory || lowStockAlert == null) return false;
    return currentStock <= lowStockAlert!;
  }
}
