import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String _prodUrl = 'https://gachamerch-be.drian.my.id/api';
const String _devUrl = 'http://10.0.2.2:3000/api';
String get _baseUrl => kReleaseMode ? _prodUrl : _devUrl;

class WeaponService {
  static Future<void> createWeapon({
    required String title,
    required String type,
    required int rarity,
    required double price,
    required double baseAtk,
    double discount = 0,
    String subStat = '',
    String passiveName = '',
    String description = '',
    File? imageFile,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_baseUrl/weapons');
    final req = http.MultipartRequest('POST', uri);
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.fields['title']       = title;
    req.fields['type']        = type;
    req.fields['rarity']      = rarity.toString();
    req.fields['price']       = price.toString();
    req.fields['discount']    = discount.toString();
    req.fields['baseAtk']     = baseAtk.toString();
    req.fields['subStat']     = subStat;
    req.fields['passiveName'] = passiveName;
    req.fields['description'] = description;
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 && data['success'] == true) return;
    throw Exception(data['message'] ?? 'Failed to create weapon');
  }

  static Future<void> updateWeapon({
    required int weaponId,
    String? title,
    String? type,
    int? rarity,
    double? price,
    double? baseAtk,
    double? discount,
    String? subStat,
    String? passiveName,
    String? description,
    File? imageFile,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_baseUrl/weapons/$weaponId');
    final req = http.MultipartRequest('PUT', uri);
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    if (title != null)       req.fields['title']       = title;
    if (type != null)        req.fields['type']        = type;
    if (rarity != null)      req.fields['rarity']      = rarity.toString();
    if (price != null)       req.fields['price']       = price.toString();
    if (discount != null)    req.fields['discount']    = discount.toString();
    if (baseAtk != null)     req.fields['baseAtk']     = baseAtk.toString();
    if (subStat != null)     req.fields['subStat']     = subStat;
    if (passiveName != null) req.fields['passiveName'] = passiveName;
    if (description != null) req.fields['description'] = description;
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) return;
    throw Exception(data['message'] ?? 'Failed to update weapon');
  }

  static Future<void> deleteWeapon(int weaponId) async {
    final token = await AuthService.getToken();
    final res = await http.delete(
      Uri.parse('$_baseUrl/weapons/$weaponId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) return;
    throw Exception(data['message'] ?? 'Failed to delete weapon');
  }

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
