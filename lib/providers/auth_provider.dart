import 'package:flutter/foundation.dart';
import '../data/models/user.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'état d'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Initialise le provider en vérifiant la session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscrit un nouvel utilisateur
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        bio: bio,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Connecte un utilisateur
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    
    _isLoading = false;
    notifyListeners();
  }

  /// Met à jour le profil utilisateur
  Future<bool> updateProfile(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(user);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change le mot de passe
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        _currentUser!.id,
        oldPassword,
        newPassword,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Demande une réinitialisation de mot de passe
  Future<String?> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.requestPasswordReset(email);
      
      _isLoading = false;
      notifyListeners();
      return token;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Réinitialise le mot de passe
  Future<bool> resetPassword(String email, String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email, token, newPassword);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
