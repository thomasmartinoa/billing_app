import 'package:flutter/material.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Customers",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.filter_list,
                    color: accentColor,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 2. Search Bar ---
              TextField(
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceColor,
                  hintText: "Search customers...",
                  hintStyle: const TextStyle(color: textGray),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // --- 3. Empty State (Centered) ---
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular Icon Background
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline, // Person icon for customers
                            size: 48,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        "No customers yet",
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      const Text(
                        "Add your first customer to get started",
                        style: TextStyle(
                          color: textGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Wide "+ Add Customer" Button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Link to Add Customer Screen later
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Add Customer",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // --- Floating Action Button ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// --- TEMPORARY TEST CODE (Delete before committing) ---
void main() {
  runApp(const MaterialApp(
    home: CustomerListScreen(), // <--- I changed this for you
    debugShowCheckedModeBanner: false, 
  ));
}
