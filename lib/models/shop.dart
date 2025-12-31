class Shop {
  final int? id;
  final String shopName;
  final String? shopType;
  final String? tagline;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? gstNumber;
  final int? iconCode;
  final String? logoUrl;
  final String currency;
  final double taxRate;
  final String invoicePrefix;
  final bool includeTaxInPrice;
  final String? termsAndConditions;
  final String? footerNote;

  Shop({
    this.id,
    required this.shopName,
    this.shopType,
    this.tagline,
    this.address,
    this.phoneNumber,
    this.email,
    this.website,
    this.gstNumber,
    this.iconCode,
    this.logoUrl,
    this.currency = 'INR',
    this.taxRate = 18.0,
    this.invoicePrefix = 'INV',
    this.includeTaxInPrice = false,
    this.termsAndConditions,
    this.footerNote,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      shopName: json['shopName'] ?? '',
      shopType: json['shopType'],
      tagline: json['tagline'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      gstNumber: json['gstNumber'],
      iconCode: json['iconCode'],
      logoUrl: json['logoUrl'],
      currency: json['currency'] ?? 'INR',
      taxRate: (json['taxRate'] ?? 18.0).toDouble(),
      invoicePrefix: json['invoicePrefix'] ?? 'INV',
      includeTaxInPrice: json['includeTaxInPrice'] ?? false,
      termsAndConditions: json['termsAndConditions'],
      footerNote: json['footerNote'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'shopName': shopName,
    if (shopType != null) 'shopType': shopType,
    if (tagline != null) 'tagline': tagline,
    if (address != null) 'address': address,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (email != null) 'email': email,
    if (website != null) 'website': website,
    if (gstNumber != null) 'gstNumber': gstNumber,
    if (iconCode != null) 'iconCode': iconCode,
    if (logoUrl != null) 'logoUrl': logoUrl,
    'currency': currency,
    'taxRate': taxRate,
    'invoicePrefix': invoicePrefix,
    'includeTaxInPrice': includeTaxInPrice,
    if (termsAndConditions != null) 'termsAndConditions': termsAndConditions,
    if (footerNote != null) 'footerNote': footerNote,
  };
}
