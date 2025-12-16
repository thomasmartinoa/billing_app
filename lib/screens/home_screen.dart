import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Color(0xFF00C59E)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Color(0xFF00C59E)),
            onPressed: () {},
          )
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TOP CARDS
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.people,
                      value: "0",
                      title: "Customers",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.inventory_2_outlined,
                      value: "0",
                      title: "Products",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.shopping_cart,
                      value: "0",
                      title: "Sales",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.warning_amber_rounded,
                      value: "0",
                      title: "Low Stock",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                      child: QuickButton(
                        icon: Icons.shopping_cart,
                        title: "New Invoice",
                        onTap: () {
                          // Navigate to New Invoice screen
                        },
                      )),
                  SizedBox(width: 12),
                  Expanded(
                      child: QuickButton(
                        icon: Icons.add_box,
                        title: "Add Product",
                        onTap: () {
                          // Navigate to Add Product screen
                        },
                      )),
                  SizedBox(width: 12),
                  Expanded(
                      child: QuickButton(
                        icon: Icons.person_add,
                        title: "Add Customer",
                        onTap: () {
                          // Navigate to Add Customer screen
                        },
                      )),
                ],
              ),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Invoices",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF00C59E)),
                  )
                ],
              ),

              SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0x14181818),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF12332D).withValues(alpha: 0.6)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white24, size: 45),
                    SizedBox(height: 10),
                    Text("No invoices yet", style: TextStyle(color: Colors.white60)),
                    SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: Color(0xFF00C59E)),
                      label: Text("Create First Invoice",
                          style: TextStyle(color: Color(0xFF00C59E))),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text("New Invoice", style: TextStyle(color: Colors.black)),
        icon: Icon(Icons.add, color: Colors.black),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF07100F),
        selectedItemColor: Color(0xFF00C59E),
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoices"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
        ],
      ),
    );
  }
}

// -------------------- WIDGETS -----------------------

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  DashboardCard({required this.icon, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x14181818),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF12332D).withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF00C59E)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class QuickButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0x14181818),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF12332D).withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF00C59E), size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
