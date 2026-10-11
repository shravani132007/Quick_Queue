import 'package:flutter_test/flutter_test.dart';
import 'package:smart_canteen/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('baseUrl default is non-empty and points to /api', () {
      final url = ApiService.baseUrl;
      expect(url.endsWith('/api'), isTrue);
      expect(url.contains('5000'), isTrue);
    });

    test('ApiException toString returns clean message', () {
      const exception = ApiException('Cannot connect to the server.');
      expect(exception.toString(), 'Cannot connect to the server.');
    });
  });
}
