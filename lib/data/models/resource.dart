import 'dart:convert';

/// Types of educational resources
enum ResourceType {
  video,
  pdf,
  text,
  quiz,
  external;

  String get displayName {
    switch (this) {
      case ResourceType.video:
        return 'Vidéo';
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.text:
        return 'Texte';
      case ResourceType.quiz:
        return 'Quiz';
      case ResourceType.external:
        return 'Lien externe';
    }
  }
}

/// Model representing a Resource (video, PDF, text) within a Chapter
class Resource {
  final int? id;
  final int? chapterId; // null = course-level resource
  final int courseId;
  final String title;
  final String? description;
  final ResourceType type;
  final String? url; // Video URL or PDF URL
  final String? content; // For text content
  final int? durationSeconds; // For videos
  final int? sizeBytes; // File size
  final int orderIndex; // For ordering resources
  final bool isMandatory; // Is this resource mandatory?
  final Map<String, dynamic>? metadata; // Additional metadata (resolution, format, etc.)
  final bool isActive;
  final int? quizId; // ID of the associated quiz (for quiz-type resources)
  final DateTime createdAt;
  final DateTime updatedAt;

  Resource({
    this.id,
    this.chapterId, // Now nullable
    required this.courseId,
    required this.title,
    this.description,
    required this.type,
    this.url,
    this.content,
    this.durationSeconds,
    this.sizeBytes,
    required this.orderIndex,
    this.isMandatory = false,
    this.metadata,
    this.isActive = true,
    this.quizId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Resource to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'type': type.name,
      'url': url,
      'content': content,
      'durationSeconds': durationSeconds,
      'sizeBytes': sizeBytes,
      'orderIndex': orderIndex,
      'isMandatory': isMandatory ? 1 : 0,
      'metadata': metadata != null ? json.encode(metadata) : null,
      'isActive': isActive ? 1 : 0,
      'quizId': quizId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Resource from Map
  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] as int?,
      chapterId: map['chapterId'] as int?,
      courseId: map['courseId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: ResourceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ResourceType.text,
      ),
      url: map['url'] as String?,
      content: map['content'] as String?,
      durationSeconds: map['durationSeconds'] as int?,
      sizeBytes: map['sizeBytes'] as int?,
      orderIndex: map['orderIndex'] as int,
      isMandatory: (map['isMandatory'] as int?) == 1,
      metadata: map['metadata'] != null
          ? json.decode(map['metadata'] as String) as Map<String, dynamic>
          : null,
      isActive: (map['isActive'] as int) == 1,
      quizId: map['quizId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  String toJson() => json.encode(toMap());

  /// Create from JSON
  factory Resource.fromJson(String source) =>
      Resource.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Factory to create a quiz resource from a quiz ID
  factory Resource.forQuiz({
    int? id,
    int? chapterId,
    required int courseId,
    required String title,
    String? description,
    required int quizId,
    required int orderIndex,
    bool isMandatory = false,
  }) {
    return Resource(
      id: id,
      chapterId: chapterId,
      courseId: courseId,
      title: title,
      description: description,
      type: ResourceType.quiz,
      quizId: quizId,
      orderIndex: orderIndex,
      isMandatory: isMandatory,
    );
  }

  /// Create a copy with updated fields
  Resource copyWith({
    int? id,
    int? chapterId,
    int? courseId,
    String? title,
    String? description,
    ResourceType? type,
    String? url,
    String? content,
    int? durationSeconds,
    int? sizeBytes,
    int? orderIndex,
    bool? isMandatory,
    Map<String, dynamic>? metadata,
    bool? isActive,
    int? quizId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      url: url ?? this.url,
      content: content ?? this.content,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      orderIndex: orderIndex ?? this.orderIndex,
      isMandatory: isMandatory ?? this.isMandatory,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
      quizId: quizId ?? this.quizId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format duration for display (e.g., "5:30")
  String get formattedDuration {
    if (durationSeconds == null) return '';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format file size for display (e.g., "2.5 MB")
  String get formattedSize {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) {
      return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'Resource(id: $id, title: $title, type: ${type.name}, chapterId: $chapterId, quizId: $quizId)';
  }
}
