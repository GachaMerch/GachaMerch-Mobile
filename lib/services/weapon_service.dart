import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String _prodUrl = 'https://gachamerch-be.drian.my.id/api';
const String _devUrl = 'http://10.0.2.2:3000/api';
String get _baseUrl => kReleaseMode ? _prodUrl : _devUrl;

class WeaponService {
  static Future<Map<String, dynamic>> getWeapons({int page = 1, int limit = 8}) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/weapons?page=$page&limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return {
        'weapons': data['data'] as List<dynamic>,
        'totalPages': data['pagination']['totalPages'] as int,
      };
    }
    throw Exception(data['message'] ?? 'Failed to fetch weapons');
  }
}
