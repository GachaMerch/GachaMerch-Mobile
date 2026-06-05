import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import 'auth_service.dart';

String get _baseUrl => backendApiBaseUrl;

class InventoryService {
  static Future<List<dynamic>> getInventory() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/inventory'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      final d = data['data'];
      if (d is! List) throw Exception('Invalid response from server');
      return List<dynamic>.from(d);
    }
    throw Exception(data['message'] ?? 'Failed to fetch inventory');
  }
}
