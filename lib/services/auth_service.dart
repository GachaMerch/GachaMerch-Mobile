import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _prodUrl = 'https://gachamerch-be.drian.my.id/api';
const String _devUrl = 'http://10.0.2.2:3000/api';
String get _baseUrl => kReleaseMode ? _prodUrl : _devUrl;

class AuthService {
  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      final d = data['data'];
      if (d is! Map) throw Exception('Invalid response from server');
      final map = Map<String, dynamic>.from(d);
      await _saveToken(map['token']?.toString() ?? '');
      return map;
    }
    throw Exception(data['message'] ?? 'Google auth failed');
  }

  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 && data['success'] == true) {
      final d = data['data'];
      if (d is! Map) throw Exception('Invalid response from server');
      final map = Map<String, dynamic>.from(d);
      await _saveToken(map['token']?.toString() ?? '');
      return map;
    }
    throw Exception(data['message'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login(
      String usernameOrEmail, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usernameOrEmail': usernameOrEmail, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      final d = data['data'];
      if (d is! Map) throw Exception('Invalid response from server');
      final map = Map<String, dynamic>.from(d);
      await _saveToken(map['token']?.toString() ?? '');
      return map;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    String? password,
  }) async {
    final token = await getToken();
    final body = <String, dynamic>{'username': username};
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    final res = await http.patch(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      final d = data['data'];
      if (d is! Map) throw Exception('Invalid response from server');
      return Map<String, dynamic>.from(d);
    }
    throw Exception(data['message'] ?? 'Update failed');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      final d = data['data'];
      if (d is! Map) throw Exception('Invalid response from server');
      return Map<String, dynamic>.from(d);
    }
    throw Exception(data['message'] ?? 'Failed to fetch user');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
