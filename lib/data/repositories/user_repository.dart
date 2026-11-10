import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/password_helper.dart';

/// Repository pour gérer les opérations CRUD sur les utilisateurs
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Crée un nouveau compte utilisateur (F1.1.1 - Inscription)
  Future<User> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? bio,
    String? photo,
  }) async {
    final db = await _dbHelper.database;

    // Vérifier si l'email existe déjà
    final existing = await getUserByEmail(email);
    if (existing != null) {
      throw Exception('Un compte avec cet email existe déjà');
    }

    // Créer l'utilisateur
    final user = User(
      id: _uuid.v4(),
      email: email.toLowerCase().trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      role: role,
      bio: bio?.trim(),
      photo: photo,
      createdAt: DateTime.now(),
      isActive: true,
    );

    // Hash le mot de passe
    final hashedPassword = PasswordHelper.hashPassword(password);

    // Insérer dans la base de données
    final userMap = user.toMap();
    userMap['password'] = hashedPassword;

    await db.insert(
      AppConstants.usersTable,
      userMap,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    return user;
  }

  /// Récupère un utilisateur par email
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return User.fromMap(results.first);
  }

  /// Récupère un utilisateur par ID
  Future<User?> getUserById(String id) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return User.fromMap(results.first);
  }

  /// Authentifie un utilisateur (connexion)
  Future<User?> authenticateUser(String email, String password) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      AppConstants.usersTable,
      where: 'email = ? AND isActive = ?',
      whereArgs: [email.toLowerCase().trim(), 1],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final userMap = results.first;
    final hashedPassword = userMap['password'] as String;

    // Vérifier le mot de passe
    if (PasswordHelper.verifyPassword(password, hashedPassword)) {
      return User.fromMap(userMap);
    }

    return null;
  }

  /// Met à jour le profil utilisateur (F1.1.3 - Profil utilisateur)
  Future<User> updateUser(User user) async {
    final db = await _dbHelper.database;

    final updatedUser = user.copyWith(
      updatedAt: DateTime.now(),
    );

    await db.update(
      AppConstants.usersTable,
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return updatedUser;
  }

  /// Change le mot de passe d'un utilisateur (F1.1.4 - Changement de mot de passe)
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    final db = await _dbHelper.database;

    // Récupérer l'utilisateur
    final results = await db.query(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) {
      throw Exception('Utilisateur non trouvé');
    }

    final userMap = results.first;
    final currentHashedPassword = userMap['password'] as String;

    // Vérifier l'ancien mot de passe
    if (!PasswordHelper.verifyPassword(oldPassword, currentHashedPassword)) {
      throw Exception('Mot de passe actuel incorrect');
    }

    // Hasher le nouveau mot de passe
    final newHashedPassword = PasswordHelper.hashPassword(newPassword);

    // Mettre à jour le mot de passe
    await db.update(
      AppConstants.usersTable,
      {
        'password': newHashedPassword,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Génère un token de réinitialisation de mot de passe (F1.1.2 - Mot de passe oublié)
  Future<String> generatePasswordResetToken(String email) async {
    final db = await _dbHelper.database;

    // Vérifier si l'utilisateur existe
    final user = await getUserByEmail(email);
    if (user == null) {
      throw Exception('Aucun compte associé à cet email');
    }

    // Générer un token
    final token = PasswordHelper.generateResetToken();
    final expiry = DateTime.now().add(const Duration(hours: 1));

    // Stocker le token
    await db.update(
      AppConstants.usersTable,
      {
        'resetToken': token,
        'resetTokenExpiry': expiry.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return token;
  }

  /// Réinitialise le mot de passe avec un token (F1.1.2 - Mot de passe oublié)
  Future<void> resetPasswordWithToken(String email, String token, String newPassword) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      AppConstants.usersTable,
      where: 'email = ? AND resetToken = ?',
      whereArgs: [email.toLowerCase().trim(), token],
      limit: 1,
    );

    if (results.isEmpty) {
      throw Exception('Token invalide ou expiré');
    }

    final userMap = results.first;
    final expiryStr = userMap['resetTokenExpiry'] as String?;

    if (expiryStr == null) {
      throw Exception('Token invalide');
    }

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      throw Exception('Le token a expiré');
    }

    // Hasher le nouveau mot de passe
    final hashedPassword = PasswordHelper.hashPassword(newPassword);

    // Mettre à jour le mot de passe et supprimer le token
    await db.update(
      AppConstants.usersTable,
      {
        'password': hashedPassword,
        'resetToken': null,
        'resetTokenExpiry': null,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userMap['id']],
    );
  }

  /// Récupère tous les utilisateurs (F1.2.1 - CRUD Utilisateur)
  Future<List<User>> getAllUsers({String? role}) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results;

    if (role != null) {
      results = await db.query(
        AppConstants.usersTable,
        where: 'role = ? AND isActive = ?',
        whereArgs: [role, 1],
        orderBy: 'createdAt DESC',
      );
    } else {
      results = await db.query(
        AppConstants.usersTable,
        where: 'isActive = ?',
        whereArgs: [1],
        orderBy: 'createdAt DESC',
      );
    }

    return results.map((map) => User.fromMap(map)).toList();
  }

  /// Supprime un utilisateur (soft delete) (F1.2.1 - CRUD Utilisateur)
  Future<void> deleteUser(String userId) async {
    final db = await _dbHelper.database;

    await db.update(
      AppConstants.usersTable,
      {
        'isActive': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Supprime définitivement un utilisateur
  Future<void> hardDeleteUser(String userId) async {
    final db = await _dbHelper.database;

    await db.delete(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Compte le nombre d'utilisateurs par rôle (F1.2.3 - Gestion des rôles)
  Future<Map<String, int>> getUserCountByRole() async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT role, COUNT(*) as count
      FROM ${AppConstants.usersTable}
      WHERE isActive = 1
      GROUP BY role
    ''');

    final Map<String, int> counts = {};
    for (final row in results) {
      counts[row['role'] as String] = row['count'] as int;
    }

    return counts;
  }
}
