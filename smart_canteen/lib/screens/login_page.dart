import 'package:flutter/material.dart';

import 'admin_menu_page.dart';
import 'admin_shop_registration_page.dart';
import 'shop_selection_page.dart';
import '../services/api_service.dart';

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
  bool _isRegistering = false;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchRole(String role) {
    setState(() {
      _selectedRole = role;
      _isRegistering = false;
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await ApiService.registerUser(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        setState(() => _isRegistering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Please sign in.')),
        );
        return;
      }

      final result = await ApiService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
      if (!mounted) return;

      final user = result['user'] as Map<String, dynamic>?;
      final shop = result['shop'] as Map<String, dynamic>?;
      if (_selectedRole == 'admin') {
        if (shop != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminMenuPage(
                shopId: shop['id'] as int,
                initialShopName: shop['name']?.toString() ?? 'My Canteen',
                initialLocation: shop['location']?.toString() ?? '',
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ShopSelectionPage(
                adminMode: true,
                adminId: user?['id'] as int?,
                adminUsername: user?['username']?.toString(),
                adminPhone: user?['phone']?.toString(),
              ),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ShopSelectionPage(
              customerName:
                  user?['username']?.toString() ??
                  _usernameController.text.trim(),
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final raw = error.toString().replaceFirst(
        RegExp(r'^(Client)?Exception:\s*'),
        '',
      );
      final message = raw.toLowerCase().contains('failed to fetch')
          ? 'Cannot connect to the server. Please ensure the backend is running.'
          : raw;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _selectedRole == 'admin';

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFF17120A),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1600&auto=format&fit=crop',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => const SizedBox.expand(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.7),
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
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
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
                          color: const Color(0xFF593900),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?q=80&w=800&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.expand(),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.1),
                                      const Color.fromRGBO(217, 145, 0, 0.9),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
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
                                      : _isRegistering
                                      ? 'Create your student account'
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
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildRoleButton(
                                          title: 'User',
                                          icon: Icons.person,
                                          isActive: !isAdmin,
                                          onTap: () => _switchRole('user'),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildRoleButton(
                                          title: 'Admin',
                                          icon: Icons.admin_panel_settings,
                                          isActive: isAdmin,
                                          onTap: () => _switchRole('admin'),
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
                                              : 'Username',
                                          icon: Icons.email,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter username or email';
                                          }
                                          return null;
                                        },
                                      ),

                                      if (_isRegistering) ...[
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                          decoration: _inputDecoration(
                                            hintText: 'Email address',
                                            icon: Icons.alternate_email,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                !value.contains('@')) {
                                              return 'Enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],

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
                                          if (value == null || value.isEmpty) {
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

                                            Flexible(
                                              child: GestureDetector(
                                                onTap: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Password reset is not configured.',
                                                          ),
                                                        ),
                                                      );
                                                },
                                                child: Text(
                                                  'Forgot Password?',
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
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
                                          onPressed: _isLoading
                                              ? null
                                              : _handleSubmit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  _isRegistering
                                                      ? 'Create Account'
                                                      : 'Sign In',
                                                  style: const TextStyle(
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
                                            onPressed: () {
                                              setState(
                                                () => _isRegistering =
                                                    !_isRegistering,
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(
                                                color: Colors.white70,
                                                width: 1.5,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                            ),
                                            child: Text(
                                              _isRegistering
                                                  ? 'Back to Sign In'
                                                  : 'Create Account',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // REGISTER NEW SHOP FOR ADMIN
                                      if (isAdmin)
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const AdminShopRegistrationPage(),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.add_business_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Register New Shop / Canteen',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(
                                                color: Colors.white70,
                                                width: 1.5,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
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
          ],
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
      hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white70, size: 16),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.15),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}
