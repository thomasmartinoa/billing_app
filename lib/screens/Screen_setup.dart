import 'package:flutter/material.dart';

class ScreenSetup extends StatefulWidget {
  const ScreenSetup({super.key});

  @override
  State<ScreenSetup> createState() => _ScreenSetupState();
}

class _ScreenSetupState extends State<ScreenSetup> {
  int _step = 1;
  final List<String> _shopTypes = const [
    "Restaurant",
    "Retail Store",
    "Grocery Store",
    "Salon and Spa",
    "Pharmacy",
    "Electronics Store",
    "Clothing Boutique",
    "Bakery",
    "Cafe and Coffee Shop",
    "Hardware Store",
    "Bookstore",
    "Pet Store",
    "Jewelry Store",
    "Custom Shop",
  ];
  String _selectedShopType = "Restaurant";

  final List<IconData> _icons = const [
    Icons.storefront,
    Icons.shopping_bag_outlined,
    Icons.shopping_cart_outlined,
    Icons.restaurant,
    Icons.local_pharmacy,
    Icons.electrical_services,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.local_florist,
    Icons.diamond_outlined,
    Icons.build,
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
  bool _includeTaxInPrices = false;
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

  void _completeSetup() {
    final payload = {
      "shopType": _selectedShopType,
      "icon": _selectedIcon.codePoint,
      "basicinfo": {
        "name": _nameCtrl.text,
        "tagline": _taglineCtrl.text,
        "address": _addressCtrl.text,
        "phone": _phoneCtrl.text,
        "email": _emailCtrl.text,
        "website": _websiteCtrl.text,
        "gst": _gstCtrl.text,
      },
      "businessSettings": {
        "currency": _currency,
        "taxRate": _taxRateCtrl.text,
        "invoicePrefix": _invoicePrefixCtrl.text,
        "includeTaxInPrices": _includeTaxInPrices,
        "terms": _termsCtrl.text,
        "footerNotes": _footerCtrl.text,
      },
    };

    debugPrint("SHOP SETUP DATA: $payload");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shop setup complete!(check console)")),
    );
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
              "Setup Tour Shop",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _step == 1
                  ? "Step 1:Choose Your Shop Type"
                  : _step == 2
                  ? "Step 2:Basic Information"
                  : "Step 3:Business Settings",
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
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141618),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildStepContent(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _step == 1 ? null : _goBack,
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
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_step == 3 ? "Complete Setup" : "Continue"),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What type of business do you run?",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select your shop type to  customize your experience.",
          style: TextStyle(fontSize: 12, color: Color(0xFF8A8F98)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _shopTypes.map((type) {
            final bool selected = _selectedShopType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedShopType = type),
              child: Container(
                width: 110,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF17F1C5)
                        : const Color(0xFF252A30),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : const Color(0xFFD5D8DD),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          "choose an icon for your shop:",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _icons.map((icon) {
            final bool selected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF17F1C5)
                        : const Color(0xFF252A30),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? const Color(0xFF17F1C5)
                      : const Color(0xFFD5D8DD),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tell us about your shop",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "This information will be displayed on your invoices.",
          style: TextStyle(fontSize: 12, color: Color(0xFF8A8F98)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: "Shop Name *"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _taglineCtrl,
          decoration: const InputDecoration(labelText: "Tagline / Slogan"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _addressCtrl,
          decoration: const InputDecoration(labelText: "Address *"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: "Phone Number *"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Email Address"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _websiteCtrl,
          decoration: const InputDecoration(labelText: "Website"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _gstCtrl,
          decoration: const InputDecoration(labelText: "GST / Tax Number"),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Business settings",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "Configure currency, tax rates, and invoice settings for your shop.",
          style: TextStyle(fontSize: 12, color: Color(0xFF8A8F98)),
        ),
        const SizedBox(height: 12),
        const Text("Currency", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _currency,
          items: const [
            DropdownMenuItem(value: "INR", child: Text("Indian Rupee (INR)")),
            DropdownMenuItem(value: "USD", child: Text("US Dollar (USD)")),
            DropdownMenuItem(value: "EUR", child: Text("Euro (EUR)")),
            DropdownMenuItem(value: "GBP", child: Text("British Pound (GBP)")),
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
                  labelText: "Default Tax Rate (%)",
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _invoicePrefixCtrl,
                decoration: const InputDecoration(labelText: "Invoice Prefix"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Include Tax in Prices", style: TextStyle(fontSize: 13)),
            Switch(
              value: _includeTaxInPrices,
              onChanged: (val) => setState(() => _includeTaxInPrices = val),
            ),
          ],
        ),

        const SizedBox(height: 8),
        TextField(
          controller: _termsCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Default Terms and Conditions",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _footerCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: "Invoice Footer Notes"),
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
