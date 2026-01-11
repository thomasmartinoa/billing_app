/// Application-wide string constants for UI text
/// This structure supports easy migration to flutter_localizations in the future
library;

class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // --- Button Labels ---
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';

  // --- Status Labels ---
  static const String paid = 'Paid';
  static const String unpaid = 'Unpaid';
  static const String pending = 'Pending';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String loading = 'Loading';

  // --- Common Actions ---
  static const String addCustomer = 'Add Customer';
  static const String addProduct = 'Add Product';
  static const String createInvoice = 'Create Invoice';
  static const String deleteCustomer = 'Delete Customer';
  static const String deleteProduct = 'Delete Product';
  static const String editCustomer = 'Edit Customer';
  static const String editProduct = 'Edit Product';
  static const String searchProducts = 'Search products...';
  static const String searchCustomers = 'Search customers...';
  static const String filterByActivity = 'Filter By Activity';

  // --- Screen Titles ---
  static const String products = 'Products';
  static const String customers = 'Customers';
  static const String billing = 'Billing';
  static const String invoices = 'Invoices';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String about = 'About';

  // --- Invoice/Payment ---
  static const String total = 'Total';
  static const String subtotal = 'Subtotal';
  static const String tax = 'Tax';
  static const String discount = 'Discount';
  static const String paidOn = 'Paid On';
  static const String paidAt = 'Paid At';
  static const String status = 'Status';
  static const String saveAsPdf = 'Save as PDF';

  // --- Messages ---
  static const String deleteConfirmation = 'Are you sure you want to delete this item?';
  static const String deleteCustomerConfirmation = 'Are you sure you want to delete this customer?';
  static const String deleteProductConfirmation = 'Are you sure you want to delete this product?';
  static const String savingChanges = 'Saving changes...';
  static const String savedSuccessfully = 'Saved successfully';
  
  // --- Error Messages (templates) ---
  static String errorLoading(String item) => 'Error loading $item';
  static String errorSaving(String item) => 'Error saving $item';
  static String errorDeleting(String item) => 'Error deleting $item';
  static String errorMessage(String message) => 'Error: $message';
  
  // --- Hints ---
  static const String enterName = 'Enter name';
  static const String enterEmail = 'Enter email';
  static const String enterPhone = 'Enter phone';
  static const String enterAddress = 'Enter address';
}
