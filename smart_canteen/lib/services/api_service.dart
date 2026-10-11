import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) {
      final sanitized = configuredUrl.replaceFirst(RegExp(r'/+$'), '');
      if (sanitized.endsWith('/api')) {
        return sanitized;
      }
      return '$sanitized/api';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException(
        'Cannot connect to the server. Please ensure the backend is running.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Connection timed out. Please check your backend connection.',
      );
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('failed to fetch') ||
          msg.contains('socketexception') ||
          msg.contains('connection refused') ||
          msg.contains('network is unreachable')) {
        throw const ApiException(
          'Cannot connect to the server. Please ensure the backend is running.',
        );
      }
      throw ApiException(
        e.toString().replaceFirst(RegExp(r'^(Client)?Exception:\s*'), ''),
      );
    }
  }

  static Future<Map<String, dynamic>> _decodeResponse(
    http.Response response,
  ) async {
    Map<String, dynamic> decoded;
    try {
      final parsed = jsonDecode(response.body);
      if (parsed is Map<String, dynamic>) {
        decoded = parsed;
      } else {
        throw const FormatException(
          'The server returned an invalid response format.',
        );
      }
    } catch (_) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Request failed with status ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      throw const ApiException('The server returned an invalid response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded['error']?.toString() ??
            decoded['message']?.toString() ??
            'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String role,
  }) async {
    return _guard(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );
      return _decodeResponse(response);
    });
  }

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': 'user',
        }),
      );
      return _decodeResponse(response);
    });
  }

  static Future<List<Map<String, dynamic>>> getShops({
    int? adminId,
    String? ownerPhone,
    String? ownerName,
  }) async {
    return _guard(() async {
      final query = <String, String>{};
      if (adminId != null) query['admin_id'] = adminId.toString();
      if (ownerPhone != null && ownerPhone.isNotEmpty) {
        query['phone'] = ownerPhone;
      }
      if (ownerName != null && ownerName.isNotEmpty) {
        query['owner'] = ownerName;
      }

      final uri = Uri.parse('$baseUrl/shops').replace(
        queryParameters: query.isEmpty ? null : query,
      );
      final response = await http.get(uri);
      final data = await _decodeResponse(response);
      return List<Map<String, dynamic>>.from(
        data['shops'] as List? ?? const [],
      );
    });
  }

  static Future<Map<String, dynamic>> getShop(int shopId) async {
    return _guard(() async {
      final response = await http.get(Uri.parse('$baseUrl/shops/$shopId'));
      return _decodeResponse(response);
    });
  }

  static Future<Map<String, dynamic>> registerShop({
    required String shopNo,
    required String name,
    required String ownerName,
    required String contactNo,
    required String locationType,
    required String location,
    int? adminId,
  }) async {
    return _guard(() async {
      final body = <String, dynamic>{
        'shop_no': shopNo,
        'name': name,
        'owner_name': ownerName,
        'contact_no': contactNo,
        'location_type': locationType,
        'location': location,
      };
      if (adminId != null) body['admin_id'] = adminId;

      final response = await http.post(
        Uri.parse('$baseUrl/shops'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _decodeResponse(response);
    });
  }

  static Future<Map<String, dynamic>> updateShop({
    required int shopId,
    required String name,
    required String location,
  }) async {
    return _guard(() async {
      final response = await http.put(
        Uri.parse('$baseUrl/shops/$shopId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'location': location}),
      );
      return _decodeResponse(response);
    });
  }

  static Future<List<Map<String, dynamic>>> getMenuItems(
    int shopId, {
    String? category,
    String? dayOfWeek,
  }) async {
    return _guard(() async {
      final query = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        query['category'] = category;
      }
      if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
        query['day'] = dayOfWeek;
      }
      final uri = Uri.parse('$baseUrl/shops/$shopId/menu')
          .replace(queryParameters: query.isEmpty ? null : query);
      final response = await http.get(uri);
      final data = await _decodeResponse(response);
      return List<Map<String, dynamic>>.from(
        data['dishes'] as List? ?? const [],
      );
    });
  }

  static Future<Map<String, dynamic>> addMenuItem({
    required int shopId,
    required String name,
    required String category,
    required double price,
    required int quantity,
    String dayOfWeek = 'All',
  }) async {
    return _guard(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/shops/$shopId/menu'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'category': category,
          'price': price,
          'quantity': quantity,
          'day_of_week': dayOfWeek,
        }),
      );
      return _decodeResponse(response);
    });
  }

  static Future<Map<String, dynamic>> deleteMenuItem(int itemId) async {
    return _guard(() async {
      final response = await http.delete(Uri.parse('$baseUrl/menu/$itemId'));
      return _decodeResponse(response);
    });
  }

  static Future<Map<String, dynamic>> placeOrder({
    required int shopId,
    required String customerName,
    required List<Map<String, dynamic>> items,
    String paymentMethod = 'UPI',
  }) async {
    return _guard(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shop_id': shopId,
          'customer_name': customerName,
          'payment_method': paymentMethod,
          'items': items,
        }),
      );
      return _decodeResponse(response);
    });
  }

  static Future<List<Map<String, dynamic>>> getIncomingOrders(
    int shopId,
  ) async {
    return _guard(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/shops/$shopId/orders'),
      );
      final data = await _decodeResponse(response);
      return List<Map<String, dynamic>>.from(
        data['orders'] as List? ?? const [],
      );
    });
  }

  static Future<void> updateOrderStatus(int orderId, String status) async {
    return _guard(() async {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      await _decodeResponse(response);
    });
  }
}
