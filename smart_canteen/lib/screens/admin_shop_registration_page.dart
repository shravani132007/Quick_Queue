import 'package:flutter/material.dart';

import 'admin_menu_page.dart';
import '../services/api_service.dart';

class AdminShopRegistrationPage extends StatefulWidget {
  const AdminShopRegistrationPage({super.key});

  @override
  State<AdminShopRegistrationPage> createState() =>
      _AdminShopRegistrationPageState();
}

class _AdminShopRegistrationPageState extends State<AdminShopRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _shopNoController = TextEditingController(
    text: 'SHOP-01',
  );
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();

  String _selectedLocationType = 'Main Canteen';
  bool _isSubmitting = false;

  final List<String> _locationTypes = const [
    'Main Canteen',
    'Food Court',
    'Snack Corner',
    'Campus Cafe',
    'Juice Center',
  ];

  @override
  void dispose() {
    _shopNoController.dispose();
    _shopNameController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final result = await ApiService.registerShop(
        shopNo: _shopNoController.text.trim(),
        name: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        contactNo: _contactController.text.trim(),
        locationType: _selectedLocationType,
        location: _locationController.text.trim(),
      );
      if (!mounted) return;
      final shopId = result['shop_id'] as int;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shop "${_shopNameController.text.trim()}" registered successfully!',
          ),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );

      // Navigate to admin menu dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminMenuPage(
            shopId: shopId,
            initialShopName: _shopNameController.text.trim(),
            initialLocation: _locationController.text.trim(),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD99100);
    const darkBackground = Color(0xFF17120A);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Register Shop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF261C0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF17120A), Color(0xFF261C0D), Color(0xFF0F0B06)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: const Color(0xFF22190E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Shop Registration',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Enter details to register your canteen/shop',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 20),

                        // Shop Number
                        _buildLabel('Shop / Stall Number'),
                        TextFormField(
                          controller: _shopNoController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hintText: 'e.g. SHOP-01, STALL-A',
                            icon: Icons.tag,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter shop number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Shop Name
                        _buildLabel('Shop Name'),
                        TextFormField(
                          controller: _shopNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hintText: 'e.g. KIT Main Canteen',
                            icon: Icons.restaurant,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter shop name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Owner / Manager Name
                        _buildLabel('Owner / Manager Name'),
                        TextFormField(
                          controller: _ownerNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hintText: 'e.g. Ramesh Kumar',
                            icon: Icons.person,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter owner/manager name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Contact Number
                        _buildLabel('Contact Number'),
                        TextFormField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hintText: 'e.g. +91 98765 43210',
                            icon: Icons.phone,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter contact number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location Type
                        _buildLabel('Location Type'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLocationType,
                          dropdownColor: const Color(0xFF261C0D),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hintText: 'Select Location Type',
                            icon: Icons.category,
                          ),
                          items: _locationTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedLocationType = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location / Landmark
                        _buildLabel('Location / Campus Landmark'),
                        TextFormField(
                          controller: _locationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hintText:
                                'e.g. Near Engineering Block, Ground Floor',
                            icon: Icons.location_on,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              _isSubmitting
                                  ? 'Registering...'
                                  : 'Register & Continue to Menu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFFFC247), size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFC247), width: 1.5),
      ),
    );
  }
}
