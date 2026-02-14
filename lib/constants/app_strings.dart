// Application-wide string constants for UI text
// This structure supports easy migration to flutter_localizations in the future

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

  // --- Invoice Screen ---
  static const String invoice = 'INVOICE';
  static const String invoiceNo = 'Invoice No:';
  static const String invoiceNumber = 'Invoice Number';
  static const String date = 'Date:';
  static const String customer = 'Customer:';
  static const String walkInCustomer = 'Walk-in Customer';
  static const String thankYou = 'Thank You!';
  static const String thankYouMessage = 'Thank you for your business!';
  static const String visitAgain = 'Visit Again!';
  static const String paymentStatus = 'Payment:';
  static const String invoiceStatus = 'Status:';

  // --- Cart ---
  static const String cart = 'Cart';
  static const String items = 'Items';
  static const String addToCart = 'Add to Cart';
  static const String clearCart = 'Clear Cart';
  static const String emptyCart = 'Cart is empty';
  static const String addItemsToCart = 'Please add items to cart';
  static const String confirmInvoice = 'Confirm Invoice';
  static const String invoiceConfirmation = 'Invoice Confirmation';

  // --- Validation Messages ---
  static const String enterProductName = 'Please enter product name';
  static const String enterSellingPrice = 'Please enter selling price';
  static const String priceGreaterThanZero = 'Selling price must be greater than 0';
  static const String costPriceCannotBeNegative = 'Cost price cannot be negative';
  static const String stockCannotBeNegative = 'Stock cannot be negative';
  static const String enterCustomerName = 'Please enter customer name';
  static const String enterValidEmail = 'Please enter a valid email address';
  static const String enterValidPhone = 'Please enter a valid phone number';
  static const String selectCategory = 'Please select a category';

  // --- Warnings & Confirmations ---
  static const String costHigherWarningTitle = 'Cost Higher Than Selling Price';
  static const String costHigherWarning = 'Cost price is greater than selling price. This product will result in a loss. Continue anyway?';
  static const String lowStockWarning = 'Low Stock Warning';
  static const String outOfStock = 'Out of Stock';
  static const String insufficientStock = 'Insufficient stock available';

  // --- Dashboard/Stats ---
  static const String totalRevenue = 'Total Revenue';
  static const String totalProducts = 'Total Products';
  static const String totalCustomers = 'Total Customers';
  static const String lowStockItems = 'Low Stock Items';
  static const String recentInvoices = 'Recent Invoices';
  static const String quickStats = 'Quick Stats';

  // --- Product Fields ---
  static const String productName = 'Product Name';
  static const String sellingPrice = 'Selling Price';
  static const String costPrice = 'Cost Price';
  static const String currentStock = 'Current Stock';
  static const String minStock = 'Minimum Stock';
  static const String category = 'Category';
  static const String unit = 'Unit';
  static const String sku = 'SKU';
  static const String description = 'Description';

  // --- Customer Fields ---
  static const String customerName = 'Customer Name';
  static const String email = 'Email';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String customerDetails = 'Customer Details';

  // --- Settings ---
  static const String shopSettings = 'Shop Settings';
  static const String shopName = 'Shop Name';
  static const String shopType = 'Shop Type';
  static const String tagline = 'Tagline';
  static const String gstNumber = 'GST Number';
  static const String website = 'Website';
  static const String taxRate = 'Tax Rate (%)';
  static const String invoicePrefix = 'Invoice Prefix';
  static const String includeTaxInPrice = 'Include Tax in Price';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String footerNote = 'Footer Note';
  static const String currency = 'Currency';

  // --- Printer ---
  static const String printer = 'Printer';
  static const String printerSettings = 'Printer Settings';
  static const String connectPrinter = 'Connect Printer';
  static const String disconnectPrinter = 'Disconnect Printer';
  static const String printReceipt = 'Print Receipt';
  static const String printerNotConnected = 'Printer not connected';
  static const String selectPrinter = 'Select Printer';
  static const String printerConnected = 'Printer Connected';

  // --- Theme ---
  static const String theme = 'Theme';
  static const String lightTheme = 'Light';
  static const String darkTheme = 'Dark';
  static const String systemTheme = 'System';

  // --- About ---
  static const String version = 'Version';
  static const String developer = 'Developer';
  static const String appName = 'Billing App';
  static const String appDescription = 'A complete billing solution for your business';

  // --- Authentication ---
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String createAccount = 'Create Account';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String welcomeBack = 'Welcome Back';
  static const String getStarted = 'Get Started';

  // --- General ---
  static const String back = 'Back';
  static const String next = 'Next';
  static const String finish = 'Finish';
  static const String skip = 'Skip';
  static const String continueText = 'Continue';
  static const String update = 'Update';
  static const String refresh = 'Refresh';
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String tryAgain = 'Try Again';
  static const String retry = 'Retry';
}
