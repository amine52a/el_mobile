import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/user.dart';
import '../data/repositories/user_repository.dart';
import '../core/constants/app_constants.dart';

/// Service d'authentification
class AuthService {
  final UserRepository _userRepository = UserRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Inscrit un nouvel utilisateur
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? bio,
  }) async {
    try {
      final user = await _userRepository.createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        bio: bio,
      );

      // Sauvegarder la session
      await _saveSession(user);

      return user;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  /// Connecte un utilisateur
  Future<User> login(String email, String password) async {
    try {
      final user = await _userRepository.authenticateUser(email, password);

      if (user == null) {
        throw Exception('Email ou mot de passe incorrect');
      }

      // Sauvegarder la session
      await _saveSession(user);

      return user;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.sessionKey);
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  /// Vérifie si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final sessionJson = await _secureStorage.read(key: AppConstants.sessionKey);
    return sessionJson != null;
  }

  /// Récupère l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    try {
      final sessionJson = await _secureStorage.read(key: AppConstants.sessionKey);
      if (sessionJson == null) return null;

      final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
      return User.fromJson(sessionMap);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde la session utilisateur
  Future<void> _saveSession(User user) async {
    final sessionJson = jsonEncode(user.toJson());
    await _secureStorage.write(
      key: AppConstants.sessionKey,
      value: sessionJson,
    );

    // Générer un token simple (dans une vraie app, utiliser JWT)
    final token = 'token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    await _secureStorage.write(
      key: AppConstants.tokenKey,
      value: token,
    );
  }

  /// Met à jour la session avec les nouvelles informations utilisateur
  Future<void> updateSession(User user) async {
    await _saveSession(user);
  }

  /// Demande une réinitialisation de mot de passe
  Future<String> requestPasswordReset(String email) async {
    try {
      final token = await _userRepository.generatePasswordResetToken(email);
      
      // Dans une vraie application, envoyer l'email ici
      // Pour le moment, on retourne juste le token
      print('Token de réinitialisation: $token');
      print('Email: $email');
      
      return token;
    } catch (e) {
      throw Exception('Erreur lors de la demande de réinitialisation: ${e.toString()}');
    }
  }

  /// Réinitialise le mot de passe
  Future<void> resetPassword(String email, String token, String newPassword) async {
    try {
      await _userRepository.resetPasswordWithToken(email, token, newPassword);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: ${e.toString()}');
    }
  }

  /// Change le mot de passe
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      await _userRepository.changePassword(userId, oldPassword, newPassword);
    } catch (e) {
      throw Exception('Erreur lors du changement de mot de passe: ${e.toString()}');
    }
  }

  /// Met à jour le profil utilisateur
  Future<User> updateProfile(User user) async {
    try {
      final updatedUser = await _userRepository.updateUser(user);
      await updateSession(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: ${e.toString()}');
    }
  }
}
