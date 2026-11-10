import 'dart:convert';

/// Model representing a Chapter within a Course
class Chapter {
  final int? id;
  final int courseId;
  final String title;
  final String? description;
  final int orderIndex; // For ordering chapters
  final int? durationMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.durationMinutes,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Chapter to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'durationMinutes': durationMinutes,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Chapter from Map
  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as int?,
      courseId: map['courseId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      orderIndex: map['orderIndex'] as int,
      durationMinutes: map['durationMinutes'] as int?,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  String toJson() => json.encode(toMap());

  /// Create from JSON
  factory Chapter.fromJson(String source) =>
      Chapter.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Create a copy with updated fields
  Chapter copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    int? orderIndex,
    int? durationMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Chapter(id: $id, courseId: $courseId, title: $title, order: $orderIndex)';
  }
}
