import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/device.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  static const String _scanHistoryStorageKey = 'scan_history_v1';
  static const String _profileStorageKey = 'profile_v1';
  static const String _authStorageKey = 'auth_v1';

  AppState() {
    _loadPersistedState();
  }

  bool _showSplash = true;
  bool get showSplash => _showSplash;
  void finishSplash() {
    _showSplash = false;
    notifyListeners();
  }

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  bool _emailVerified = false;
  bool get emailVerified => _emailVerified;

  String _displayName = 'SecureNet User';
  String get displayName => _displayName;
  String _email = 'user@securenet.app';
  String get email => _email;
  String _phone = 'Not set';
  String get phone => _phone;
  String _location = 'Not set';
  String get location => _location;
  bool _scanConsentAccepted = false;
  bool get scanConsentAccepted => _scanConsentAccepted;
  String get initials {
    final parts = _displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'SN';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  List<ScanHistoryEntry> _scanHistory = [];
  List<ScanHistoryEntry> get scanHistory => List.unmodifiable(_scanHistory);
  int get scanCount => _scanHistory.length;
  NetworkAnalysis? get lastAnalysis => _scanHistory.isEmpty ? null : _scanHistory.first.analysis;
  DateTime? get lastScanAt => _scanHistory.isEmpty ? null : _scanHistory.first.scannedAt;
  void loginWithSession({
    required String token,
    String? refreshToken,
    required String email,
    String? displayName,
    bool emailVerified = false,
  }) {
    _accessToken = token;
    _refreshToken = refreshToken;
    _email = email;
    if (displayName != null && displayName.trim().isNotEmpty) {
      _displayName = displayName.trim();
    }
    _emailVerified = emailVerified;
    _isAuthenticated = true;
    _persistAuth();
    _persistProfile();
    notifyListeners();
  }

  void recordScan(NetworkAnalysis analysis) {
    _scanHistory = [
      ScanHistoryEntry(scannedAt: DateTime.now(), analysis: analysis),
      ..._scanHistory,
    ];
    _persistScanHistory();
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken = null;
    _emailVerified = false;
    _scanHistory = [];
    _scanConsentAccepted = false;
    _persistScanHistory();
    _persistAuth();
    notifyListeners();
  }

  Future<void> acceptScanConsent() async {
    _scanConsentAccepted = true;
    await _persistProfile();
    notifyListeners();
  }

  Future<void> setEmailVerified(bool value) async {
    _emailVerified = value;
    await _persistAuth();
    notifyListeners();
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required String phone,
    required String location,
  }) async {
    _displayName = displayName.trim().isEmpty ? 'SecureNet User' : displayName.trim();
    _email = email.trim().isEmpty ? 'user@securenet.app' : email.trim();
    _phone = phone.trim().isEmpty ? 'Not set' : phone.trim();
    _location = location.trim().isEmpty ? 'Not set' : location.trim();
    await _persistProfile();
    notifyListeners();
  }

  Future<void> _loadPersistedState() async {
    await _loadAuth();
    await _loadProfile();
    await _loadScanHistory();
  }

  Future<void> _loadAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_authStorageKey);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      _isAuthenticated = token != null && token.isNotEmpty;
      _accessToken = token;
      _refreshToken = data['refresh_token'] as String?;
      _emailVerified = data['email_verified'] == true;
      notifyListeners();
    } catch (_) {
      _isAuthenticated = false;
      _accessToken = null;
      _refreshToken = null;
      _emailVerified = false;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileStorageKey);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _displayName = (data['display_name'] as String?)?.trim().isNotEmpty == true
          ? (data['display_name'] as String).trim()
          : _displayName;
      _email = (data['email'] as String?)?.trim().isNotEmpty == true
          ? (data['email'] as String).trim()
          : _email;
      _phone = (data['phone'] as String?)?.trim().isNotEmpty == true
          ? (data['phone'] as String).trim()
          : _phone;
      _location = (data['location'] as String?)?.trim().isNotEmpty == true
          ? (data['location'] as String).trim()
          : _location;
      _scanConsentAccepted = data['scan_consent_accepted'] == true;
      notifyListeners();
    } catch (_) {
      // Keep defaults if parsing fails.
    }
  }

  Future<void> _loadScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_scanHistoryStorageKey);
      if (raw == null || raw.isEmpty) return;
      final parsed = jsonDecode(raw) as List<dynamic>;
      _scanHistory = parsed
          .map((e) => ScanHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      _scanHistory = [];
      notifyListeners();
    }
  }

  Future<void> _persistProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'display_name': _displayName,
        'email': _email,
        'phone': _phone,
        'location': _location,
        'scan_consent_accepted': _scanConsentAccepted,
      });
      await prefs.setString(_profileStorageKey, payload);
    } catch (_) {
      // Non-fatal; app still works without persistence.
    }
  }

  Future<void> _persistAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'access_token': _accessToken,
        'refresh_token': _refreshToken,
        'email_verified': _emailVerified,
      });
      await prefs.setString(_authStorageKey, payload);
    } catch (_) {
      // Non-fatal.
    }
  }

  Future<void> _persistScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode(_scanHistory.map((e) => e.toJson()).toList());
      await prefs.setString(_scanHistoryStorageKey, payload);
    } catch (_) {
      // Non-fatal; app still works without persistence.
    }
  }

  Future<void> syncProfileAndHistoryFromBackend(ApiService api) async {
    final me = await api.me();
    if (me != null) {
      _email = (me['email'] as String?) ?? _email;
      final fullName = (me['full_name'] as String?)?.trim();
      if (fullName != null && fullName.isNotEmpty) {
        _displayName = fullName;
      }
      _emailVerified = me['is_email_verified'] == true;
      await _persistProfile();
      await _persistAuth();
    }

    final history = await api.fetchScanHistory();
    if (history != null) {
      _scanHistory = history.map((row) {
        final scannedAtRaw = row['created_at'] as String?;
        final analysisRaw = row['analysis'] as Map<String, dynamic>? ?? const {};
        return ScanHistoryEntry(
          scannedAt: DateTime.tryParse(scannedAtRaw ?? '') ?? DateTime.now(),
          analysis: NetworkAnalysis.fromJson(analysisRaw),
        );
      }).toList();
      await _persistScanHistory();
    }
    notifyListeners();
  }
}
