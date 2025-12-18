import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool isTrackInventory = true;
  String selectedUnit = 'pcs';

  // --- Design Colors ---
  final Color backgroundColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF1F1F1F);
  final Color accentColor = const Color(0xFF00E676);
  final Color textWhite = Colors.white;
  final Color textGray = const Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Product",
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Basic Information ---
            _buildSectionHeader("Basic Information"),
            const SizedBox(height: 16),
            _buildTextField(icon: Icons.inventory_2, hint: "Product Name *"),
            const SizedBox(height: 16),
            _buildTextField(
              icon: Icons.description, 
              hint: "Description", 
              maxLines: 3
            ),
            const SizedBox(height: 16),
            _buildSelectorField(
              icon: Icons.category,
              hint: "No Category",
              onTap: () {
                // TODO: Show category selector
              },
            ),
            const SizedBox(height: 30),

            // --- 2. Pricing ---
            _buildSectionHeader("Pricing"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    icon: Icons.attach_money, 
                    hint: "Selling Price *",
                    inputType: TextInputType.number
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    icon: Icons.money_off, 
                    hint: "Cost Price",
                    inputType: TextInputType.number
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- 3. Inventory ---
            _buildSectionHeader("Inventory"),
            const SizedBox(height: 16),
            _buildToggleTile(
              title: "Track Inventory",
              subtitle: "Monitor stock levels",
              icon: Icons.inventory,
              value: isTrackInventory,
              onChanged: (val) => setState(() => isTrackInventory = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    icon: Icons.numbers, 
                    hint: "0",
                    label: "Current Stock",
                    inputType: TextInputType.number
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectorField(
                    hint: selectedUnit,
                    label: "Unit",
                    showDropdownIcon: true,
                    onTap: () {
                      // TODO: Show unit selector
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              icon: Icons.warning_amber, 
              hint: "Low Stock Alert",
              inputType: TextInputType.number
            ),
            const SizedBox(height: 30),

            // --- 4. Identification (Optional) ---
            _buildSectionHeader("Identification (Optional)"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(icon: Icons.qr_code, hint: "SKU"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(icon: Icons.barcode_reader, hint: "Barcode"),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper: Section Header with Vertical Bar ---
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 4,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- Helper: Standard Text Field ---
  Widget _buildTextField({
    required IconData icon,
    required String hint,
    String? label,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: TextStyle(color: textGray, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            style: TextStyle(color: textWhite),
            keyboardType: inputType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textGray),
              prefixIcon: Icon(icon, color: textGray),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper: Selector Field (like Dropdown) ---
  Widget _buildSelectorField({
    IconData? icon,
    required String hint,
    String? label,
    required VoidCallback onTap,
    bool showDropdownIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: TextStyle(color: textGray, fontSize: 12)),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textGray),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(color: textWhite),
                  ),
                ),
                Icon(
                  showDropdownIcon ? Icons.arrow_drop_down : Icons.arrow_forward_ios,
                  color: textGray,
                  size: showDropdownIcon ? 24 : 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper: Toggle Switch Tile ---
  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        secondary: Icon(icon, color: textGray),
        title: Text(title, style: TextStyle(color: textWhite, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: textGray)),
      ),
    );
  }
}

// --- TEMPORARY TEST CODE (Delete before committing) ---
void main() {
  runApp(const MaterialApp(
    home: AddProductScreen(),
    debugShowCheckedModeBanner: false,
  ));
}