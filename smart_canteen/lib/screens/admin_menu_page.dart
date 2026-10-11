import 'package:flutter/material.dart';

import 'incoming_orders_pages.dart';
import 'login_page.dart';
import '../services/api_service.dart';

class AdminMenuItem {
  final int id;
  final String name;
  final String category;
  final double price;
  final String dayOfWeek;

  const AdminMenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.dayOfWeek,
  });
}

typedef AdminMenuPage = AdminDashboardScreen;

class AdminDashboardScreen extends StatefulWidget {
  final int shopId;
  final String initialShopName;
  final String initialLocation;

  const AdminDashboardScreen({
    super.key,
    this.shopId = 1,
    this.initialShopName = 'KIT Main Canteen',
    this.initialLocation = 'Main College Campus',
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const teal = Color(0xFF49E0E0);

  final _shopController = TextEditingController();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  int _selectedDay = 0;
  List<AdminMenuItem> _menuItems = [];
  bool _loading = true;
  bool _savingShop = false;
  String? _loadError;

  List<AdminMenuItem> get _currentMenu => _menuItems
      .where(
        (item) =>
            item.dayOfWeek == 'All' || item.dayOfWeek == _days[_selectedDay],
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _shopController.text = widget.initialShopName;
    _locationController.text = widget.initialLocation;
    _loadShopAndMenu();
  }

  Future<void> _loadShopAndMenu() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        ApiService.getShop(widget.shopId),
        ApiService.getMenuItems(widget.shopId),
      ]);
      if (!mounted) return;
      final shop = results[0]['shop'] as Map<String, dynamic>;
      final items = results[1] as List<Map<String, dynamic>>;
      setState(() {
        _shopController.text = shop['name']?.toString() ?? '';
        _locationController.text = shop['location']?.toString() ?? '';
        _menuItems = items.map((item) {
          return AdminMenuItem(
            id: item['id'] as int,
            name: item['name']?.toString() ?? '',
            category: item['category']?.toString() ?? '',
            price: (item['price'] as num).toDouble(),
            dayOfWeek: item['day_of_week']?.toString() ?? 'All',
          );
        }).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _shopController.dispose();
    _locationController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add item for ${_days[_selectedDay]}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Snacks, Meals, Beverages...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final category = _categoryController.text.trim();
              final price = double.tryParse(_priceController.text.trim());

              if (name.isEmpty ||
                  category.isEmpty ||
                  price == null ||
                  price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid item details.'),
                  ),
                );
                return;
              }

              try {
                await ApiService.addMenuItem(
                  shopId: widget.shopId,
                  name: name,
                  category: category,
                  price: price,
                  quantity: 50,
                  dayOfWeek: _days[_selectedDay],
                );
                if (!mounted) return;
                _nameController.clear();
                _categoryController.clear();
                _priceController.clear();
                await _loadShopAndMenu();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error.toString().replaceFirst('Exception: ', ''),
                    ),
                  ),
                );
              }
            },
            child: const Text('Add item'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveShopDetails() async {
    if (_shopController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop name and location cannot be empty.'),
        ),
      );
      return;
    }

    setState(() => _savingShop = true);
    try {
      await ApiService.updateShop(
        shopId: widget.shopId,
        name: _shopController.text.trim(),
        location: _locationController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Shop details saved.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingShop = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B2D),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF071B2D),
          elevation: 0,
          toolbarHeight: 72,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.restaurant_rounded, color: teal, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Quick Queue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: Colors.white,
                      iconSize: 26,
                    ),
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () {},
                      icon: const Icon(Icons.grid_view_rounded),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                    IconButton(
                      tooltip: 'Incoming orders',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                IncomingOrdersPage(shopId: widget.shopId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                    IconButton(
                      tooltip: 'Sign Out',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage your shop information and weekly menu',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D1E33),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFF49E0E0),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Shop Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1E33),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF1F5577)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shop name',
                              style: TextStyle(
                                color: Color(0xFFB7C8D8),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _shopController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF0D1E33),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2A4968),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2A4968),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF49E0E0),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                color: Color(0xFFB7C8D8),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _locationController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF0D1E33),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2A4968),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2A4968),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF49E0E0),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 64,
                        child: ElevatedButton.icon(
                          onPressed: _savingShop ? null : _saveShopDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF49E0E0),
                            foregroundColor: const Color(0xFF041d2e),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          icon: const Icon(Icons.store_mall_directory_rounded),
                          label: Text(
                            _savingShop ? 'Saving...' : 'Save shop details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D1E33),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Color(0xFF49E0E0),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Weekly Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage dishes by day',
                  style: TextStyle(color: Color(0xFFB7C8D8), fontSize: 20),
                ),
                const SizedBox(height: 18),
                Row(
                  children: List.generate(_days.length, (index) {
                    final selected = _selectedDay == index;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < _days.length - 1 ? 10 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedDay = index);
                          },
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF49E0E0)
                                  : const Color(0xFF0D1E33),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2A4968),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (selected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: Color(0xFF061B2D),
                                    ),
                                  ),
                                Text(
                                  _days[index],
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFF061B2D)
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_days[_selectedDay]} menu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddItemDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF49E0E0),
                        foregroundColor: const Color(0xFF061B2D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1E33),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF1F5577)),
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _loadError != null
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Could not load menu: $_loadError',
                                style: const TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: _loadShopAndMenu,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _currentMenu.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child: Text(
                              'No items added for this day yet.',
                              style: TextStyle(
                                color: Color(0xFFB7C8D8),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(_currentMenu.length, (index) {
                            final item = _currentMenu[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: index == _currentMenu.length - 1
                                        ? Colors.transparent
                                        : const Color(0xFF1F5577),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF49E0E0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.fastfood_rounded,
                                      color: Color(0xFF061B2D),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.category,
                                          style: const TextStyle(
                                            color: Color(0xFFB7C8D8),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '₹${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4D5A),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      tooltip: 'Delete item',
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        try {
                                          await ApiService.deleteMenuItem(
                                            item.id,
                                          );
                                          await _loadShopAndMenu();
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                error.toString().replaceFirst(
                                                  'Exception: ',
                                                  '',
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              IncomingOrdersPage(shopId: widget.shopId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF49E0E0),
                        width: 2,
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF49E0E0),
                    ),
                    label: const Text(
                      'View Incoming Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// This temporary page is replaced by the actual incoming orders screen
// in the next file below.
