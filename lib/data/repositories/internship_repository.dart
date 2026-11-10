import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/internship.dart';
import '../models/internship_application.dart';
import '../../core/constants/app_constants.dart';

/// Repository pour la gestion des offres de stage (Module 5 - F5.2.x)
class InternshipRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// F5.2.1 - Créer une offre de stage
  Future<void> createInternship(Internship internship) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.internshipsTable,
      internship.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// F5.2.2 - Récupérer toutes les offres actives
  Future<List<Internship>> getAllActiveInternships() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipsTable,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Internship.fromMap(maps[i]));
  }

  /// F5.2.2 - Récupérer toutes les offres (admin/recruteur)
  Future<List<Internship>> getAllInternships() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipsTable,
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Internship.fromMap(maps[i]));
  }

  /// F5.2.2 - Récupérer une offre par ID
  Future<Internship?> getInternshipById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Internship.fromMap(maps.first);
  }

  /// F5.2.2 - Récupérer les offres d'un recruteur
  Future<List<Internship>> getInternshipsByRecruiter(String recruiterId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipsTable,
      where: 'recruiterId = ?',
      whereArgs: [recruiterId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Internship.fromMap(maps[i]));
  }

  /// F5.1.2 - Filtrer les offres
  Future<List<Internship>> filterInternships({
    String? domain,
    String? location,
    String? duration,
    String? internshipType,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'isActive = 1';
    List<dynamic> whereArgs = [];

    if (domain != null && domain.isNotEmpty) {
      whereClause += ' AND domain = ?';
      whereArgs.add(domain);
    }
    
    if (location != null && location.isNotEmpty) {
      whereClause += ' AND location LIKE ?';
      whereArgs.add('%$location%');
    }
    
    if (duration != null && duration.isNotEmpty) {
      whereClause += ' AND duration = ?';
      whereArgs.add(duration);
    }
    
    if (internshipType != null && internshipType.isNotEmpty) {
      whereClause += ' AND internshipType = ?';
      whereArgs.add(internshipType);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipsTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => Internship.fromMap(maps[i]));
  }

  /// F5.1.3 - Rechercher des offres par texte
  Future<List<Internship>> searchInternships(String query) async {
    final db = await _dbHelper.database;
    final String searchQuery = '%$query%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipsTable,
      where: 'isActive = 1 AND (title LIKE ? OR description LIKE ? OR company LIKE ?)',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => Internship.fromMap(maps[i]));
  }

  /// F5.2.3 - Mettre à jour une offre
  Future<void> updateInternship(Internship internship) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.internshipsTable,
      internship.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [internship.id],
    );
  }

  /// F5.2.3 - Supprimer une offre
  Future<void> deleteInternship(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.internshipsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// F5.2.3 - Désactiver une offre (soft delete)
  Future<void> deactivateInternship(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.internshipsTable,
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ GESTION DES CANDIDATURES ============

  /// F5.1.5 - Postuler à une offre
  Future<void> applyToInternship(InternshipApplication application) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.internshipApplicationsTable,
      application.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Vérifier si l'étudiant a déjà postulé
  Future<bool> hasApplied(String internshipId, String studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipApplicationsTable,
      where: 'internshipId = ? AND studentId = ?',
      whereArgs: [internshipId, studentId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// Récupérer les candidatures d'un étudiant
  Future<List<InternshipApplication>> getStudentApplications(String studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipApplicationsTable,
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'appliedAt DESC',
    );
    return List.generate(maps.length, (i) => InternshipApplication.fromMap(maps[i]));
  }

  /// Récupérer les candidatures pour une offre
  Future<List<InternshipApplication>> getInternshipApplications(String internshipId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.internshipApplicationsTable,
      where: 'internshipId = ?',
      whereArgs: [internshipId],
      orderBy: 'appliedAt DESC',
    );
    return List.generate(maps.length, (i) => InternshipApplication.fromMap(maps[i]));
  }

  /// Mettre à jour le statut d'une candidature
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.internshipApplicationsTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [applicationId],
    );
  }

  /// Supprimer une candidature
  Future<void> deleteApplication(String applicationId) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.internshipApplicationsTable,
      where: 'id = ?',
      whereArgs: [applicationId],
    );
  }
}
