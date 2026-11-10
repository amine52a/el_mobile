import 'package:email_validator/email_validator.dart';
import '../constants/app_constants.dart';

/// Classe utilitaire pour la validation des formulaires
class Validators {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    if (!EmailValidator.validate(value)) {
      return 'Veuillez entrer un email valide';
    }
    
    return null;
  }
  
  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Le mot de passe ne peut pas dépasser ${AppConstants.maxPasswordLength} caractères';
    }
    
    // Vérifier la présence d'au moins une lettre majuscule
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre majuscule';
    }
    
    // Vérifier la présence d'au moins une lettre minuscule
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre minuscule';
    }
    
    // Vérifier la présence d'au moins un chiffre
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    return null;
  }
  
  /// Valide la confirmation du mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  /// Valide un nom (prénom ou nom de famille)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (value.length < AppConstants.minNameLength) {
      return '$fieldName doit contenir au moins ${AppConstants.minNameLength} caractères';
    }
    
    if (value.length > AppConstants.maxNameLength) {
      return '$fieldName ne peut pas dépasser ${AppConstants.maxNameLength} caractères';
    }
    
    // Vérifier que le nom ne contient que des lettres et des espaces
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
      return '$fieldName ne peut contenir que des lettres';
    }
    
    return null;
  }
  
  /// Valide un rôle utilisateur
  static String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le rôle est requis';
    }
    
    const validRoles = [
      AppConstants.roleStudent,
      AppConstants.roleMentor,
      AppConstants.roleAdmin,
      AppConstants.roleRecruiter,
    ];
    
    if (!validRoles.contains(value)) {
      return 'Rôle invalide';
    }
    
    return null;
  }
  
  /// Valide un champ requis générique
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
}
