import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'gstNumber': gstNumber,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerModel(
      id: docId,
      name: map['name'] ?? '',
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      gstNumber: map['gstNumber'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? gstNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
