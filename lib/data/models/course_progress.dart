import 'dart:convert';

/// Model representing a student's progress in a course
class CourseProgress {
  final int? id;
  final String userId; // Changed from int to String (UUID)
  final int courseId;
  final int? currentChapterId;
  final int? currentResourceId;
  final int completedChapters;
  final int completedResources;
  final double progressPercentage; // 0-100
  final int totalTimeSpentSeconds;
  final DateTime? lastAccessedAt;
  final DateTime? completedAt;
  final DateTime enrolledAt;
  final DateTime updatedAt;

  CourseProgress({
    this.id,
    required this.userId,
    required this.courseId,
    this.currentChapterId,
    this.currentResourceId,
    this.completedChapters = 0,
    this.completedResources = 0,
    this.progressPercentage = 0.0,
    this.totalTimeSpentSeconds = 0,
    this.lastAccessedAt,
    this.completedAt,
    DateTime? enrolledAt,
    DateTime? updatedAt,
  })  : enrolledAt = enrolledAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert CourseProgress to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'currentChapterId': currentChapterId,
      'currentResourceId': currentResourceId,
      'completedChapters': completedChapters,
      'completedResources': completedResources,
      'progressPercentage': progressPercentage,
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'enrolledAt': enrolledAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create CourseProgress from Map (database row)
  factory CourseProgress.fromMap(Map<String, dynamic> map) {
    return CourseProgress(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      courseId: map['courseId'] as int,
      currentChapterId: map['currentChapterId'] as int?,
      currentResourceId: map['currentResourceId'] as int?,
      completedChapters: map['completedChapters'] as int? ?? 0,
      completedResources: map['completedResources'] as int? ?? 0,
      progressPercentage: (map['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpentSeconds: map['totalTimeSpentSeconds'] as int? ?? 0,
      lastAccessedAt: map['lastAccessedAt'] != null
          ? DateTime.parse(map['lastAccessedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      enrolledAt: DateTime.parse(map['enrolledAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  String toJson() => json.encode(toMap());

  /// Create from JSON
  factory CourseProgress.fromJson(String source) =>
      CourseProgress.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Create a copy with updated fields
  CourseProgress copyWith({
    int? id,
    String? userId, // Changed from int to String
    int? courseId,
    int? currentChapterId,
    int? currentResourceId,
    int? completedChapters,
    int? completedResources,
    double? progressPercentage,
    int? totalTimeSpentSeconds,
    DateTime? lastAccessedAt,
    DateTime? completedAt,
    DateTime? enrolledAt,
    DateTime? updatedAt,
  }) {
    return CourseProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      currentChapterId: currentChapterId ?? this.currentChapterId,
      currentResourceId: currentResourceId ?? this.currentResourceId,
      completedChapters: completedChapters ?? this.completedChapters,
      completedResources: completedResources ?? this.completedResources,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalTimeSpentSeconds:
          totalTimeSpentSeconds ?? this.totalTimeSpentSeconds,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      completedAt: completedAt ?? this.completedAt,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if course is completed
  bool get isCompleted => completedAt != null;

  /// Format total time spent (e.g., "2h 30m")
  String get formattedTimeSpent {
    final hours = totalTimeSpentSeconds ~/ 3600;
    final minutes = (totalTimeSpentSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  String toString() {
    return 'CourseProgress(id: $id, userId: $userId, courseId: $courseId, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}
