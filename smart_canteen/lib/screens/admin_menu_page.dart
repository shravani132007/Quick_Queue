import 'package:flutter/material.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin - Daily Menu Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        primaryColor: const Color(0xFF11998E),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class MenuItemModel {
  final String name;
  final String category;
  final double price;

  MenuItemModel({
    required this.name,
    required this.category,
    required this.price,
  });
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Shop Registration State
  final TextEditingController _shopNameController = TextEditingController();
  final _shopFormKey = GlobalKey<FormState>();
  String registeredShopName = '';
  bool isShopRegistered = false;

  String selectedDay = 'Monday';
  int selectedSidebarIndex = 0;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final Map<String, List<MenuItemModel>> weeklyMenu = {
    'Monday': [
      MenuItemModel(name: 'Veg Sandwich', category: 'Snacks', price: 40),
      MenuItemModel(name: 'Cold Coffee', category: 'Beverages', price: 50),
    ],
    'Tuesday': [
      MenuItemModel(name: 'Paneer Roll', category: 'Snacks', price: 70),
    ],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = 'Snacks';

  final List<String> categories = ['Snacks', 'Meals', 'Beverages'];

  @override
  void dispose() {
    _shopNameController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _registerShop() {
    if (_shopFormKey.currentState!.validate()) {
      setState(() {
        registeredShopName = _shopNameController.text.trim();
        isShopRegistered = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shop "$registeredShopName" saved successfully!'),
          backgroundColor: const Color(0xFF11998E),
        ),
      );
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        weeklyMenu[selectedDay]!.add(
          MenuItemModel(
            name: _nameController.text.trim(),
            category: _selectedCategory,
            price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          ),
        );
        _nameController.clear();
        _priceController.clear();
        _selectedCategory = 'Snacks';
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      weeklyMenu[selectedDay]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1E293B),
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                isShopRegistered ? registeredShopName : 'Admin Portal',
                style: const TextStyle(color: Color(0xFF38EF7D), fontSize: 18),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: _buildSidebar(),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isShopRegistered
                        ? '$registeredShopName Dashboard'
                        : 'Weekly Menu Manager',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Shop Registration Card / Banner
                  _buildShopRegistrationCard(),

                  const SizedBox(height: 25),
                  _buildDaysTabBar(),
                  const SizedBox(height: 25),
                  _buildFormCard(),
                  const SizedBox(height: 30),
                  _buildTableCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopRegistrationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isShopRegistered
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE6F4F1),
                      child: Icon(Icons.store, color: Color(0xFF11998E)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered Shop / Canteen Name',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          registeredShopName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      isShopRegistered = false;
                    });
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Name'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF11998E),
                    side: const BorderSide(color: Color(0xFF11998E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            )
          : Form(
              key: _shopFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register Your Shop Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your shop or canteen name to display across your menu and customer portal.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _shopNameController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Royal Canteen & Bakery',
                            prefixIcon: Icon(Icons.storefront),
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Please enter your shop name'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _registerShop,
                        icon: const Icon(Icons.check),
                        label: const Text('Save Shop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF11998E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: Color(0xFF38EF7D)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isShopRegistered ? registeredShopName : 'Admin Portal',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF38EF7D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSidebarItem(0, Icons.calendar_today, 'Daily Menus'),
          _buildSidebarItem(1, Icons.assignment, 'Manage Orders'),
          _buildSidebarItem(2, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final bool isActive = selectedSidebarIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedSidebarIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF334155) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map<Widget>((day) {
          final bool isActive = selectedDay == day;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    isActive ? const Color(0xFF11998E) : Colors.white,
                foregroundColor:
                    isActive ? Colors.white : const Color(0xFF333333),
                side: BorderSide(
                  color: isActive
                      ? const Color(0xFF11998E)
                      : const Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedDay = day;
                });
              },
              child: Text(day),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Item for $selectedDay',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Name', border: OutlineInputBorder()),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                        labelText: 'Category', border: OutlineInputBorder()),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                        labelText: 'Price', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (val) => double.tryParse(val ?? '') == null
                        ? 'Invalid'
                        : null,
                  ),
                ),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11998E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    final items = weeklyMenu[selectedDay] ?? [];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Action')),
        ],
        rows: List.generate(items.length, (index) {
          final item = items[index];
          return DataRow(cells: [
            DataCell(Text(item.name)),
            DataCell(Text(item.category)),
            DataCell(Text('₹${item.price.toStringAsFixed(0)}')),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteItem(index),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}