import 'package:cloud_firestore/cloud_firestore.dart';

class ShopSettings {
  final String shopType;
  final int iconCodePoint;
  final String name;
  final String tagline;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String gstNumber;
  final String currency;
  final double taxRate;
  final String invoicePrefix;
  final bool includeTaxInPrice;
  final String termsAndConditions;
  final String footerNote;

  ShopSettings({
    required this.shopType,
    required this.iconCodePoint,
    required this.name,
    this.tagline = '',
    required this.address,
    required this.phone,
    this.email = '',
    this.website = '',
    this.gstNumber = '',
    this.currency = 'INR',
    this.taxRate = 18.0,
    this.invoicePrefix = 'INV',
    this.includeTaxInPrice = false,
    this.termsAndConditions = '',
    this.footerNote = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'shopType': shopType,
      'iconCodePoint': iconCodePoint,
      'name': name,
      'tagline': tagline,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'gstNumber': gstNumber,
      'currency': currency,
      'taxRate': taxRate,
      'invoicePrefix': invoicePrefix,
      'includeTaxInPrice': includeTaxInPrice,
      'termsAndConditions': termsAndConditions,
      'footerNote': footerNote,
    };
  }

  factory ShopSettings.fromMap(Map<String, dynamic> map) {
    return ShopSettings(
      shopType: map['shopType'] ?? '',
      iconCodePoint: map['iconCodePoint'] ?? 0,
      name: map['name'] ?? '',
      tagline: map['tagline'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      currency: map['currency'] ?? 'INR',
      taxRate: (map['taxRate'] ?? 18.0).toDouble(),
      invoicePrefix: map['invoicePrefix'] ?? 'INV',
      includeTaxInPrice: map['includeTaxInPrice'] ?? false,
      termsAndConditions: map['termsAndConditions'] ?? '',
      footerNote: map['footerNote'] ?? '',
    );
  }

  // Alias getters for compatibility
  String get shopName => name;
  String? get thankYouNote => footerNote.isNotEmpty ? footerNote : null;
}

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final ShopSettings? shopSettings;
  final bool isSetupComplete;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.shopSettings,
    this.isSetupComplete = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'shopSettings': shopSettings?.toMap(),
      'isSetupComplete': isSetupComplete,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      shopSettings: map['shopSettings'] != null
          ? ShopSettings.fromMap(map['shopSettings'])
          : null,
      isSetupComplete: map['isSetupComplete'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    ShopSettings? shopSettings,
    bool? isSetupComplete,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      shopSettings: shopSettings ?? this.shopSettings,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
