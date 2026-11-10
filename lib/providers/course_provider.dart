import 'package:flutter/foundation.dart';
import '../data/models/course.dart';
import '../data/models/chapter.dart';
import '../data/models/resource.dart';
import '../data/models/course_progress.dart';
import '../services/course_service.dart';

/// Provider for managing course state and operations
class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();

  // State variables
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  Course? _selectedCourse;
  List<Chapter> _currentChapters = [];
  List<Resource> _currentResources = [];
  CourseProgress? _currentProgress;
  List<Map<String, dynamic>> _enrolledCourses = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String? _selectedLevel;
  String? _selectedSubject;
  String? _selectedLanguage;
  String? _searchQuery;

  // Getters
  List<Course> get courses => _filteredCourses;
  List<Course> get allCourses => _courses;
  Course? get selectedCourse => _selectedCourse;
  List<Chapter> get currentChapters => _currentChapters;
  List<Resource> get currentResources => _currentResources;
  CourseProgress? get currentProgress => _currentProgress;
  List<Map<String, dynamic>> get enrolledCourses => _enrolledCourses;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get selectedLevel => _selectedLevel;
  String? get selectedSubject => _selectedSubject;
  String? get selectedLanguage => _selectedLanguage;
  String? get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _selectedLevel != null ||
      _selectedSubject != null ||
      _selectedLanguage != null ||
      (_searchQuery != null && _searchQuery!.isNotEmpty);

  // ==================== INITIALIZATION ====================

  /// Initialize and load all courses
  Future<void> initialize() async {
    await loadCourses();
  }

  // ==================== COURSE OPERATIONS ====================

  /// Load all courses
  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _courses = await _courseService.getCourses();
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des cours: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific course by ID
  Future<void> loadCourse(int courseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedCourse = await _courseService.getCourseById(courseId);
      
      if (_selectedCourse != null) {
        // Load chapters and resources
        _currentChapters = await _courseService.getChaptersByCourse(courseId);
        _currentResources = await _courseService.getResourcesByCourse(courseId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du cours: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load course with progress for a specific user
  Future<void> loadCourseWithProgress(int courseId, int userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await loadCourse(courseId);
      _currentProgress = await _courseService.getCourseProgress(userId, courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new course
  Future<bool> createCourse({
    required String title,
    required String description,
    String? imageUrl,
    required String level,
    required String subject,
    required String language,
    int? instructorId,
    String? instructorName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _courseService.createCourse(
        title: title,
        description: description,
        imageUrl: imageUrl,
        level: level,
        subject: subject,
        language: language,
        instructorId: instructorId,
        instructorName: instructorName,
      );

      // Reload courses
      await loadCourses();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du cours: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing course
  Future<bool> updateCourse(Course course) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _courseService.updateCourse(course);
      
      if (success) {
        await loadCourses();
        if (_selectedCourse?.id == course.id) {
          _selectedCourse = course;
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification du cours: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a course
  Future<bool> deleteCourse(int courseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _courseService.deleteCourse(courseId);
      
      if (success) {
        await loadCourses();
        if (_selectedCourse?.id == courseId) {
          _selectedCourse = null;
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du cours: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== FILTERING ====================

  /// Set level filter
  void setLevelFilter(String? level) {
    _selectedLevel = level;
    _applyFilters();
    notifyListeners();
  }

  /// Set subject filter
  void setSubjectFilter(String? subject) {
    _selectedSubject = subject;
    _applyFilters();
    notifyListeners();
  }

  /// Set language filter
  void setLanguageFilter(String? language) {
    _selectedLanguage = language;
    _applyFilters();
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedLevel = null;
    _selectedSubject = null;
    _selectedLanguage = null;
    _searchQuery = null;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters to courses list
  void _applyFilters() {
    _filteredCourses = _courses.where((course) {
      // Level filter
      if (_selectedLevel != null && course.level != _selectedLevel) {
        return false;
      }

      // Subject filter
      if (_selectedSubject != null && course.subject != _selectedSubject) {
        return false;
      }

      // Language filter
      if (_selectedLanguage != null && course.language != _selectedLanguage) {
        return false;
      }

      // Search query
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        return course.title.toLowerCase().contains(query) ||
            course.description.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  // ==================== ENROLLMENT & PROGRESS ====================

  /// Enroll user in a course (with UUID)
  Future<bool> enrollInCourseWithUUID(String userId, int courseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _courseService.enrollInCourseWithUUID(userId, courseId);
      
      if (success) {
        // Reload course to update enrollment count
        await loadCourse(courseId);
      } else {
        _errorMessage = 'Vous êtes déjà inscrit à ce cours';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Enroll user in a course (legacy - with int userId)
  Future<bool> enrollInCourse(int userId, int courseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _courseService.enrollInCourse(userId, courseId);
      
      if (success) {
        // Reload enrolled courses
        await loadUserEnrolledCourses(userId);
        // Reload course to update enrollment count
        await loadCourse(courseId);
      } else {
        _errorMessage = 'Vous êtes déjà inscrit à ce cours';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update course progress
  Future<bool> updateProgress({
    required int userId,
    required int courseId,
    int? currentChapterId,
    int? currentResourceId,
    int? additionalTimeSpentSeconds,
  }) async {
    try {
      final success = await _courseService.updateProgress(
        userId: userId,
        courseId: courseId,
        currentChapterId: currentChapterId,
        currentResourceId: currentResourceId,
        additionalTimeSpentSeconds: additionalTimeSpentSeconds,
      );

      if (success) {
        // Reload progress
        _currentProgress = await _courseService.getCourseProgress(userId, courseId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la progression: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update course progress with UUID
  Future<bool> updateProgressWithUUID({
    required String userId,
    required int courseId,
    int? currentChapterId,
    int? currentResourceId,
    int? additionalTimeSpentSeconds,
  }) async {
    try {
      final success = await _courseService.updateProgressWithUUID(
        userId: userId,
        courseId: courseId,
        currentChapterId: currentChapterId,
        currentResourceId: currentResourceId,
        additionalTimeSpentSeconds: additionalTimeSpentSeconds,
      );

      if (success) {
        // Reload progress
        _currentProgress = await _courseService.getCourseProgressWithUUID(userId, courseId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la progression: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load user's enrolled courses
  Future<void> loadUserEnrolledCourses(int userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _enrolledCourses = await _courseService.getUserCoursesWithDetails(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des cours inscrits: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user is enrolled in a course (with UUID)
  Future<bool> isEnrolledWithUUID(String userId, int courseId) async {
    return await _courseService.isEnrolledWithUUID(userId, courseId);
  }

  /// Check if user is enrolled in a course (legacy)
  Future<bool> isEnrolled(int userId, int courseId) async {
    return await _courseService.isEnrolled(userId, courseId);
  }

  // ==================== CHAPTER OPERATIONS ====================

  /// Load chapters for the selected course
  Future<void> loadChapters(int courseId) async {
    try {
      _currentChapters = await _courseService.getChaptersByCourse(courseId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des chapitres: $e';
      notifyListeners();
    }
  }

  // ==================== RESOURCE OPERATIONS ====================

  /// Load resources for a specific chapter
  Future<void> loadResourcesByChapter(int chapterId) async {
    try {
      _currentResources = await _courseService.getResourcesByChapter(chapterId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des ressources: $e';
      notifyListeners();
    }
  }

  /// Load resources for a specific course (no chapter)
  Future<void> loadResourcesByCourse(int courseId) async {
    try {
      _currentResources = await _courseService.getResourcesByCourse(courseId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des ressources: $e';
      notifyListeners();
    }
  }

  /// Create a new resource
  Future<bool> createResource(Resource resource) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _courseService.createResourceFromObject(resource);

      _isLoading = false;
      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Erreur lors de la création de la ressource';
      }
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la création de la ressource: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing resource
  Future<bool> updateResource(Resource resource) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _courseService.updateResourceFromObject(resource);

      _isLoading = false;
      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Erreur lors de la mise à jour de la ressource';
      }
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la mise à jour de la ressource: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a resource
  Future<bool> deleteResource(int resourceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _courseService.deleteResource(resourceId);

      _isLoading = false;
      if (success) {
        _errorMessage = null;
        // Remove from local list
        _currentResources.removeWhere((r) => r.id == resourceId);
      } else {
        _errorMessage = 'Erreur lors de la suppression de la ressource';
      }
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la suppression de la ressource: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== CHAPTER OPERATIONS ====================

  /// Load chapters for a specific course
  Future<void> loadChaptersByCourse(int courseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentChapters = await _courseService.getChaptersByCourse(courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des chapitres: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new chapter
  Future<bool> createChapter(Chapter chapter) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final chapterId = await _courseService.createChapterFromObject(chapter);

      _isLoading = false;
      if (chapterId > 0) {
        // Reload chapters to get the new one with ID
        await loadChaptersByCourse(chapter.courseId);
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erreur lors de la création du chapitre';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la création du chapitre: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing chapter
  Future<bool> updateChapter(Chapter chapter) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _courseService.updateChapter(chapter);

      _isLoading = false;
      if (success) {
        // Update local list
        final index = _currentChapters.indexWhere((c) => c.id == chapter.id);
        if (index != -1) {
          _currentChapters[index] = chapter;
        }
        _errorMessage = null;
      } else {
        _errorMessage = 'Erreur lors de la mise à jour du chapitre';
      }
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la mise à jour du chapitre: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a chapter
  Future<bool> deleteChapter(int chapterId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _courseService.deleteChapter(chapterId);

      _isLoading = false;
      if (success) {
        _errorMessage = null;
        // Remove from local list
        _currentChapters.removeWhere((c) => c.id == chapterId);
        // Also remove associated resources
        _currentResources.removeWhere((r) => r.chapterId == chapterId);
      } else {
        _errorMessage = 'Erreur lors de la suppression du chapitre';
      }
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la suppression du chapitre: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    _currentChapters = [];
    _currentResources = [];
    _currentProgress = null;
    notifyListeners();
  }
}
