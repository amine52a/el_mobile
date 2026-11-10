import '../database/database_helper.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';
import '../../core/constants/app_constants.dart';

/// Repository for managing Quiz data (F3.1 - Quiz Management)
class QuizRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ==================== QUIZ CRUD ====================
  
  /// Create a new quiz (F3.1.1)
  Future<int> createQuiz(Quiz quiz) async {
    final db = await _db.database;
    return await db.insert(AppConstants.tableQuizzes, quiz.toMap());
  }

  /// Get quiz by ID
  Future<Quiz?> getQuizById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuizzes,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Quiz.fromMap(maps.first);
  }

  /// Get all quizzes for a course
  Future<List<Quiz>> getQuizzesByCourse(int courseId) async {
    final db = await _db.database;
    print('📊 QuizRepository.getQuizzesByCourse: courseId=$courseId');
    final maps = await db.query(
      AppConstants.tableQuizzes,
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'createdAt DESC',
    );
    
    print('📊 QuizRepository.getQuizzesByCourse: Found ${maps.length} quizzes');
    if (maps.isNotEmpty) {
      print('📊 First quiz: ${maps.first}');
    }
    
    return maps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// Get all quizzes for a chapter
  Future<List<Quiz>> getQuizzesByChapter(int chapterId) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuizzes,
      where: 'chapterId = ?',
      whereArgs: [chapterId],
      orderBy: 'createdAt DESC',
    );
    
    return maps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// Get all quizzes (for admin)
  Future<List<Quiz>> getAllQuizzes() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuizzes,
      orderBy: 'createdAt DESC',
    );
    
    return maps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// Update a quiz (F3.1.2)
  Future<int> updateQuiz(Quiz quiz) async {
    final db = await _db.database;
    return await db.update(
      AppConstants.tableQuizzes,
      quiz.toMap(),
      where: 'id = ?',
      whereArgs: [quiz.id],
    );
  }

  /// Delete a quiz (F3.1.3) - CASCADE will delete questions and attempts
  Future<int> deleteQuiz(int id) async {
    final db = await _db.database;
    return await db.delete(
      AppConstants.tableQuizzes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== QUESTION CRUD ====================

  /// Add a question to a quiz (F3.1.4)
  Future<int> createQuestion(Question question) async {
    final db = await _db.database;
    return await db.insert(AppConstants.tableQuestions, question.toMap());
  }

  /// Get all questions for a quiz
  Future<List<Question>> getQuestionsByQuiz(int quizId) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuestions,
      where: 'quizId = ?',
      whereArgs: [quizId],
      orderBy: 'orderIndex ASC',
    );
    
    return maps.map((map) => Question.fromMap(map)).toList();
  }

  /// Get a single question by ID
  Future<Question?> getQuestionById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuestions,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Question.fromMap(maps.first);
  }

  /// Update a question (F3.1.5)
  Future<int> updateQuestion(Question question) async {
    final db = await _db.database;
    return await db.update(
      AppConstants.tableQuestions,
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  /// Delete a question (F3.1.6)
  Future<int> deleteQuestion(int id) async {
    final db = await _db.database;
    return await db.delete(
      AppConstants.tableQuestions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reorder questions for a quiz
  Future<void> reorderQuestions(int quizId, List<int> questionIds) async {
    final db = await _db.database;
    final batch = db.batch();
    
    for (int i = 0; i < questionIds.length; i++) {
      batch.update(
        AppConstants.tableQuestions,
        {'orderIndex': i + 1},
        where: 'id = ?',
        whereArgs: [questionIds[i]],
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ==================== QUIZ ATTEMPT CRUD ====================

  /// Create a new quiz attempt (F3.2.1 - Student starts quiz)
  Future<int> createQuizAttempt(QuizAttempt attempt) async {
    final db = await _db.database;
    return await db.insert(AppConstants.tableQuizAttempts, attempt.toMap());
  }

  /// Get all attempts by a user for a quiz
  Future<List<QuizAttempt>> getAttemptsByUserAndQuiz(int userId, int quizId) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuizAttempts,
      where: 'userId = ? AND quizId = ?',
      whereArgs: [userId, quizId],
      orderBy: 'startedAt DESC',
    );
    
    return maps.map((map) => QuizAttempt.fromMap(map)).toList();
  }

  /// Get a specific attempt by ID
  Future<QuizAttempt?> getAttemptById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuizAttempts,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return QuizAttempt.fromMap(maps.first);
  }

  /// Update a quiz attempt (F3.2.3 - Submit answers)
  Future<int> updateQuizAttempt(QuizAttempt attempt) async {
    final db = await _db.database;
    return await db.update(
      AppConstants.tableQuizAttempts,
      attempt.toMap(),
      where: 'id = ?',
      whereArgs: [attempt.id],
    );
  }

  /// Get all attempts for a quiz (for admin/stats)
  Future<List<QuizAttempt>> getAttemptsByQuiz(int quizId) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableQuizAttempts,
      where: 'quizId = ?',
      whereArgs: [quizId],
      orderBy: 'startedAt DESC',
    );
    
    return maps.map((map) => QuizAttempt.fromMap(map)).toList();
  }

  /// Get attempt count for a user on a specific quiz
  Future<int> getAttemptCount(int userId, int quizId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableQuizAttempts} WHERE userId = ? AND quizId = ?',
      [userId, quizId],
    );
    
    return result.first['count'] as int;
  }

  /// Get best score for a user on a quiz
  Future<double?> getBestScore(int userId, int quizId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT MAX(score) as bestScore FROM ${AppConstants.tableQuizAttempts} WHERE userId = ? AND quizId = ? AND completedAt IS NOT NULL',
      [userId, quizId],
    );
    
    return result.first['bestScore'] as double?;
  }

  // ==================== STATISTICS ====================

  /// Get quiz statistics
  Future<Map<String, dynamic>> getQuizStats(int quizId) async {
    final db = await _db.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_attempts,
        COUNT(DISTINCT userId) as unique_students,
        AVG(score) as average_score,
        MAX(score) as highest_score,
        MIN(score) as lowest_score,
        COUNT(CASE WHEN completedAt IS NOT NULL THEN 1 END) as completedAttempts
      FROM ${AppConstants.tableQuizAttempts}
      WHERE quizId = ?
    ''', [quizId]);
    
    return result.first;
  }
}
