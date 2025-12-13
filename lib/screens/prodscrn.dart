import 'package:flutter/material.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your specific colors here to match the design
    const Color backgroundColor = Colors.black;
    const Color surfaceColor = Color(0xFF1F1F1F); // Dark Gray for search bar
    const Color accentColor = Color(0xFF00E676); // Teal Green
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
              // --- 1. Header (Title + Icon) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Products",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.filter_list, // Closest match to the triangle/shapes icon
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
                  hintText: "Search products...",
                  hintStyle: const TextStyle(color: textGray),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // --- 3. Empty State (Centered Content) ---
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large Circular Icon Background
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.inventory_2_outlined, // Box icon
                            size: 48,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      const Text(
                        "No products yet",
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        "Add your first product to get started",
                        style: TextStyle(
                          color: textGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Wide "+ Add Product" Button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to Add Product Screen (Branch 4)
                            print("Navigate to Add Product"); 
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Add Product",
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

      // --- 4. Floating Action Button (Bottom Right) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Product Screen
        },
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// --- TEMPORARY TEST CODE (Delete before committing) ---
void main() {
  runApp(const MaterialApp(
    home: ProductListScreen(),
    debugShowCheckedModeBanner: false, // Removes the "Debug" banner
  ));
}