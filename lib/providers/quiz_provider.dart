import 'package:flutter/foundation.dart';
import '../data/models/quiz.dart';
import '../data/models/question.dart';
import '../data/models/quiz_attempt.dart';
import '../data/repositories/quiz_repository.dart';

/// Provider for managing Quiz state (F3.1)
class QuizProvider with ChangeNotifier {
  final QuizRepository _repository = QuizRepository();

  List<Quiz> _quizzes = [];
  List<Question> _currentQuizQuestions = [];
  Quiz? _currentQuiz;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Quiz> get quizzes => _quizzes;
  List<Question> get currentQuizQuestions => _currentQuizQuestions;
  Quiz? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== QUIZ OPERATIONS ====================

  /// Load all quizzes for a course
  Future<void> loadQuizzesByCourse(int courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await _repository.getQuizzesByCourse(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des quiz: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all quizzes for a chapter
  Future<void> loadQuizzesByChapter(int chapterId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await _repository.getQuizzesByChapter(chapterId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des quiz: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all quizzes (admin)
  Future<void> loadAllQuizzes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizzes = await _repository.getAllQuizzes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des quiz: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific quiz with its questions
  Future<void> loadQuiz(int quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentQuiz = await _repository.getQuizById(quizId);
      if (_currentQuiz != null) {
        _currentQuizQuestions = await _repository.getQuestionsByQuiz(quizId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement du quiz: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new quiz (F3.1.1)
  Future<int?> createQuiz(Quiz quiz) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final quizId = await _repository.createQuiz(quiz);
      
      // Reload quizzes based on context
      if (quiz.chapterId != null) {
        await loadQuizzesByChapter(quiz.chapterId!);
      } else {
        await loadQuizzesByCourse(quiz.courseId);
      }
      
      _isLoading = false;
      notifyListeners();
      return quizId;
    } catch (e) {
      _error = 'Erreur lors de la création du quiz: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update an existing quiz (F3.1.2)
  Future<bool> updateQuiz(Quiz quiz) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateQuiz(quiz);
      
      // Update in local list
      final index = _quizzes.indexWhere((q) => q.id == quiz.id);
      if (index != -1) {
        _quizzes[index] = quiz;
      }
      
      // Update current quiz if it's the one being edited
      if (_currentQuiz?.id == quiz.id) {
        _currentQuiz = quiz;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du quiz: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a quiz (F3.1.3)
  Future<bool> deleteQuiz(int quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteQuiz(quizId);
      
      // Remove from local list
      _quizzes.removeWhere((q) => q.id == quizId);
      
      // Clear current quiz if it was deleted
      if (_currentQuiz?.id == quizId) {
        _currentQuiz = null;
        _currentQuizQuestions.clear();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression du quiz: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== QUESTION OPERATIONS ====================

  /// Add a question to the current quiz (F3.1.4)
  Future<int?> addQuestion(Question question) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final questionId = await _repository.createQuestion(question);
      
      // Reload questions if we have a current quiz
      if (_currentQuiz != null) {
        _currentQuizQuestions = await _repository.getQuestionsByQuiz(_currentQuiz!.id!);
      }
      
      _isLoading = false;
      notifyListeners();
      return questionId;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la question: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update a question (F3.1.5)
  Future<bool> updateQuestion(Question question) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateQuestion(question);
      
      // Update in local list
      final index = _currentQuizQuestions.indexWhere((q) => q.id == question.id);
      if (index != -1) {
        _currentQuizQuestions[index] = question;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de la question: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a question (F3.1.6)
  Future<bool> deleteQuestion(int questionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteQuestion(questionId);
      
      // Remove from local list
      _currentQuizQuestions.removeWhere((q) => q.id == questionId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression de la question: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reorder questions
  Future<bool> reorderQuestions(List<Question> reorderedQuestions) async {
    try {
      final questionIds = reorderedQuestions.map((q) => q.id!).toList();
      await _repository.reorderQuestions(_currentQuiz!.id!, questionIds);
      
      _currentQuizQuestions = reorderedQuestions;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du réordonnancement des questions: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== QUIZ TAKING OPERATIONS ====================

  /// Get questions for a specific quiz (for quiz taking)
  List<Question> get questions => _currentQuizQuestions;

  /// Load questions for quiz taking
  Future<void> loadQuestionsByQuiz(int quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentQuizQuestions = await _repository.getQuestionsByQuiz(quizId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des questions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save a quiz attempt
  Future<bool> createQuizAttempt({
    required int quizId,
    required String userId,
    required double score,
    required Map<String, String> answers,
  }) async {
    try {
      // Convert answers from Map<String, String> to Map<int, dynamic>
      final answersMap = <int, dynamic>{};
      answers.forEach((key, value) {
        answersMap[int.parse(key)] = value;
      });

      final attempt = QuizAttempt(
        quizId: quizId,
        userId: userId,
        percentage: score,
        isPassed: score >= (_currentQuiz?.passingScore ?? 50.0),
        answers: answersMap,
        submittedAt: DateTime.now(),
      );

      await _repository.createQuizAttempt(attempt);
      return true;
    } catch (e) {
      _error = 'Erreur lors de la sauvegarde de la tentative: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get quiz attempts for a user
  Future<List<Map<String, dynamic>>> getQuizAttempts(String userId, int quizId) async {
    try {
      // TODO: Implement getQuizAttemptsByUser in QuizRepository
      return [];
    } catch (e) {
      _error = 'Erreur lors du chargement des tentatives: $e';
      notifyListeners();
      return [];
    }
  }

  /// Clear current quiz and questions
  void clearCurrentQuiz() {
    _currentQuiz = null;
    _currentQuizQuestions.clear();
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
