import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Toggle states
  bool isStockAvailable = true;
  bool isTaxEnabled = false;
  bool isDiscountEnabled = false;

  @override
  Widget build(BuildContext context) {
    // Design Colors
    const Color backgroundColor = Colors.black;
    const Color surfaceColor = Color(0xFF1F1F1F);
    const Color accentColor = Color(0xFF00E676);
    const Color textWhite = Colors.white;
    const Color textGray = Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textWhite),
          onPressed: () {
            // TODO: Handle back navigation
          },
        ),
        title: const Text(
          "Add Product",
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Basic Information", style: TextStyle(color: textGray, fontSize: 12)),
            const SizedBox(height: 10),

            // --- Product Name ---
            _buildTextField(label: "Product Name", hint: "Enter product name"),
            const SizedBox(height: 16),

            // --- Category Dropdown ---
            _buildTextField(
              label: "Category", 
              hint: "Select Category", 
              icon: Icons.keyboard_arrow_down
            ),
            const SizedBox(height: 16),

            // --- Price Row (Selling & Cost) ---
            // UPDATED: Now restricting input to Numbers only
            Row(
              children: [
                Expanded(child: _buildTextField(
                  label: "Selling Price", 
                  hint: "₹ 0.00",
                  inputType: const TextInputType.numberWithOptions(decimal: true)
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(
                  label: "Cost Price", 
                  hint: "₹ 0.00",
                  inputType: const TextInputType.numberWithOptions(decimal: true)
                )),
              ],
            ),
            const SizedBox(height: 24),

            const Divider(color: surfaceColor, thickness: 1),
            const SizedBox(height: 16),

            // --- Toggles Section ---
            const Text("Settings", style: TextStyle(color: textGray, fontSize: 12)),
            const SizedBox(height: 10),

            _buildSwitchTile("Stock Available", isStockAvailable, (val) {
              setState(() => isStockAvailable = val);
            }),
            
            _buildSwitchTile("Apply Tax", isTaxEnabled, (val) {
              setState(() => isTaxEnabled = val);
            }),

             _buildSwitchTile("Apply Discount", isDiscountEnabled, (val) {
              setState(() => isDiscountEnabled = val);
            }),

            const SizedBox(height: 40),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add Product",
                  style: TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED HELPER WIDGET ---
  Widget _buildTextField({
    required String label, 
    required String hint, 
    IconData? icon,
    TextInputType inputType = TextInputType.text // Added default type
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          keyboardType: inputType, // <--- Using the new input type here
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1F1F1F),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  // Helper widget for switches
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00E676),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

