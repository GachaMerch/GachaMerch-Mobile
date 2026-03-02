import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String _prodUrl = 'https://gachamerch-be.drian.my.id/api';
const String _devUrl = 'http://10.0.2.2:3000/api';
String get _baseUrl => kReleaseMode ? _prodUrl : _devUrl;

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
