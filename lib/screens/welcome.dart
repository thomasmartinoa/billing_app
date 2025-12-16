import 'package:flutter/material.dart';
import 'package:billing_app/screens/login.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17F1C5);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ..._buildFloatingIcons(primary),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary.withOpacity(0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary.withOpacity(0.15),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  size: 36,
                                  color: Color(0xFF17F1C5),
                                ),
                              ),

                              Positioned(
                                top: 0,
                                right: 10,
                                child: _SmallIcon(
                                  icon: Icons.attach_money,
                                  color: primary,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 5,
                                child: _SmallIcon(
                                  icon: Icons.trending_up,
                                  color: primary,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 0,
                                child: _SmallIcon(
                                  icon: Icons.calculate_outlined,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Welcome',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Fast, simple billing for your business',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: primary.withOpacity(0.5),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                          child: const Text(
                            'LETS GO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _buildFloatingIcons(Color primary) {
  final icons = [
    {'icon': Icons.receipt, 'top': 60.0, 'left': 30.0},
    {'icon': Icons.receipt_long, 'top': 120.0, 'right': 40.0},
    {'icon': Icons.calculate, 'top': 200.0, 'left': 50.0},
    {'icon': Icons.point_of_sale, 'bottom': 180.0, 'right': 30.0},
    {'icon': Icons.payments_outlined, 'bottom': 250.0, 'left': 35.0},
    {'icon': Icons.analytics_outlined, 'top': 300.0, 'right': 50.0},
  ];

  return icons.map((data) {
    return Positioned(
      top: data['top'] as double?,
      left: data['left'] as double?,
      right: data['right'] as double?,
      bottom: data['bottom'] as double?,
      child: Icon(
        data['icon'] as IconData,
        size: 40,
        color: primary.withOpacity(0.08),
      ),
    );
  }).toList();
}

class _SmallIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SmallIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
