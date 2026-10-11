import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'admin_menu_page.dart';
import 'login_page.dart';
import 'student_order_pages.dart';

class ShopSelectionPage extends StatefulWidget {
  final String customerName;
  final bool adminMode;
  final int? adminId;
  final String? adminUsername;
  final String? adminPhone;

  const ShopSelectionPage({
    super.key,
    this.customerName = 'Student',
    this.adminMode = false,
    this.adminId,
    this.adminUsername,
    this.adminPhone,
  });

  @override
  State<ShopSelectionPage> createState() => _ShopSelectionPageState();
}

class _ShopSelectionPageState extends State<ShopSelectionPage> {
  late Future<List<Map<String, dynamic>>> _shops;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  void _fetchShops() {
    if (widget.adminMode) {
      _shops = ApiService.getShops(
        adminId: widget.adminId,
        ownerPhone: widget.adminPhone,
        ownerName: widget.adminUsername,
      );
    } else {
      _shops = ApiService.getShops();
    }
  }

  IconData _shopIcon(Map<String, dynamic> shop) {
    final type = shop['location_type']?.toString().toLowerCase() ?? '';
    if (type.contains('cafe') || type.contains('coffee')) {
      return Icons.local_cafe;
    }
    if (type.contains('food')) return Icons.store;
    return Icons.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0D9488);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant),
            SizedBox(width: 10),
            Text('Smart Canteen'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const Icon(Icons.account_circle),
                const SizedBox(width: 5),
                Text(widget.adminMode ? 'Admin Portal' : 'Student Portal'),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.adminMode ? 'Your Canteen' : 'Choose a Canteen',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.adminMode
                      ? 'Manage menu items, incoming orders, and shop details for your canteen.'
                      : 'Select the shop or canteen from which you want to order food.',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 25),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _shops,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          Text('Could not load shops: ${snapshot.error}'),
                          TextButton(
                            onPressed: () =>
                                setState(() => _fetchShops()),
                            child: const Text('Retry'),
                          ),
                        ],
                      );
                    }
                    final shops = snapshot.data ?? const [];
                    if (shops.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            widget.adminMode
                                ? 'No shop registered for this admin account yet.'
                                : 'No shops have been registered yet.',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: <Widget>[
                        ...shops.map<Widget>((shop) {
                          final isAvailable = shop['is_open'] == true;
                          final shopName = shop['name']?.toString() ?? 'Shop';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            elevation: 1,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F4F1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _shopIcon(shop),
                                      color: teal,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          shopName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                shop['location']?.toString() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          isAvailable ? 'Open' : 'Closed',
                                          style: TextStyle(
                                            color: isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: widget.adminMode || isAvailable
                                        ? () {
                                            final page = widget.adminMode
                                                ? AdminMenuPage(
                                                    shopId: shop['id'] as int,
                                                    initialShopName: shopName,
                                                    initialLocation:
                                                        shop['location']
                                                            ?.toString() ??
                                                        '',
                                                  )
                                                : CanteenHomePage(
                                                    shopId: shop['id'] as int,
                                                    shopName: shopName,
                                                    customerName:
                                                        widget.customerName,
                                                  );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => page,
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: teal,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      widget.adminMode
                                          ? 'Manage Shop'
                                          : 'View Menu',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
