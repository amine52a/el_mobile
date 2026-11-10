import 'dart:convert';

/// Model representing a Course
class Course {
  final int? id;
  final String title;
  final String description;
  final String? imageUrl;
  final String level; // Beginner, Intermediate, Advanced
  final String subject; // Math, Science, Language, etc.
  final String language; // Arabic, English, French
  final int? instructorId;
  final String? instructorName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalChapters;
  final int totalResources;
  final double? averageRating;
  final int enrolledStudents;

  Course({
    this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.level,
    required this.subject,
    required this.language,
    this.instructorId,
    this.instructorName,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.totalChapters = 0,
    this.totalResources = 0,
    this.averageRating,
    this.enrolledStudents = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Course to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'level': level,
      'subject': subject,
      'language': language,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalChapters': totalChapters,
      'totalResources': totalResources,
      'averageRating': averageRating,
      'enrolledStudents': enrolledStudents,
    };
  }

  /// Create Course from Map
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,
      level: map['level'] as String,
      subject: map['subject'] as String,
      language: map['language'] as String,
      instructorId: map['instructorId'] as int?,
      instructorName: map['instructorName'] as String?,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      totalChapters: map['totalChapters'] as int? ?? 0,
      totalResources: map['totalResources'] as int? ?? 0,
      averageRating: map['averageRating'] as double?,
      enrolledStudents: map['enrolledStudents'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  String toJson() => json.encode(toMap());

  /// Create from JSON
  factory Course.fromJson(String source) =>
      Course.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Create a copy with updated fields
  Course copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? level,
    String? subject,
    String? language,
    int? instructorId,
    String? instructorName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalChapters,
    int? totalResources,
    double? averageRating,
    int? enrolledStudents,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      level: level ?? this.level,
      subject: subject ?? this.subject,
      language: language ?? this.language,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalChapters: totalChapters ?? this.totalChapters,
      totalResources: totalResources ?? this.totalResources,
      averageRating: averageRating ?? this.averageRating,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, title: $title, level: $level, subject: $subject, language: $language)';
  }
}
