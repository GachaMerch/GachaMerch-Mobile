import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import 'auth_service.dart';

String get _baseUrl => backendApiBaseUrl;

class OrderService {
  static Future<Map<String, dynamic>> buyWeapon({
    required int weaponId,
    required int quantity,
  }) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl/order/buy'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'weaponId': weaponId, 'quantity': quantity}),
    );
    final data = jsonDecode(res.body);
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        data['success'] == true) {
      final d = data['data'];
      if (d is! Map) throw Exception('Invalid response from server');
      return Map<String, dynamic>.from(d);
    }
    throw Exception(data['message'] ?? 'Purchase failed');
  }
}
