import 'package:flutter/material.dart';

import '../services/api_service.dart';

void main() {
  runApp(const SmartCanteenApp());
}

class MenuItemModel {
  final int id;
  final String name;
  final String category;
  final double price;
  final int quantity;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
  });
}

class CartItemModel {
  final MenuItemModel item;
  int quantity;

  CartItemModel({required this.item, required this.quantity});
}

class OrderModel {
  final String token;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;

  OrderModel({
    required this.token,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
  });
}

class SmartCanteenApp extends StatelessWidget {
  const SmartCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
        ),
      ),
      home: const CanteenHomePage(),
    );
  }
}

typedef StudentOrderPage = CanteenHomePage;

class CanteenHomePage extends StatefulWidget {
  final int shopId;
  final String shopName;
  final String customerName;

  const CanteenHomePage({
    super.key,
    this.shopId = 1,
    this.shopName = 'KIT Main Canteen',
    this.customerName = 'Student',
  });

  @override
  State<CanteenHomePage> createState() => _CanteenHomePageState();
}

class _CanteenHomePageState extends State<CanteenHomePage> {
  final List<MenuItemModel> adminMenu = [];

  final Map<int, int> _cart = {};

  OrderModel? _activeOrder;
  bool _loadingMenu = true;
  String? _menuError;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _loadingMenu = true;
      _menuError = null;
    });
    try {
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final items = await ApiService.getMenuItems(
        widget.shopId,
        dayOfWeek: days[DateTime.now().weekday - 1],
      );
      if (!mounted) return;
      setState(() {
        adminMenu
          ..clear()
          ..addAll(
            items.map((item) {
              return MenuItemModel(
                id: item['id'] as int,
                name: item['name']?.toString() ?? '',
                category: item['category']?.toString() ?? '',
                price: (item['price'] as num).toDouble(),
                quantity: item['quantity'] as int? ?? 0,
              );
            }),
          );
        _loadingMenu = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _menuError = error.toString().replaceFirst('Exception: ', '');
        _loadingMenu = false;
      });
    }
  }

  void _increaseQty(int itemId) {
    final item = adminMenu.firstWhere((entry) => entry.id == itemId);
    if ((_cart[itemId] ?? 0) >= item.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more stock is available.')),
      );
      return;
    }
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
  }

  void _decreaseQty(int itemId) {
    setState(() {
      if (_cart.containsKey(itemId)) {
        if (_cart[itemId]! > 1) {
          _cart[itemId] = _cart[itemId]! - 1;
        } else {
          _cart.remove(itemId);
        }
      }
    });
  }

  void _removeFromCart(int itemId) {
    setState(() {
      _cart.remove(itemId);
    });
  }

  double get _cartTotal {
    double total = 0;

    _cart.forEach((id, qty) {
      final item = adminMenu.firstWhere((element) => element.id == id);

      total += item.price * qty;
    });

    return total;
  }

  // ----------------------------------------------------------
  // PAYMENT
  // ----------------------------------------------------------

  void _openPaymentDialog() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Payment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 50,
                color: Color(0xFF0D9488),
              ),

              const SizedBox(height: 15),

              const Text(
                'Payment is simulated; this app will not charge you.',
                style: TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.qr_code, color: Color(0xFF0D9488)),
                title: const Text('UPI'),
                subtitle: const Text('Pay using UPI'),
                onTap: () {
                  Navigator.pop(context);
                  _submitOrder('UPI');
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.credit_card,
                  color: Color(0xFF0D9488),
                ),
                title: const Text('Card'),
                subtitle: const Text('Debit / Credit Card'),
                onTap: () {
                  Navigator.pop(context);
                  _submitOrder('Card');
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.account_balance,
                  color: Color(0xFF0D9488),
                ),
                title: const Text('Net Banking'),
                subtitle: const Text('Pay using Net Banking'),
                onTap: () {
                  Navigator.pop(context);
                  _submitOrder('Net Banking');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // Orders use the backend; no payment provider is connected.
  // ----------------------------------------------------------

  Future<void> _submitOrder(String paymentMethod) async {
    if (_cart.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Submitting order...'),
            ],
          ),
        );
      },
    );

    try {
      final orderedItems = _cart.entries.map((entry) {
        final item = adminMenu.firstWhere(
          (menuItem) => menuItem.id == entry.key,
        );
        return CartItemModel(item: item, quantity: entry.value);
      }).toList();
      final result = await ApiService.placeOrder(
        shopId: widget.shopId,
        customerName: widget.customerName,
        paymentMethod: paymentMethod,
        items: _cart.entries
            .map(
              (entry) => {'menu_item_id': entry.key, 'quantity': entry.value},
            )
            .toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _activeOrder = OrderModel(
          token: result['token']?.toString() ?? '',
          items: orderedItems,
          totalAmount: (result['total_amount'] as num).toDouble(),
          status: result['status']?.toString() ?? 'pending',
          paymentStatus: result['payment_status']?.toString() ?? 'pending',
        );
        _cart.clear();
      });
      await _loadMenu();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Order placed. Payment is pending; no charge was made.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D9488),
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              widget.shopName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.account_circle, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Student Portal',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(20.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ------------------------------------------------
                // MENU
                // ------------------------------------------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Today's Menu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      'Updated by Admin',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),

                  child: _loadingMenu
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _menuError != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text('Could not load menu: $_menuError'),
                              TextButton(
                                onPressed: _loadMenu,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : adminMenu.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text('No menu items are available.'),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),

                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),

                            itemCount: adminMenu.length,

                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),

                            itemBuilder: (context, index) {
                              final item = adminMenu[index];

                              final qty = _cart[item.id] ?? 0;

                              return Padding(
                                padding: const EdgeInsets.all(12.0),

                                child: Row(
                                  children: [
                                    Text(
                                      '${index + 1}. ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF1F5F9,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),

                                                child: Text(
                                                  item.category,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            '₹${item.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Color(0xFF0D9488),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    qty == 0
                                        ? ElevatedButton.icon(
                                            onPressed: item.quantity > 0
                                                ? () => _increaseQty(item.id)
                                                : null,

                                            icon: const Icon(
                                              Icons.add,
                                              size: 16,
                                            ),

                                            label: Text(
                                              item.quantity > 0
                                                  ? 'Add'
                                                  : 'Sold out',
                                            ),

                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0D9488,
                                              ),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),

                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                  ),
                                                  onPressed: () =>
                                                      _decreaseQty(item.id),
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                ),

                                                Text(
                                                  '$qty',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                  onPressed: () =>
                                                      _increaseQty(item.id),
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // CART
                // ------------------------------------------------
                const Text(
                  'Your Cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: _cart.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'Your cart is currently empty.',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),

                                itemCount: _cart.length,

                                separatorBuilder: (context, index) =>
                                    const Divider(color: Color(0xFFE2E8F0)),

                                itemBuilder: (context, index) {
                                  final itemId = _cart.keys.elementAt(index);

                                  final qty = _cart[itemId]!;

                                  final item = adminMenu.firstWhere(
                                    (element) => element.id == itemId,
                                  );

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            Text(
                                              '₹${item.price.toStringAsFixed(0)} each',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),

                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 14,
                                                  ),
                                                  onPressed: () =>
                                                      _decreaseQty(item.id),
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 28,
                                                        minHeight: 28,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                ),

                                                Text(
                                                  '$qty',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 14,
                                                  ),
                                                  onPressed: () =>
                                                      _increaseQty(item.id),
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 28,
                                                        minHeight: 28,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Text(
                                            '₹${(item.price * qty).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _removeFromCart(item.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const Divider(
                                thickness: 2,
                                color: Color(0xFFF1F5F9),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),

                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      '₹${_cartTotal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // PAYMENT BUTTON
                              SizedBox(
                                width: double.infinity,

                                child: ElevatedButton.icon(
                                  onPressed: _openPaymentDialog,

                                  icon: const Icon(Icons.payment),

                                  label: const Text(
                                    'Proceed to Payment',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // ORDER / TOKEN
                // ------------------------------------------------
                if (_activeOrder != null) ...[
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24.0),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(12),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF34D399),
                          size: 40,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Order Placed Successfully!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text(
                          'Show this token number at the canteen counter',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.symmetric(vertical: 10),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white30),
                          ),

                          child: Text(
                            _activeOrder!.token,

                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF34D399),
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // PAYMENT STATUS
                        Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                'Payment:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                _activeOrder!.paymentStatus,

                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Ordered Items:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),

                              const Divider(color: Colors.white24),

                              ..._activeOrder!.items.map(
                                (cartItem) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),

                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${cartItem.item.name} (x${cartItem.quantity})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        '₹${(cartItem.item.price * cartItem.quantity).toStringAsFixed(0)}',

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const Divider(color: Colors.white38),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  const Text(
                                    'Total Paid:',
                                    style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  Text(
                                    '₹${_activeOrder!.totalAmount.toStringAsFixed(0)}',

                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                _activeOrder!.status,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
