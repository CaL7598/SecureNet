import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import 'api_base_url.dart';

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? apiBaseUrl;

  final String _baseUrl;

  Future<NetworkAnalysis?> analyzeNetwork(List<DeviceScan> devices) async {
    try {
      final body = jsonEncode({
        'devices': devices.map((d) => d.toJson()).toList(),
        'scan_timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze-network'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return NetworkAnalysis.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> healthCheck() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/v1/health'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/password-reset/request'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/password-reset/confirm'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'code': code,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
