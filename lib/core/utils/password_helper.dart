import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Classe utilitaire pour le hachage des mots de passe
class PasswordHelper {
  /// Hash un mot de passe avec SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Vérifie si un mot de passe correspond au hash
  static bool verifyPassword(String password, String hashedPassword) {
    final hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }
  
  /// Génère un token aléatoire pour la réinitialisation du mot de passe
  static String generateResetToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + DateTime.now().microsecond.toString();
    return hashPassword(random);
  }
}
