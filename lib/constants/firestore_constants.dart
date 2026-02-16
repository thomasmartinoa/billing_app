// Firestore collection and field name constants
//
// Centralizes all Firestore collection names to prevent typos and
// enable easy refactoring of database structure.

class FirestoreCollections {
  FirestoreCollections._(); // Private constructor to prevent instantiation

  // Top-level collections
  static const String users = 'users';

  // Sub-collections under users
  static const String customers = 'customers';
  static const String products = 'products';
  static const String invoices = 'invoices';
  static const String categories = 'categories';
}

/// Common Firestore field names used across collections
class FirestoreFields {
  FirestoreFields._();

  // Common timestamp fields
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // User fields
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String shopSettings = 'shopSettings';
  static const String isSetupComplete = 'isSetupComplete';

  // Shop settings fields
  static const String shopName = 'name';
  static const String shopType = 'shopType';
  static const String address = 'address';
  static const String phone = 'phone';
  static const String taxRate = 'taxRate';
  static const String currency = 'currency';
  static const String invoicePrefix = 'invoicePrefix';

  // Product fields
  static const String name = 'name';
  static const String category = 'category';
  static const String sku = 'sku';
  static const String sellingPrice = 'sellingPrice';
  static const String costPrice = 'costPrice';
  static const String currentStock = 'currentStock';
  static const String minStock = 'minStock';
  static const String trackInventory = 'trackInventory';

  // Invoice fields
  static const String invoiceNumber = 'invoiceNumber';
  static const String customerId = 'customerId';
  static const String customerName = 'customerName';
  static const String items = 'items';
  static const String subtotal = 'subtotal';
  static const String discount = 'discount';
  static const String taxAmount = 'taxAmount';
  static const String total = 'total';
  static const String paymentStatus = 'paymentStatus';
  static const String status = 'status';
}
