class Customer {
  final int? id;
  final String customerName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? notes;
  final double? totalPurchases;
  final int? totalInvoices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.customerName,
    this.phoneNumber,
    this.email,
    this.address,
    this.gstNumber,
    this.notes,
    this.totalPurchases,
    this.totalInvoices,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      gstNumber: json['gstNumber'],
      notes: json['notes'],
      totalPurchases: json['totalPurchases']?.toDouble(),
      totalInvoices: json['totalInvoices'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'customerName': customerName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    if (gstNumber != null) 'gstNumber': gstNumber,
    if (notes != null) 'notes': notes,
  };
}
