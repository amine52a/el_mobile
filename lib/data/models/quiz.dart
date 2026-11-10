/// Quiz model for Module 3
class Quiz {
  final int? id;
  final int courseId;
  final int? chapterId; // null = course-level quiz
  final String title;
  final String? description;
  final int? durationMinutes; // Time limit for the quiz
  final int maxAttempts; // Maximum number of attempts allowed (0 = unlimited)
  final double passingScore; // Minimum score to pass (percentage)
  final bool shuffleQuestions; // Randomize question order
  final bool showResults; // Show results immediately after submission
  final DateTime? availableFrom; // Quiz availability start date
  final DateTime? availableUntil; // Quiz availability end date
  final DateTime createdAt;
  final DateTime? updatedAt;

  Quiz({
    this.id,
    required this.courseId,
    this.chapterId,
    required this.title,
    this.description,
    this.durationMinutes,
    this.maxAttempts = 0, // Unlimited by default
    this.passingScore = 50.0, // 50% by default
    this.shuffleQuestions = false,
    this.showResults = true,
    this.availableFrom,
    this.availableUntil,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Quiz to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'chapterId': chapterId,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'maxAttempts': maxAttempts,
      'passingScore': passingScore,
      'shuffleQuestions': shuffleQuestions ? 1 : 0,
      'showResults': showResults ? 1 : 0,
      'availableFrom': availableFrom?.toIso8601String(),
      'availableUntil': availableUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Quiz from Map
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as int?,
      courseId: map['courseId'] as int,
      chapterId: map['chapterId'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      durationMinutes: map['durationMinutes'] as int?,
      maxAttempts: map['maxAttempts'] as int? ?? 0,
      passingScore: (map['passingScore'] as num?)?.toDouble() ?? 50.0,
      shuffleQuestions: (map['shuffleQuestions'] as int?) == 1,
      showResults: (map['showResults'] as int?) == 1,
      availableFrom: map['availableFrom'] != null 
          ? DateTime.parse(map['availableFrom'] as String)
          : null,
      availableUntil: map['availableUntil'] != null
          ? DateTime.parse(map['availableUntil'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Quiz copyWith({
    int? id,
    int? courseId,
    int? chapterId,
    String? title,
    String? description,
    int? durationMinutes,
    int? maxAttempts,
    double? passingScore,
    bool? shuffleQuestions,
    bool? showResults,
    DateTime? availableFrom,
    DateTime? availableUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      passingScore: passingScore ?? this.passingScore,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      showResults: showResults ?? this.showResults,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if quiz is currently available
  bool get isAvailable {
    final now = DateTime.now();
    
    if (availableFrom != null && now.isBefore(availableFrom!)) {
      return false;
    }
    
    if (availableUntil != null && now.isAfter(availableUntil!)) {
      return false;
    }
    
    return true;
  }

  /// Check if attempts are limited
  bool get hasLimitedAttempts => maxAttempts > 0;

  @override
  String toString() {
    return 'Quiz(id: $id, title: $title, courseId: $courseId, chapterId: $chapterId)';
  }
}
