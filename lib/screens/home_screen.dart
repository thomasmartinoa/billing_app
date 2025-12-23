import 'package:flutter/material.dart';
import 'package:billing_app/services/firestore_service.dart';
import 'package:billing_app/services/auth_service.dart';
import 'package:billing_app/screens/prodscrn.dart';
import 'package:billing_app/screens/add_product_screen.dart';
import 'package:billing_app/screens/customer_list_screen.dart';
import 'package:billing_app/screens/add_customer_screen.dart';
import 'package:billing_app/screens/billing_screen.dart';
import 'package:billing_app/screens/create_invoice_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  Map<String, dynamic> _stats = {
    'customers': 0,
    'products': 0,
    'sales': 0,
    'lowStock': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _firestoreService.getDashboardStats();
      if (mounted) {
        setState(() => _stats = stats);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ProductListScreen();
      case 2:
        return const BillingScreen();
      case 3:
        return const CustomerListScreen();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Color(0xFF00C59E)),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Color(0xFF00C59E)),
                  onPressed: () {},
                )
              ],
            )
          : null,
      drawer: _buildDrawer(),
      body: _buildCurrentScreen(),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
                ).then((_) => _loadStats());
              },
              backgroundColor: Color(0xFF00C59E),
              label: Text("New Invoice", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              icon: Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF07100F),
        selectedItemColor: Color(0xFF00C59E),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFF0D0D0D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF141618),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF00C59E),
                  radius: 30,
                  child: Icon(Icons.store, color: Colors.black, size: 30),
                ),
                SizedBox(height: 10),
                Text(
                  'Billing App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFF00C59E)),
            title: Text('Sign Out', style: TextStyle(color: Colors.white)),
            onTap: () async {
              // Close drawer first
              Navigator.of(context).pop();
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(color: Color(0xFF00C59E)),
                ),
              );
              
              try {
                await _authService.signOut();
                // Pop loading dialog
                if (mounted) Navigator.of(context).pop();
                // The AuthWrapper will automatically navigate to WelcomePage
              } catch (e) {
                // Pop loading dialog
                if (mounted) Navigator.of(context).pop();
                // Show error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadStats,
        color: Color(0xFF00C59E),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
                      value: "${_stats['customers']}",
                      title: "Customers",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.inventory_2_outlined,
                      value: "${_stats['products']}",
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
                      value: "${_stats['sales']}",
                      title: "Sales",
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.warning_amber_rounded,
                      value: "${_stats['lowStock']}",
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
                          ).then((_) => _loadStats());
                        },
                      )),
                  SizedBox(width: 12),
                  Expanded(
                      child: QuickButton(
                        icon: Icons.add_box,
                        title: "Add Product",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddProductScreen()),
                          ).then((_) => _loadStats());
                        },
                      )),
                  SizedBox(width: 12),
                  Expanded(
                      child: QuickButton(
                        icon: Icons.person_add,
                        title: "Add Customer",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
                          ).then((_) => _loadStats());
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
                  GestureDetector(
                    onTap: () => _onNavTap(2),
                    child: Text(
                      "View All",
                      style: TextStyle(color: Color(0xFF00C59E)),
                    ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreateInvoiceScreen()),
                        ).then((_) => _loadStats());
                      },
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
