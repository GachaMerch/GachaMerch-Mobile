import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import 'auth_service.dart';

String get _baseUrl => backendApiBaseUrl;

class ShopService {
  static Future<Map<String, dynamic>> getShopItems() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/shop'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to fetch shop items');
  }
}
