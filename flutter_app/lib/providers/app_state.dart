import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool _showSplash = true;
  bool get showSplash => _showSplash;
  void finishSplash() {
    _showSplash = false;
    notifyListeners();
  }

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
