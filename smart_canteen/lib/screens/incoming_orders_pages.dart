import 'package:flutter/material.dart';

import '../services/api_service.dart';

void main() {
  runApp(const CanteenAdminDashboardApp());
}

enum OrderStatus { pending, accepted, preparing, ready, completed, rejected }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Received';
      case OrderStatus.accepted:
        return 'Accepted';
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
        return const Color(0xFFEFF6FF); // Soft Blue
      case OrderStatus.accepted:
        return const Color(0xFFF0FDFA); // Soft Teal
      case OrderStatus.preparing:
        return const Color(0xFFFFF7ED); // Soft Orange
      case OrderStatus.ready:
        return const Color(0xFFF0FDF4); // Soft Green
      case OrderStatus.rejected:
        return const Color(0xFFFEF2F2); // Soft Red
      case OrderStatus.completed:
        return const Color(0xFFF1F5F9); // Neutral Gray / Slate
    }
  }

  Color get borderColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFF93C5FD);
      case OrderStatus.accepted:
        return const Color(0xFF99F6E4);
      case OrderStatus.preparing:
        return const Color(0xFFFDBA74);
      case OrderStatus.ready:
        return const Color(0xFF86EFAC);
      case OrderStatus.rejected:
        return const Color(0xFFFCA5A5);
      case OrderStatus.completed:
        return const Color(0xFFCBD5E1);
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFF1D4ED8); // Deep Blue
      case OrderStatus.accepted:
        return const Color(0xFF0F766E); // Deep Teal
      case OrderStatus.preparing:
        return const Color(0xFFC2410C); // Deep Orange
      case OrderStatus.ready:
        return const Color(0xFF15803D); // Deep Green
      case OrderStatus.rejected:
        return const Color(0xFFB91C1C); // Deep Red
      case OrderStatus.completed:
        return const Color(0xFF475569); // Neutral Slate
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.inbox_rounded;
      case OrderStatus.accepted:
        return Icons.task_alt_rounded;
      case OrderStatus.preparing:
        return Icons.outdoor_grill_rounded;
      case OrderStatus.ready:
        return Icons.check_circle_rounded;
      case OrderStatus.rejected:
        return Icons.cancel_rounded;
      case OrderStatus.completed:
        return Icons.done_all_rounded;
    }
  }
}

class OrderItem {
  final String name;
  final int qty;
  final double price;

  const OrderItem({
    required this.name,
    required this.qty,
    required this.price,
  });
}

class AdminOrderModel {
  final int id;
  final String token;
  final String customerName;
  final String time;
  final String paymentStatus;
  final List<OrderItem> items;
  final double total;
  OrderStatus status;

  AdminOrderModel({
    required this.id,
    required this.token,
    this.customerName = 'Student',
    required this.time,
    this.paymentStatus = 'PAID',
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
        scaffoldBackgroundColor: const Color(0xFF17120A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD99100),
          primary: const Color(0xFFD99100),
        ),
      ),
      home: const AdminOrdersPage(),
    );
  }
}

typedef IncomingOrdersPage = AdminOrdersPage;

class AdminOrdersPage extends StatefulWidget {
  final int shopId;
  final String? shopName;

  const AdminOrdersPage({
    super.key,
    this.shopId = 1,
    this.shopName,
  });

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final List<AdminOrderModel> _activeOrders = [];
  bool _loadingOrders = true;
  String? _ordersError;
  String? _resolvedShopName;

  @override
  void initState() {
    super.initState();
    _resolvedShopName = widget.shopName;
    _loadOrders();
    _loadShopInfo();
  }

  Future<void> _loadShopInfo() async {
    if (_resolvedShopName != null && _resolvedShopName!.isNotEmpty) return;
    try {
      final data = await ApiService.getShop(widget.shopId);
      final shop = data['shop'] as Map<String, dynamic>?;
      if (mounted && shop != null) {
        setState(() {
          _resolvedShopName = shop['name']?.toString();
        });
      }
    } catch (_) {
      // Non-critical fallback
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loadingOrders = true;
      _ordersError = null;
    });
    try {
      final orders = await ApiService.getIncomingOrders(widget.shopId);
      if (!mounted) return;
      setState(() {
        _activeOrders
          ..clear()
          ..addAll(
            orders.map((order) {
              final createdAt = DateTime.tryParse(
                order['created_at']?.toString() ?? '',
              )?.toLocal();
              final time = createdAt == null
                  ? (order['created_at']?.toString() ?? '')
                  : '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
              final status = OrderStatus.values.firstWhere(
                (value) => value.name == order['status'],
                orElse: () => OrderStatus.pending,
              );
              final rawCustomer = order['customer_name']?.toString().trim();
              final customerName =
                  (rawCustomer != null && rawCustomer.isNotEmpty)
                      ? rawCustomer
                      : 'Student';
              final rawPayment =
                  order['payment_status']?.toString().toUpperCase() ?? 'PAID';

              final items = (order['items'] as List<dynamic>? ?? const []).map((
                item,
              ) {
                final entry = item as Map<String, dynamic>;
                return OrderItem(
                  name: entry['name']?.toString() ?? '',
                  qty: entry['qty'] as int? ?? 0,
                  price: (entry['price'] as num).toDouble(),
                );
              }).toList();
              return AdminOrderModel(
                id: order['id'] as int,
                token: order['token']?.toString() ?? '',
                customerName: customerName,
                time: time,
                paymentStatus: rawPayment,
                items: items,
                total: (order['total'] as num).toDouble(),
                status: status,
              );
            }),
          );
        _loadingOrders = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ordersError = error.toString().replaceFirst(
          RegExp(r'^(Client)?Exception:\s*'),
          '',
        );
        _loadingOrders = false;
      });
    }
  }

  int get _countPending =>
      _activeOrders.where((o) => o.status == OrderStatus.pending).length;
  int get _countPreparing =>
      _activeOrders.where((o) => o.status == OrderStatus.preparing).length;
  int get _countReady =>
      _activeOrders.where((o) => o.status == OrderStatus.ready).length;

  Future<void> _updateStatus(int index, OrderStatus newStatus) async {
    final order = _activeOrders[index];
    try {
      await ApiService.updateOrderStatus(order.id, newStatus.name);
      if (!mounted) return;
      setState(() => order.status = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order ${order.token} updated to ${newStatus.displayName}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: newStatus == OrderStatus.rejected
              ? const Color(0xFFDC2626)
              : const Color(0xFF15803D),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
              RegExp(r'^(Client)?Exception:\s*'),
              '',
            ),
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _confirmReject(int index) {
    final order = _activeOrders[index];
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF22190E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 10),
            Text(
              'Reject Order ${order.token}?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reject this order for ${order.customerName}?\nTotal: ₹${order.total.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Color(0xFFFFF3D1),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Keep Order',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _updateStatus(index, OrderStatus.rejected);
            },
            icon: const Icon(Icons.cancel_rounded, size: 16),
            label: const Text('Confirm Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD99100);
    const darkBackground = Color(0xFF17120A);
    final shopTitle = _resolvedShopName ?? 'Shop #${widget.shopId}';

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF261C0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: primaryColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Incoming Orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    shopTitle,
                    style: const TextStyle(
                      color: Color(0xFFFFF3D1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Orders',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadingOrders ? null : _loadOrders,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF17120A), Color(0xFF261C0D), Color(0xFF0F0B06)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
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
                              title: 'Received / Pending',
                              icon: Icons.inbox_rounded,
                              iconColor: const Color(0xFF1D4ED8),
                              badgeColor: const Color(0xFFEFF6FF),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? 16 : 0,
                            height: isWide ? 0 : 12,
                          ),
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: _buildMetricCard(
                              count: _countPreparing,
                              title: 'In Preparation',
                              icon: Icons.outdoor_grill_rounded,
                              iconColor: const Color(0xFFC2410C),
                              badgeColor: const Color(0xFFFFF7ED),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? 16 : 0,
                            height: isWide ? 0 : 12,
                          ),
                          Expanded(
                            flex: isWide ? 1 : 0,
                            child: _buildMetricCard(
                              count: _countReady,
                              title: 'Ready for Pickup',
                              icon: Icons.check_circle_rounded,
                              iconColor: const Color(0xFF15803D),
                              badgeColor: const Color(0xFFF0FDF4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Section Header & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Customer Orders',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and update token orders for $shopTitle',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFFF3D1),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _loadingOrders ? null : _loadOrders,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: const Color(0xFF17120A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Responsive Orders Content
                  if (_loadingOrders)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading incoming orders...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_ordersError != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22190E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 44,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Could not load orders: $_ordersError',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadOrders,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry Connection'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: const Color(0xFF17120A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_activeOrders.isEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 48,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22190E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: primaryColor,
                                size: 50,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'No Incoming Orders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'New customer orders placed for this canteen will appear here in real time.',
                              style: TextStyle(
                                color: Color(0xFFFFF3D1),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: _loadOrders,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Check for Updates'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white38),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final int columns =
                            maxWidth > 1000 ? 3 : (maxWidth > 650 ? 2 : 1);
                        const double spacing = 20.0;
                        final double cardWidth =
                            (maxWidth - (columns - 1) * spacing) / columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: _activeOrders.asMap().entries.map((entry) {
                            return SizedBox(
                              width: cardWidth,
                              child: _buildOrderTicket(
                                entry.value,
                                entry.key,
                                shopTitle,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
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
    required Color badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTicket(
    AdminOrderModel order,
    int index,
    String shopTitle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Head: Token & Status
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Token Badge: High contrast dark chip with white text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.token,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Status Badge: High contrast per requirement 5
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.badgeColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: order.status.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.status.icon,
                            size: 13,
                            color: order.status.textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.status.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: order.status.textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Customer info and timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.time,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Shop Name indicator
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shopTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCBD5E1), thickness: 1),

          // Order Items List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORDERED ITEMS (${order.items.length})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: order.paymentStatus == 'PAID'
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: order.paymentStatus == 'PAID'
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        'PAYMENT: ${order.paymentStatus}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: order.paymentStatus == 'PAID'
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of items
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  '${item.qty}x',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${(item.price * item.qty).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
                const SizedBox(height: 6),

                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '₹${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
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
          // Reject button (Red)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmReject(index),
              icon: const Icon(Icons.cancel_rounded, size: 16),
              label: const Text(
                'Reject Order',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Accept Order button (Green)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(index, OrderStatus.preparing),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const Text(
                'Accept Order',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    } else if (order.status == OrderStatus.accepted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _updateStatus(index, OrderStatus.preparing),
          icon: const Icon(Icons.outdoor_grill_rounded, size: 18),
          label: const Text(
            'Mark as Preparing',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706), // Orange
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    } else if (order.status == OrderStatus.preparing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _updateStatus(index, OrderStatus.ready),
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: const Text(
            'Mark as Ready',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D), // Positive Green
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    } else if (order.status == OrderStatus.ready) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _updateStatus(index, OrderStatus.completed),
          icon: const Icon(Icons.task_alt_rounded, size: 18),
          label: const Text(
            'Complete Pickup',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF334155), // Neutral Dark Slate
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Order Closed (${order.status.displayName})',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ),
      );
    }
  }
}
