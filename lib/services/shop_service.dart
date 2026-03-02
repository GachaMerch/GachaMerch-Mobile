import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String _prodUrl = 'https://gachamerch-be.drian.my.id/api';
const String _devUrl = 'http://10.0.2.2:3000/api';
String get _baseUrl => kReleaseMode ? _prodUrl : _devUrl;

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
