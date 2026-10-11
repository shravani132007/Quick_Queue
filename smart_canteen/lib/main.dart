import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/shop_selection_page.dart';
import 'screens/student_order_pages.dart';
import 'screens/admin_menu_page.dart';
import 'screens/incoming_orders_pages.dart';
import 'screens/admin_shop_registration_page.dart';

void main() {
  runApp(const SmartCanteenApp());
}

class SmartCanteenApp extends StatelessWidget {
  const SmartCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Canteen',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),

      // First screen
      initialRoute: '/login',

      // All screens/routes
      routes: {
        '/login': (context) => const LoginPage(),

        '/shop-selection': (context) => const ShopSelectionPage(),

        '/student-order': (context) => const StudentOrderPage(),

        '/admin-menu': (context) => const AdminMenuPage(),

        '/incoming-orders': (context) => const IncomingOrdersPage(),

        '/admin-shop-registration': (context) =>
            const AdminShopRegistrationPage(),
      },
    );
  }
}