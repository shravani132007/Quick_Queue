import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CanteenAdminDashboardApp());
}

enum OrderStatus { pending, preparing, ready, completed, rejected }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Color get badgeColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFFEF3C7);
      case OrderStatus.preparing:
        return const Color(0xFFDBEAFE);
      case OrderStatus.ready:
        return const Color(0xFFDCFCE7);
      case OrderStatus.completed:
        return const Color(0xFFF1F5F9);
      case OrderStatus.rejected:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFD97706);
      case OrderStatus.preparing:
        return const Color(0xFF2563EB);
      case OrderStatus.ready:
        return const Color(0xFF16A34A);
      case OrderStatus.completed:
        return const Color(0xFF64748B);
      case OrderStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }
}

class OrderItem {
  final String name;
  final int qty;
  final double price;

  OrderItem({
    required this.name,
    required this.qty,
    required this.price,
  });
}

class AdminOrderModel {
  final String token;
  final String time;
  final List<OrderItem> items;
  final double total;
  OrderStatus status;

  AdminOrderModel({
    required this.token,
    required this.time,
    required this.items,
    required this.total,
    required this.status,
  });
}

class CanteenAdminDashboardApp extends StatelessWidget {
  const CanteenAdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen Admin - Incoming Orders',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF1E293B),
        ),
      ),
      home: const AdminOrdersPage(),
    );
  }
}

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final List<AdminOrderModel> _activeOrders = [
    AdminOrderModel(
      token: '#TK-4829',
      time: '10:42 AM',
      items: [
        OrderItem(name: 'Veg Cheese Burger', qty: 2, price: 60),
        OrderItem(name: 'Cold Coffee', qty: 1, price: 40),
      ],
      total: 160,
      status: OrderStatus.pending,
    ),
    AdminOrderModel(
      token: '#TK-7310',
      time: '10:45 AM',
      items: [
        OrderItem(name: 'Paneer Butter Masala Meal', qty: 1, price: 120),
      ],
      total: 120,
      status: OrderStatus.preparing,
    ),
  ];

  int get _countPending =>
      _activeOrders.where((o) => o.status == OrderStatus.pending).length;
  int get _countPreparing =>
      _activeOrders.where((o) => o.status == OrderStatus.preparing).length;
  int get _countReady =>
      _activeOrders.where((o) => o.status == OrderStatus.ready).length;

  void _updateStatus(int index, OrderStatus newStatus) {
    setState(() {
      _activeOrders[index].status = newStatus;
    });
  }

  void _addSimulatedUserOrder() {
    final randomDigits = 1000 + Random().nextInt(9000);
    final now = TimeOfDay.now();
    final formattedTime =
        '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';

    setState(() {
      _activeOrders.insert(
        0,
        AdminOrderModel(
          token: '#TK-$randomDigits',
          time: formattedTime,
          items: [
            OrderItem(name: 'Masala Dosa', qty: 1, price: 50),
            OrderItem(name: 'Cold Coffee', qty: 1, price: 40),
          ],
          total: 90,
          status: OrderStatus.pending,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 4,
        title: const Row(
          children: [
            Icon(Icons.assignment, color: Color(0xFF38EF7D)),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Canteen Admin Dashboard',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Staff Portal',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Analytics Metrics Bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 650;
                    return Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      children: [
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: _buildMetricCard(
                            count: _countPending,
                            title: 'Pending Approval',
                            icon: Icons.access_time_filled,
                            iconColor: const Color(0xFFD97706),
                          ),
                        ),
                        SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 12),
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: _buildMetricCard(
                            count: _countPreparing,
                            title: 'In Kitchen',
                            icon: Icons.local_fire_department,
                            iconColor: const Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 12),
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: _buildMetricCard(
                            count: _countReady,
                            title: 'Ready for Pickup',
                            icon: Icons.notifications_active,
                            iconColor: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Section Header & Action Button
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    const Text(
                      'Incoming User Orders',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addSimulatedUserOrder,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Simulate Incoming User Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Responsive Orders Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    if (constraints.maxWidth > 900) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: crossAxisCount == 1 ? 1.2 : 0.95,
                      ),
                      itemCount: _activeOrders.length,
                      itemBuilder: (context, index) {
                        final order = _activeOrders[index];
                        return _buildOrderTicket(order, index);
                      },
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

  Widget _buildMetricCard({
    required int count,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Icon(icon, size: 32, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTicket(AdminOrderModel order, int index) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Order Head
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.token,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: order.status.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Order Items List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text.rich(
                                TextSpan(
                                  text: '${item.name} ',
                                  style: const TextStyle(fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: 'x${item.qty}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${(item.price * item.qty).toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: _buildActionButtons(order, index),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AdminOrderModel order, int index) {
    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(index, OrderStatus.rejected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Reject', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(index, OrderStatus.preparing),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Accept Order', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      );
    } else if (order.status == OrderStatus.preparing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(index, OrderStatus.ready),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text('Mark as Ready', style: TextStyle(fontSize: 12)),
        ),
      );
    } else if (order.status == OrderStatus.ready) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(index, OrderStatus.completed),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF475569),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text('Complete Pickup', style: TextStyle(fontSize: 12)),
        ),
      );
    } else {
      return Center(
        child: Text(
          'Order Closed (${order.status.displayName})',
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      );
    }
  }
}