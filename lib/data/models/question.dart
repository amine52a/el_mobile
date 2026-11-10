/// Question types for quizzes
enum QuestionType {
  multipleChoice, // QCM - Multiple choice question
  trueFalse,      // Vrai/Faux
  shortAnswer;    // Texte court

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'QCM';
      case QuestionType.trueFalse:
        return 'Vrai/Faux';
      case QuestionType.shortAnswer:
        return 'Réponse courte';
    }
  }
}

/// Question model for Module 3
class Question {
  final int? id;
  final int quizId;
  final QuestionType type;
  final String questionText;
  final String? explanation; // Explanation shown after answering
  final int points; // Points awarded for correct answer
  final int orderIndex; // Order in quiz
  final List<String> options; // For multiple choice questions
  final List<int> correctAnswerIndices; // Indices of correct answers (for QCM)
  final bool? correctAnswerBool; // For true/false questions
  final String? correctAnswerText; // For short answer questions
  final DateTime createdAt;
  final DateTime? updatedAt;

  Question({
    this.id,
    required this.quizId,
    required this.type,
    required this.questionText,
    this.explanation,
    this.points = 1,
    required this.orderIndex,
    this.options = const [],
    this.correctAnswerIndices = const [],
    this.correctAnswerBool,
    this.correctAnswerText,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Question to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'type': type.name,
      'questionText': questionText,
      'explanation': explanation,
      'points': points,
      'orderIndex': orderIndex,
      'options': options.join('|||'), // Store as delimited string
      'correctAnswerIndices': correctAnswerIndices.join(','),
      'correctAnswerBool': correctAnswerBool != null ? (correctAnswerBool! ? 1 : 0) : null,
      'correctAnswerText': correctAnswerText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Question from Map
  factory Question.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String;
    final type = QuestionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => QuestionType.multipleChoice,
    );

    // Parse options
    final optionsStr = map['options'] as String?;
    final options = optionsStr != null && optionsStr.isNotEmpty
        ? optionsStr.split('|||')
        : <String>[];

    // Parse correct answer indices
    final indicesStr = map['correctAnswerIndices'] as String?;
    final correctAnswerIndices = indicesStr != null && indicesStr.isNotEmpty
        ? indicesStr.split(',').map((e) => int.parse(e)).toList()
        : <int>[];

    return Question(
      id: map['id'] as int?,
      quizId: map['quizId'] as int,
      type: type,
      questionText: map['questionText'] as String,
      explanation: map['explanation'] as String?,
      points: map['points'] as int? ?? 1,
      orderIndex: map['orderIndex'] as int,
      options: options,
      correctAnswerIndices: correctAnswerIndices,
      correctAnswerBool: map['correctAnswerBool'] != null
          ? (map['correctAnswerBool'] as int) == 1
          : null,
      correctAnswerText: map['correctAnswerText'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Question copyWith({
    int? id,
    int? quizId,
    QuestionType? type,
    String? questionText,
    String? explanation,
    int? points,
    int? orderIndex,
    List<String>? options,
    List<int>? correctAnswerIndices,
    bool? correctAnswerBool,
    String? correctAnswerText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      type: type ?? this.type,
      questionText: questionText ?? this.questionText,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      orderIndex: orderIndex ?? this.orderIndex,
      options: options ?? this.options,
      correctAnswerIndices: correctAnswerIndices ?? this.correctAnswerIndices,
      correctAnswerBool: correctAnswerBool ?? this.correctAnswerBool,
      correctAnswerText: correctAnswerText ?? this.correctAnswerText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a given answer is correct
  bool isAnswerCorrect(dynamic answer) {
    switch (type) {
      case QuestionType.multipleChoice:
        if (answer is List<int>) {
          // Check if selected indices match correct indices
          if (answer.length != correctAnswerIndices.length) return false;
          return answer.every((idx) => correctAnswerIndices.contains(idx)) &&
                 correctAnswerIndices.every((idx) => answer.contains(idx));
        } else if (answer is int) {
          // Single answer
          return correctAnswerIndices.contains(answer);
        }
        return false;

      case QuestionType.trueFalse:
        if (answer is bool) {
          return answer == correctAnswerBool;
        }
        return false;

      case QuestionType.shortAnswer:
        if (answer is String && correctAnswerText != null) {
          // Case-insensitive comparison, trim whitespace
          return answer.trim().toLowerCase() == correctAnswerText!.trim().toLowerCase();
        }
        return false;
    }
  }

  @override
  String toString() {
    return 'Question(id: $id, type: ${type.displayName}, text: $questionText)';
  }
}
