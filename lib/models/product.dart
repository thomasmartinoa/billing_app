class Product {
  final int? id;
  final String productName;
  final String? description;
  final double sellingPrice;
  final double? costPrice;
  final String? sku;
  final String? barcode;
  final String unit;
  final bool trackInventory;
  final int currentStock;
  final int lowStockAlert;
  final bool? isLowStock;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.productName,
    this.description,
    required this.sellingPrice,
    this.costPrice,
    this.sku,
    this.barcode,
    this.unit = 'pcs',
    this.trackInventory = true,
    this.currentStock = 0,
    this.lowStockAlert = 10,
    this.isLowStock,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productName: json['productName'] ?? '',
      description: json['description'],
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      costPrice: json['costPrice']?.toDouble(),
      sku: json['sku'],
      barcode: json['barcode'],
      unit: json['unit'] ?? 'pcs',
      trackInventory: json['trackInventory'] ?? true,
      currentStock: json['currentStock'] ?? 0,
      lowStockAlert: json['lowStockAlert'] ?? 10,
      isLowStock: json['isLowStock'],
      imageUrl: json['imageUrl'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'productName': productName,
    if (description != null) 'description': description,
    'sellingPrice': sellingPrice,
    if (costPrice != null) 'costPrice': costPrice,
    if (sku != null) 'sku': sku,
    if (barcode != null) 'barcode': barcode,
    'unit': unit,
    'trackInventory': trackInventory,
    'currentStock': currentStock,
    'lowStockAlert': lowStockAlert,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (categoryId != null) 'categoryId': categoryId,
  };
}

class Category {
  final int? id;
  final String categoryName;
  final String? description;
  final String? colorCode;
  final int? productCount;

  Category({
    this.id,
    required this.categoryName,
    this.description,
    this.colorCode,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
      colorCode: json['colorCode'],
      productCount: json['productCount'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'categoryName': categoryName,
    if (description != null) 'description': description,
    if (colorCode != null) 'colorCode': colorCode,
  };
}
