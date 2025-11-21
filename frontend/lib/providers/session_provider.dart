import 'package:flutter/foundation.dart';
import '../services/auth_repository.dart';

class SessionProvider with ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  SessionProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _authRepo.getToken();
    if (token != null) {
      _isAuthenticated = true;
      _userId = await _authRepo.getUserId();
      _userEmail = await _authRepo.getUserEmail();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    final result = await _authRepo.login(email, password);
    if (result.success) {
      _isAuthenticated = true;
      _userId = result.user?['id']?.toString();
      _userEmail = result.user?['email']?.toString();
      notifyListeners();
      return true;
    } else {
      debugPrint('Login failed: ${result.error}');
    }
    return false;
  }

  Future<bool> signup(String email, String password) async {
    final result = await _authRepo.signup(email, password);
    if (result.success) {
      _isAuthenticated = true;
      _userId = result.user?['id']?.toString();
      _userEmail = result.user?['email']?.toString();
      notifyListeners();
      return true;
    } else {
      debugPrint('Signup failed: ${result.error}');
    }
    return false;
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }
}

