import '../data/models/course.dart';
import '../data/models/chapter.dart';
import '../data/models/resource.dart';
import '../data/models/course_progress.dart';
import '../data/repositories/course_repository.dart';

/// Service for managing course-related business logic
class CourseService {
  final CourseRepository _repository = CourseRepository();

  // ==================== COURSE METHODS ====================

  /// Create a new course
  Future<int> createCourse({
    required String title,
    required String description,
    String? imageUrl,
    required String level,
    required String subject,
    required String language,
    int? instructorId,
    String? instructorName,
  }) async {
    final course = Course(
      title: title,
      description: description,
      imageUrl: imageUrl,
      level: level,
      subject: subject,
      language: language,
      instructorId: instructorId,
      instructorName: instructorName,
    );

    return await _repository.createCourse(course);
  }

  /// Get course by ID
  Future<Course?> getCourseById(int id) async {
    return await _repository.getCourseById(id);
  }

  /// Get all courses with optional filters
  Future<List<Course>> getCourses({
    String? level,
    String? subject,
    String? language,
    String? searchQuery,
  }) async {
    return await _repository.getAllCourses(
      level: level,
      subject: subject,
      language: language,
      searchQuery: searchQuery,
    );
  }

  /// Update course
  Future<bool> updateCourse(Course course) async {
    final result = await _repository.updateCourse(course);
    return result > 0;
  }

  /// Delete course
  Future<bool> deleteCourse(int id) async {
    final result = await _repository.deleteCourse(id);
    return result > 0;
  }

  /// Get courses by instructor
  Future<List<Course>> getCoursesByInstructor(int instructorId) async {
    return await _repository.getCoursesByInstructor(instructorId);
  }

  // ==================== CHAPTER METHODS ====================

  /// Create a new chapter
  Future<int> createChapter({
    required int courseId,
    required String title,
    String? description,
    required int orderIndex,
    int? durationMinutes,
  }) async {
    final chapter = Chapter(
      courseId: courseId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      durationMinutes: durationMinutes,
    );

    return await _repository.createChapter(chapter);
  }

  /// Create a new chapter from object
  Future<int> createChapterFromObject(Chapter chapter) async {
    return await _repository.createChapter(chapter);
  }

  /// Get chapter by ID
  Future<Chapter?> getChapterById(int id) async {
    return await _repository.getChapterById(id);
  }

  /// Get all chapters for a course
  Future<List<Chapter>> getChaptersByCourse(int courseId) async {
    return await _repository.getChaptersByCourse(courseId);
  }

  /// Update chapter
  Future<bool> updateChapter(Chapter chapter) async {
    final result = await _repository.updateChapter(chapter);
    return result > 0;
  }

  /// Delete chapter
  Future<bool> deleteChapter(int id) async {
    final result = await _repository.deleteChapter(id);
    return result > 0;
  }

  // ==================== RESOURCE METHODS ====================

  /// Create a new resource
  Future<int> createResource({
    required int chapterId,
    required int courseId,
    required String title,
    String? description,
    required ResourceType type,
    String? url,
    String? content,
    int? durationSeconds,
    int? sizeBytes,
    required int orderIndex,
    Map<String, dynamic>? metadata,
  }) async {
    final resource = Resource(
      chapterId: chapterId,
      courseId: courseId,
      title: title,
      description: description,
      type: type,
      url: url,
      content: content,
      durationSeconds: durationSeconds,
      sizeBytes: sizeBytes,
      orderIndex: orderIndex,
      metadata: metadata,
    );

    return await _repository.createResource(resource);
  }

  /// Create a new resource from Resource object
  Future<bool> createResourceFromObject(Resource resource) async {
    try {
      final id = await _repository.createResource(resource);
      return id > 0;
    } catch (e) {
      print('Error creating resource: $e');
      return false;
    }
  }

  /// Update resource from Resource object
  Future<bool> updateResourceFromObject(Resource resource) async {
    try {
      final result = await _repository.updateResource(resource);
      return result > 0;
    } catch (e) {
      print('Error updating resource: $e');
      return false;
    }
  }

  /// Get resource by ID
  Future<Resource?> getResourceById(int id) async {
    return await _repository.getResourceById(id);
  }

  /// Get all resources for a chapter
  Future<List<Resource>> getResourcesByChapter(int chapterId) async {
    return await _repository.getResourcesByChapter(chapterId);
  }

  /// Get all resources for a course
  Future<List<Resource>> getResourcesByCourse(int courseId) async {
    return await _repository.getResourcesByCourse(courseId);
  }

  /// Update resource
  Future<bool> updateResource(Resource resource) async {
    final result = await _repository.updateResource(resource);
    return result > 0;
  }

  /// Delete resource
  Future<bool> deleteResource(int id) async {
    final result = await _repository.deleteResource(id);
    return result > 0;
  }

  // ==================== PROGRESS METHODS ====================

  /// Enroll user in a course (with UUID)
  Future<bool> enrollInCourseWithUUID(String userId, int courseId) async {
    try {
      // Check if already enrolled
      final existing = await _repository.getProgressByUserAndCourseUUID(
        userId,
        courseId,
      );

      if (existing != null) {
        return false; // Already enrolled
      }

      // Create new enrollment
      final progress = CourseProgress(
        userId: userId,
        courseId: courseId,
      );

      await _repository.saveProgress(progress);
      await _repository.updateCourseEnrollment(courseId);

      return true;
    } catch (e) {
      print('Error enrolling in course: $e');
      return false;
    }
  }

  /// Enroll user in a course (legacy - with int userId)
  Future<bool> enrollInCourse(int userId, int courseId) async {
    try {
      // Check if already enrolled
      final existing = await _repository.getProgressByUserAndCourse(
        userId,
        courseId,
      );

      if (existing != null) {
        return false; // Already enrolled
      }

      // Create new enrollment
      final progress = CourseProgress(
        userId: userId.toString(), // Convert int to String
        courseId: courseId,
      );

      await _repository.saveProgress(progress);
      await _repository.updateCourseEnrollment(courseId);

      return true;
    } catch (e) {
      print('Error enrolling in course: $e');
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
      final existing = await _repository.getProgressByUserAndCourse(
        userId,
        courseId,
      );

      if (existing == null) {
        // User not enrolled
        return false;
      }

      // Calculate new values
      final totalTimeSpent = existing.totalTimeSpentSeconds +
          (additionalTimeSpentSeconds ?? 0);

      // Get course info to calculate percentage
      final chapters = await _repository.getChaptersByCourse(courseId);
      final resources = await _repository.getResourcesByCourse(courseId);

      // TODO: Calculate completed chapters and resources based on user activity
      // For now, we'll keep the existing values
      final completedChapters = existing.completedChapters;
      final completedResources = existing.completedResources;

      // Calculate progress percentage
      final totalItems = chapters.length + resources.length;
      final completedItems = completedChapters + completedResources;
      final progressPercentage =
          totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

      // Check if course is completed
      DateTime? completedAt;
      if (progressPercentage >= 100 && existing.completedAt == null) {
        completedAt = DateTime.now();
      }

      // Update progress
      final updatedProgress = existing.copyWith(
        currentChapterId: currentChapterId ?? existing.currentChapterId,
        currentResourceId: currentResourceId ?? existing.currentResourceId,
        completedChapters: completedChapters,
        completedResources: completedResources,
        progressPercentage: progressPercentage,
        totalTimeSpentSeconds: totalTimeSpent,
        lastAccessedAt: DateTime.now(),
        completedAt: completedAt,
        updatedAt: DateTime.now(),
      );

      await _repository.saveProgress(updatedProgress);
      return true;
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  /// Get user's progress for a specific course
  Future<CourseProgress?> getCourseProgress(int userId, int courseId) async {
    return await _repository.getProgressByUserAndCourse(userId, courseId);
  }

  /// Get all courses the user is enrolled in
  Future<List<CourseProgress>> getUserEnrolledCourses(int userId) async {
    return await _repository.getProgressByUser(userId);
  }

  /// Get user's enrolled courses with course details
  Future<List<Map<String, dynamic>>> getUserCoursesWithDetails(
    int userId,
  ) async {
    final progressList = await _repository.getProgressByUser(userId);
    final result = <Map<String, dynamic>>[];

    for (final progress in progressList) {
      final course = await _repository.getCourseById(progress.courseId);
      if (course != null) {
        result.add({
          'course': course,
          'progress': progress,
        });
      }
    }

    return result;
  }

  /// Check if user is enrolled in a course (with UUID)
  Future<bool> isEnrolledWithUUID(String userId, int courseId) async {
    final progress = await _repository.getProgressByUserAndCourseUUID(
      userId,
      courseId,
    );
    return progress != null;
  }

  /// Check if user is enrolled in a course (legacy)
  Future<bool> isEnrolled(int userId, int courseId) async {
    final progress = await _repository.getProgressByUserAndCourse(
      userId,
      courseId,
    );
    return progress != null;
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
      final existing = await _repository.getProgressByUserAndCourseUUID(
        userId,
        courseId,
      );

      if (existing == null) {
        // User not enrolled
        return false;
      }

      // Calculate new values
      final totalTimeSpent = existing.totalTimeSpentSeconds +
          (additionalTimeSpentSeconds ?? 0);

      // Get course info to calculate percentage
      final chapters = await _repository.getChaptersByCourse(courseId);
      final resources = await _repository.getResourcesByCourse(courseId);

      // TODO: Calculate completed chapters and resources based on user activity
      // For now, we'll keep the existing values
      final completedChapters = existing.completedChapters;
      final completedResources = existing.completedResources;

      // Calculate progress percentage
      final totalItems = chapters.length + resources.length;
      final completedItems = completedChapters + completedResources;
      final progressPercentage =
          totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

      // Check if course is completed
      DateTime? completedAt;
      if (progressPercentage >= 100 && existing.completedAt == null) {
        completedAt = DateTime.now();
      }

      // Update progress
      final updatedProgress = existing.copyWith(
        currentChapterId: currentChapterId ?? existing.currentChapterId,
        currentResourceId: currentResourceId ?? existing.currentResourceId,
        completedChapters: completedChapters,
        completedResources: completedResources,
        progressPercentage: progressPercentage,
        totalTimeSpentSeconds: totalTimeSpent,
        lastAccessedAt: DateTime.now(),
        completedAt: completedAt,
        updatedAt: DateTime.now(),
      );

      await _repository.saveProgress(updatedProgress);
      return true;
    } catch (e) {
      print('Error updating progress with UUID: $e');
      return false;
    }
  }

  /// Get user's progress for a specific course with UUID
  Future<CourseProgress?> getCourseProgressWithUUID(String userId, int courseId) async {
    return await _repository.getProgressByUserAndCourseUUID(userId, courseId);
  }
}
