import 'package:flutter/material.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Design Colors from Image ---
    const Color backgroundColor = Color(0xFF000000); // Black background
    const Color surfaceColor = Color(0xFF1F1F1F);   // Dark field color
    const Color accentColor = Color(0xFF00E676);    // Teal accent
    const Color textWhite = Colors.white;
    const Color textGray = Color(0xFF757575);       // Hint text color

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            // TODO: Handle back navigation
          },
        ),
        title: const Text(
          "Add Customer",
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Top Glowing Icon ---
            Center(
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.question_mark, color: accentColor, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- 2. Contact Information Section ---
            _buildSectionHeader(accentColor, "Contact Information"),
            const SizedBox(height: 16),
            _buildTextField(surfaceColor, textGray, accentColor, 
              icon: Icons.person, hint: "Customer Name *", isMandatory: true),
            const SizedBox(height: 16),
            _buildTextField(surfaceColor, textGray, accentColor, 
              icon: Icons.phone, hint: "Phone Number", inputType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(surfaceColor, textGray, accentColor, 
              icon: Icons.email, hint: "Email Address", inputType: TextInputType.emailAddress),
            const SizedBox(height: 30),

            // --- 3. Address Section ---
            _buildSectionHeader(accentColor, "Address"),
            const SizedBox(height: 16),
            _buildTextField(surfaceColor, textGray, accentColor, 
              icon: Icons.location_on, hint: "Address", maxLines: 3),
            const SizedBox(height: 30),

            // --- 4. Business Information Section ---
            _buildSectionHeader(accentColor, "Business Information"),
            const SizedBox(height: 16),
            _buildTextField(surfaceColor, textGray, accentColor, 
              icon: Icons.receipt, hint: "GST Number"),
            const SizedBox(height: 16),
            _buildTextField(surfaceColor, textGray, accentColor, 
              icon: Icons.note, hint: "Notes", maxLines: 3),
            const SizedBox(height: 40),

            // --- 5. Bottom Add Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: accentColor.withOpacity(0.4),
                ),
                icon: const Icon(Icons.person_add, color: Colors.black),
                label: const Text(
                  "Add Customer",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Section Header with Vertical Bar ---
  Widget _buildSectionHeader(Color accentColor, String title) {
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

  // --- Helper Widget: Custom Text Field ---
  Widget _buildTextField(Color surfaceColor, Color hintColor, Color accentColor, {
    required IconData icon,
    required String hint,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool isMandatory = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(icon, color: hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

