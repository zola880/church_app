import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  static const String _sessionKey = 'current_user_id';

  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isSessionRestored = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSessionRestored => _isSessionRestored;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isRegistered => _currentUser != null;

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_sessionKey);

      if (userId != null) {
        final user = await _authService.getUserById(userId);
        if (user != null && user.isActive) {
          _currentUser = user;
        } else {
          await prefs.remove(_sessionKey);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isSessionRestored = true;
    notifyListeners();
  }

  Future<void> registerUser({
    required String name,
    required int age,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.registerUser(
        name: name,
        age: age,
        phoneNumber: phoneNumber,
      );
      _currentUser = user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, user.id);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.getUserById(userId);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
