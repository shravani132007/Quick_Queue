import 'package:flutter/material.dart';
import 'shop_selection_page.dart';



// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedRole = 'user';
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchRole(String role) {
    setState(() {
      _selectedRole = role;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // CUSTOMER / USER LOGIN
      if (_selectedRole == 'user') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShopSelectionPage(),
          ),
        );
      }

      // ADMIN LOGIN
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logging in as ADMIN: ${_usernameController.text}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _selectedRole == 'admin';

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1600&auto=format&fit=crop',
            ),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: 380,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(217, 145, 0, 0.85),
                      Color.fromRGBO(89, 57, 0, 0.95),
                      Color.fromRGBO(31, 20, 0, 0.98),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // HERO IMAGE
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?q=80&w=800&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.1),
                              const Color.fromRGBO(217, 145, 0, 0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // LOGIN CONTENT
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'WELCOME',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              isAdmin
                                  ? 'Smart Canteen Admin Portal'
                                  : 'Your Smart Canteen Solution',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFFFF3D1),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ROLE TOGGLE
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildRoleButton(
                                      title: 'User',
                                      icon: Icons.person,
                                      isActive: !isAdmin,
                                      onTap: () =>
                                          _switchRole('user'),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildRoleButton(
                                      title: 'Admin',
                                      icon:
                                          Icons.admin_panel_settings,
                                      isActive: isAdmin,
                                      onTap: () =>
                                          _switchRole('admin'),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // LOGIN FORM
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    decoration: _inputDecoration(
                                      hintText: isAdmin
                                          ? 'Admin ID / Staff Email'
                                          : 'Email / Roll Number',
                                      icon: Icons.email,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'Please enter username or email';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    decoration: _inputDecoration(
                                      hintText: 'Password',
                                      icon: Icons.lock,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 8),

                                  // REMEMBER ME / FORGOT PASSWORD
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _rememberMe =
                                                        val ?? false;
                                                  });
                                                },
                                                fillColor:
                                                    WidgetStateProperty.all(
                                                  Colors.white24,
                                                ),
                                                checkColor: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Remember me',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),

                                        GestureDetector(
                                          onTap: () {},
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // SIGN IN BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding:
                                            const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // SIGN UP
                                  if (!isAdmin)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style:
                                            OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white70,
                                            width: 1.5,
                                          ),
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 30),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.white60,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
        size: 16,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(
          color: Colors.white,
        ),
      ),
    );
  }
}

// ============================================================
// SHOP MODEL
// ============================================================

class ShopModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isOpen;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isOpen,
  });
}

// ============================================================
// SHOP SELECTION PAGE
// ============================================================

class ShopSelectionPage extends StatelessWidget {
  const ShopSelectionPage({super.key});

  // TEMPORARY SHOP DATA
  // Later this will come from your backend/database.
  static const List<ShopModel> shops = [
    ShopModel(
      id: 1,
      name: 'Main Canteen',
      description: 'Meals, snacks and beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=800&auto=format&fit=crop',
      isOpen: true,
    ),
    ShopModel(
      id: 2,
      name: 'Snack Corner',
      description: 'Quick bites and snacks',
      imageUrl:
          'https://images.unsplash.com/photo-1621939514649-280e2aa3f6b1?q=80&w=800&auto=format&fit=crop',
      isOpen: true,
    ),
    ShopModel(
      id: 3,
      name: 'Food Court',
      description: 'Special meals and refreshments',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=800&auto=format&fit=crop',
      isOpen: true,
    ),
    ShopModel(
      id: 4,
      name: 'Juice Center',
      description: 'Fresh juices and cold beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1546173159-315724a31696?q=80&w=800&auto=format&fit=crop',
      isOpen: false,
    ),
  ];

  void _selectShop(
    BuildContext context,
    ShopModel shop,
  ) {
    if (!shop.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This shop is currently closed.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Temporary navigation.
    // Later this will open your actual Menu page.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedShopPage(
          shopId: shop.id,
          shopName: shop.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1600&auto=format&fit=crop',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.78),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),

                      const Expanded(
                        child: Text(
                          'SMART CANTEEN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // SHOP CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      10,
                      18,
                      30,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        const Text(
                          'CHOOSE YOUR SHOP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.3,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Select a canteen to explore today\'s menu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFFF3D1),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // SHOP CARDS
                        ...shops.map(
                          (shop) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: _buildShopCard(
                              context,
                              shop,
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
      ),
    );
  }

  Widget _buildShopCard(
    BuildContext context,
    ShopModel shop,
  ) {
    return GestureDetector(
      onTap: () => _selectShop(context, shop),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(217, 145, 0, 0.88),
              Color.fromRGBO(89, 57, 0, 0.95),
              Color.fromRGBO(31, 20, 0, 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: const Border.fromBorderSide(
            BorderSide(
              color: Colors.white24,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // SHOP IMAGE
            SizedBox(
              height: 145,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    shop.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF3A2700),
                        child: const Icon(
                          Icons.restaurant,
                          size: 55,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),

                  // IMAGE OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // OPEN/CLOSED BADGE
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: shop.isOpen
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 7,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            shop.isOpen
                                ? 'OPEN'
                                : 'CLOSED',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SHOP INFORMATION
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                14,
                14,
                14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          shop.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFFFFF3D1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: shop.isOpen
                          ? Colors.white
                          : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: shop.isOpen
                          ? Colors.black
                          : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TEMPORARY PAGE AFTER SHOP SELECTION
// ============================================================

class SelectedShopPage extends StatelessWidget {
  final int shopId;
  final String shopName;

  const SelectedShopPage({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopName),
      ),
      body: Center(
        child: Text(
          'Selected Shop:\n\n$shopName\n\nShop ID: $shopId',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}