import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/models/user_model.dart';
import 'package:billing_app/screens/home_screen.dart';

class ScreenSetup extends StatefulWidget {
  const ScreenSetup({super.key});

  @override
  State<ScreenSetup> createState() => _ScreenSetupState();
}

class _ScreenSetupState extends State<ScreenSetup> {
  int _step = 1;
  bool _isLoading = false;
  final _firestoreService = FirestoreService();

  final List<String> _shopTypes = const [
    "Restaurant",
    "Retail Store",
    "Grocery Store",
    "Salon & Spa",
    "Pharmacy",
    "Electronics",
    "Clothing & Fashion",
    "Bakery",
    "Cafe & Coffee Shop",
    "Hardware Store",
    "Bookstore",
    "Pet Shop",
    "Florist",
    "Jewelry Store",
    "Custom Shop",
  ];
  String _selectedShopType = "Retail Store";

  final List<IconData> _icons = const [
    Icons.storefront,
    Icons.shopping_bag_outlined,
    Icons.shopping_cart_outlined,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.build,
    Icons.local_florist,
    Icons.diamond_outlined,
    Icons.pets,
  ];
  IconData _selectedIcon = Icons.storefront;

  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  String _currency = "INR";
  final _taxRateCtrl = TextEditingController(text: "18");
  final _invoicePrefixCtrl = TextEditingController(text: "INV");
  bool _includeTaxInPrice = false;
  final _termsCtrl = TextEditingController();
  final _footerCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _gstCtrl.dispose();
    _taxRateCtrl.dispose();
    _invoicePrefixCtrl.dispose();
    _termsCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _completeSetup();
    }
  }

  void _goBack() {
    if (_step > 1) {
      setState(() => _step--);
    }
  }

  void _completeSetup() async {
    // Validate required fields
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your shop name')),
      );
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your shop address')),
      );
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final shopSettings = ShopSettings(
        shopType: _selectedShopType,
        iconCodePoint: _selectedIcon.codePoint,
        name: _nameCtrl.text.trim(),
        tagline: _taglineCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim(),
        currency: _currency,
        taxRate: double.tryParse(_taxRateCtrl.text) ?? 18.0,
        invoicePrefix: _invoicePrefixCtrl.text.trim(),
        includeTaxInPrice: _includeTaxInPrice,
        termsAndConditions: _termsCtrl.text.trim(),
        footerNote: _footerCtrl.text.trim(),
      );

      await _firestoreService.updateShopSettings(shopSettings);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17F1C5);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              "Setup Your Shop",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _step == 1
                  ? "Step 1: Choose Your Shop Type"
                  : _step == 2
                      ? "Step 2: Basic Information"
                      : "Step 3: Business Settings",
              style: const TextStyle(fontSize: 14, color: primary),
            ),
            const SizedBox(height: 8),
            _StepIndicator(currentStep: _step),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildStepContent(),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF141618),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _step == 1
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Continue"),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _goBack,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primary),
                              foregroundColor: primary,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Back"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _goNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.black,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading && _step == 3
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    _step == 3 ? "Complete Setup" : "Continue",
                                  ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
      default:
        return _buildStep3();
    }
  }

  Widget _buildStep1() {
    const primary = Color(0xFF17F1C5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What type of business do you run?",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select your shop type to customize the app experience",
          style: TextStyle(fontSize: 12, color: Color(0xFF8A8F98)),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            const int columns = 3;
            const double spacing = 8;

            final double totalSpacing = spacing * (columns - 1);
            final double itemWidth = (width - totalSpacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: _shopTypes.map((type) {
                final bool selected = _selectedShopType == type;
                return SizedBox(
                  width: itemWidth,
                  height: 90,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedShopType = type),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0E3A34)
                            : const Color(0xFF1B1E22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? primary : const Color(0xFF252A30),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          type,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? primary : const Color(0xFFD5D8DD),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "Choose an icon",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141618),
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              const int iconsPerRow = 6;
              const double iconSpacing = 8;
              final double totalIconSpacing = iconSpacing * (iconsPerRow - 1);
              final double iconButtonSize =
                  (width - (totalIconSpacing)) / iconsPerRow;

              final List<IconData> moreIcons = [
                ..._icons,
                Icons.fastfood,
                Icons.local_mall,
                Icons.computer,
                Icons.medical_services,
                Icons.spa,
                Icons.coffee,
                Icons.icecream,
                Icons.local_grocery_store,
                Icons.local_shipping,
                Icons.dry_cleaning,
              ];

              return Wrap(
                spacing: iconSpacing,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: moreIcons.map((icon) {
                  final selected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: iconButtonSize,
                      height: iconButtonSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1E22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? primary : const Color(0xFF252A30),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: iconButtonSize * 0.45,
                        color: selected ? primary : const Color(0xFFD5D8DD),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    const primary = Color(0xFF17F1C5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tell us about your shop",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "This information will appear on your invoices",
          style: TextStyle(fontSize: 12, color: Color(0xFF8A8F98)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.storefront, color: primary),
            labelText: "Shop Name *",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _taglineCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.format_quote, color: primary),
            labelText: "Tagline / Slogan",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _addressCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined, color: primary),
            labelText: "Address *",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone, color: primary),
            labelText: "Phone Number *",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined, color: primary),
            labelText: "Email Address",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _websiteCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.language, color: primary),
            labelText: "Website",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _gstCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.receipt_long, color: primary),
            labelText: "GST / Tax Number",
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    const primary = Color(0xFF17F1C5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Business Settings",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "Configure currency, tax, and invoice settings",
          style: TextStyle(fontSize: 12, color: Color(0xFF8A8F98)),
        ),
        const SizedBox(height: 12),
        const Text("Currency", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _currency,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.currency_rupee, color: primary),
          ),
          items: const [
            DropdownMenuItem(value: "INR", child: Text("INR - Indian Rupee")),
            DropdownMenuItem(value: "USD", child: Text("USD - US Dollar")),
            DropdownMenuItem(value: "EUR", child: Text("EUR - Euro")),
          ],
          onChanged: (val) => setState(() => _currency = val ?? "INR"),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _taxRateCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.percent, color: primary),
                  labelText: "Tax Rate (%)",
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _invoicePrefixCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.tag, color: primary),
                  labelText: "Invoice Prefix",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1E22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Include Tax in Price",
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Show prices with tax included",
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A8F98)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _includeTaxInPrice,
                onChanged: (val) => setState(() => _includeTaxInPrice = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text("Invoice Settings", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: _termsCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.menu_book_outlined, color: primary),
            labelText: "Terms & Conditions",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _footerCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.notes, color: primary),
            labelText: "Invoice Footer Note",
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const active = Color(0xFF17F1C5);
    const inactive = Color(0xFF33363B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = currentStep >= step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: index == 0 ? 40 : 4,
              right: index == 2 ? 40 : 4,
            ),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isActive ? active : inactive,
            ),
          ),
        );
      }),
    );
  }
}
