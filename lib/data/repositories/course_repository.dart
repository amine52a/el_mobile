import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/course.dart';
import '../models/chapter.dart';
import '../models/resource.dart';
import '../models/course_progress.dart';
import '../../core/constants/app_constants.dart';

/// Repository for managing Course CRUD operations
class CourseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== COURSE OPERATIONS ====================

  /// Create a new course
  Future<int> createCourse(Course course) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.coursesTable,
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get course by ID
  Future<Course?> getCourseById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.coursesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Course.fromMap(maps.first);
  }

  /// Get all courses
  Future<List<Course>> getAllCourses({
    String? level,
    String? subject,
    String? language,
    String? searchQuery,
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (activeOnly) {
      whereClause = 'isActive = ?';
      whereArgs.add(1);
    }

    if (level != null) {
      whereClause += whereClause.isEmpty ? 'level = ?' : ' AND level = ?';
      whereArgs.add(level);
    }

    if (subject != null) {
      whereClause += whereClause.isEmpty ? 'subject = ?' : ' AND subject = ?';
      whereArgs.add(subject);
    }

    if (language != null) {
      whereClause += whereClause.isEmpty ? 'language = ?' : ' AND language = ?';
      whereArgs.add(language);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause +=
          whereClause.isEmpty ? '(title LIKE ? OR description LIKE ?)' : ' AND (title LIKE ? OR description LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.coursesTable,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  /// Update a course
  Future<int> updateCourse(Course course) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.coursesTable,
      course.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  /// Delete a course (soft delete)
  Future<int> deleteCourse(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.coursesTable,
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get courses by instructor
  Future<List<Course>> getCoursesByInstructor(int instructorId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.coursesTable,
      where: 'instructorId = ? AND isActive = ?',
      whereArgs: [instructorId, 1],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  // ==================== CHAPTER OPERATIONS ====================

  /// Create a new chapter
  Future<int> createChapter(Chapter chapter) async {
    final db = await _dbHelper.database;
    final chapterId = await db.insert(
      'chapters',
      chapter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update course totalChapters count
    await _updateCourseTotalChapters(chapter.courseId);

    return chapterId;
  }

  /// Get chapter by ID
  Future<Chapter?> getChapterById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Chapter.fromMap(maps.first);
  }

  /// Get all chapters for a course
  Future<List<Chapter>> getChaptersByCourse(int courseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'courseId = ? AND isActive = ?',
      whereArgs: [courseId, 1],
      orderBy: 'orderIndex ASC',
    );

    return List.generate(maps.length, (i) => Chapter.fromMap(maps[i]));
  }

  /// Update a chapter
  Future<int> updateChapter(Chapter chapter) async {
    final db = await _dbHelper.database;
    return await db.update(
      'chapters',
      chapter.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
  }

  /// Delete a chapter
  Future<int> deleteChapter(int id) async {
    final db = await _dbHelper.database;
    final chapter = await getChapterById(id);
    if (chapter == null) return 0;

    final result = await db.update(
      'chapters',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Update course totalChapters count
    await _updateCourseTotalChapters(chapter.courseId);

    return result;
  }

  /// Update course totalChapters count
  Future<void> _updateCourseTotalChapters(int courseId) async {
    final db = await _dbHelper.database;
    final chapters = await getChaptersByCourse(courseId);
    await db.update(
      AppConstants.coursesTable,
      {
        'totalChapters': chapters.length,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // ==================== RESOURCE OPERATIONS ====================

  /// Create a new resource
  Future<int> createResource(Resource resource) async {
    final db = await _dbHelper.database;
    final resourceId = await db.insert(
      'resources',
      resource.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update course totalResources count
    await _updateCourseTotalResources(resource.courseId);

    return resourceId;
  }

  /// Get resource by ID
  Future<Resource?> getResourceById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Resource.fromMap(maps.first);
  }

  /// Get all resources for a chapter
  Future<List<Resource>> getResourcesByChapter(int chapterId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resources',
      where: 'chapterId = ? AND isActive = ?',
      whereArgs: [chapterId, 1],
      orderBy: 'orderIndex ASC',
    );

    return List.generate(maps.length, (i) => Resource.fromMap(maps[i]));
  }

  /// Get all resources for a course
  Future<List<Resource>> getResourcesByCourse(int courseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resources',
      where: 'courseId = ? AND isActive = ?',
      whereArgs: [courseId, 1],
      orderBy: 'orderIndex ASC',
    );

    return List.generate(maps.length, (i) => Resource.fromMap(maps[i]));
  }

  /// Update a resource
  Future<int> updateResource(Resource resource) async {
    final db = await _dbHelper.database;
    return await db.update(
      'resources',
      resource.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  /// Delete a resource
  Future<int> deleteResource(int id) async {
    final db = await _dbHelper.database;
    final resource = await getResourceById(id);
    if (resource == null) return 0;

    final result = await db.update(
      'resources',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Update course totalResources count
    await _updateCourseTotalResources(resource.courseId);

    return result;
  }

  /// Update course totalResources count
  Future<void> _updateCourseTotalResources(int courseId) async {
    final db = await _dbHelper.database;
    final resources = await getResourcesByCourse(courseId);
    await db.update(
      AppConstants.coursesTable,
      {
        'totalResources': resources.length,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // ==================== COURSE PROGRESS OPERATIONS ====================

  /// Create or update course progress
  Future<int> saveProgress(CourseProgress progress) async {
    final db = await _dbHelper.database;
    
    // Check if progress already exists (using UUID)
    final existing = await getProgressByUserAndCourseUUID(
      progress.userId, // Now accepts String (UUID)
      progress.courseId,
    );

    if (existing != null) {
      // Update existing progress
      return await db.update(
        'course_progress',
        progress.copyWith(
          id: existing.id,
          updatedAt: DateTime.now(),
        ).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      // Insert new progress
      return await db.insert(
        'course_progress',
        progress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get progress by user and course (with UUID)
  Future<CourseProgress?> getProgressByUserAndCourseUUID(
    String userId,
    int courseId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'course_progress',
      where: 'userId = ? AND courseId = ?',
      whereArgs: [userId, courseId],
    );

    if (maps.isEmpty) return null;
    return CourseProgress.fromMap(maps.first);
  }

  /// Get progress by user and course (legacy - with int userId)
  Future<CourseProgress?> getProgressByUserAndCourse(
    int userId,
    int courseId,
  ) async {
    return getProgressByUserAndCourseUUID(userId.toString(), courseId);
  }

  /// Get all progress for a user
  Future<List<CourseProgress>> getProgressByUser(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'course_progress',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastAccessedAt DESC',
    );

    return List.generate(maps.length, (i) => CourseProgress.fromMap(maps[i]));
  }

  /// Update course enrolled students count
  Future<void> updateCourseEnrollment(int courseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM course_progress WHERE courseId = ?',
      [courseId],
    );

    final count = result.first['count'] as int;
    await db.update(
      AppConstants.coursesTable,
      {
        'enrolledStudents': count,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }
}
