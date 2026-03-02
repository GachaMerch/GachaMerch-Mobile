import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String _prodUrl = 'https://gachamerch-be.drian.my.id/api';
const String _devUrl = 'http://10.0.2.2:3000/api';
String get _baseUrl => kReleaseMode ? _prodUrl : _devUrl;

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
      return data['data'];
    }
    throw Exception(data['message'] ?? 'Purchase failed');
  }
}
