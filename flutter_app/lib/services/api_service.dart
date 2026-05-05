import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import 'api_base_url.dart';

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? apiBaseUrl;

  final String _baseUrl;
  static String? _globalBearerToken;
  static String? _globalRefreshToken;
  static bool _refreshInFlight = false;

  void setBearerToken(String? token) {
    _globalBearerToken = token;
  }

  void setRefreshToken(String? token) {
    _globalRefreshToken = token;
  }

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (_globalBearerToken != null && _globalBearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_globalBearerToken';
    }
    return headers;
  }

  Future<http.Response?> _authorizedRequest(
    Future<http.Response> Function() request, {
    bool canRefresh = true,
  }) async {
    try {
      final first = await request();
      if (first.statusCode != 401 || !canRefresh) return first;
      final refreshed = await refreshSession();
      if (refreshed == null) return first;
      final token = refreshed['access_token'] as String?;
      final refreshToken = refreshed['refresh_token'] as String?;
      if (token == null || refreshToken == null) return first;
      setBearerToken(token);
      setRefreshToken(refreshToken);
      return await request();
    } catch (_) {
      return null;
    }
  }

  Future<NetworkAnalysis?> analyzeNetwork(List<DeviceScan> devices) async {
    final body = jsonEncode({
      'devices': devices.map((d) => d.toJson()).toList(),
      'scan_timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    final res = await _authorizedRequest(
      () => http
          .post(
            Uri.parse('$_baseUrl/api/v1/analyze-network'),
            headers: _headers(),
            body: body,
          )
          .timeout(const Duration(seconds: 30)),
    );
    if (res == null || res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return NetworkAnalysis.fromJson(data);
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
            headers: _headers(),
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
            headers: _headers(),
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

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/register'),
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'password': password,
              'full_name': fullName,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/login'),
            headers: _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> refreshSession() async {
    if (_refreshInFlight) return null;
    final refresh = _globalRefreshToken;
    if (refresh == null || refresh.isEmpty) return null;
    try {
      _refreshInFlight = true;
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/refresh'),
            headers: _headers(),
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final parsed = jsonDecode(res.body) as Map<String, dynamic>;
      final token = parsed['access_token'] as String?;
      final refreshToken = parsed['refresh_token'] as String?;
      if (token != null && token.isNotEmpty) setBearerToken(token);
      if (refreshToken != null && refreshToken.isNotEmpty) setRefreshToken(refreshToken);
      return parsed;
    } catch (_) {
      return null;
    } finally {
      _refreshInFlight = false;
    }
  }

  Future<void> logout() async {
    final refresh = _globalRefreshToken;
    if (refresh == null || refresh.isEmpty) return;
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/logout'),
        headers: _headers(),
        body: jsonEncode({'refresh_token': refresh}),
      );
    } catch (_) {
      // best effort
    }
  }

  Future<Map<String, dynamic>?> me() async {
    final res = await _authorizedRequest(
      () => http
          .get(Uri.parse('$_baseUrl/api/v1/auth/me'), headers: _headers(json: false))
          .timeout(const Duration(seconds: 10)),
    );
    if (res == null || res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> updateProfile({
    required String fullName,
  }) async {
    final res = await _authorizedRequest(
      () => http
          .put(
            Uri.parse('$_baseUrl/api/v1/auth/profile'),
            headers: _headers(),
            body: jsonEncode({'full_name': fullName}),
          )
          .timeout(const Duration(seconds: 10)),
    );
    if (res == null || res.statusCode < 200 || res.statusCode >= 300) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/verify-email'),
            headers: _headers(),
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resendVerification(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/auth/resend-verification'),
            headers: _headers(),
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchScanHistory() async {
    final res = await _authorizedRequest(
      () => http
          .get(Uri.parse('$_baseUrl/api/v1/scan-history'), headers: _headers(json: false))
          .timeout(const Duration(seconds: 10)),
    );
    if (res == null || res.statusCode < 200 || res.statusCode >= 300) return null;
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
