/// Quiz attempt/submission model
class QuizAttempt {
  final int? id;
  final int quizId;
  final String userId; // UUID
  final DateTime startedAt;
  final DateTime? submittedAt;
  final int? score; // Total score achieved
  final int? maxScore; // Maximum possible score
  final double? percentage; // Score percentage
  final bool isPassed; // Whether the attempt passed
  final Map<int, dynamic> answers; // questionId -> answer (can be int, List<int>, bool, or String)
  final int attemptNumber; // Which attempt this is (1, 2, 3, etc.)

  QuizAttempt({
    this.id,
    required this.quizId,
    required this.userId,
    DateTime? startedAt,
    this.submittedAt,
    this.score,
    this.maxScore,
    this.percentage,
    this.isPassed = false,
    this.answers = const {},
    this.attemptNumber = 1,
  }) : startedAt = startedAt ?? DateTime.now();

  /// Convert QuizAttempt to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'score': score,
      'maxScore': maxScore,
      'percentage': percentage,
      'isPassed': isPassed ? 1 : 0,
      'answers': _encodeAnswers(answers),
      'attemptNumber': attemptNumber,
    };
  }

  /// Create QuizAttempt from Map
  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'] as int?,
      quizId: map['quizId'] as int,
      userId: map['userId'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      submittedAt: map['submittedAt'] != null
          ? DateTime.parse(map['submittedAt'] as String)
          : null,
      score: map['score'] as int?,
      maxScore: map['maxScore'] as int?,
      percentage: (map['percentage'] as num?)?.toDouble(),
      isPassed: (map['isPassed'] as int?) == 1,
      answers: _decodeAnswers(map['answers'] as String?),
      attemptNumber: map['attemptNumber'] as int? ?? 1,
    );
  }

  /// Encode answers map to JSON string for storage
  static String _encodeAnswers(Map<int, dynamic> answers) {
    final encoded = <String, dynamic>{};
    answers.forEach((key, value) {
      encoded[key.toString()] = value;
    });
    return _jsonEncode(encoded);
  }

  /// Decode answers from JSON string
  static Map<int, dynamic> _decodeAnswers(String? answersJson) {
    if (answersJson == null || answersJson.isEmpty) {
      return {};
    }

    try {
      final decoded = _jsonDecode(answersJson);
      final answers = <int, dynamic>{};
      decoded.forEach((key, value) {
        answers[int.parse(key)] = value;
      });
      return answers;
    } catch (e) {
      print('Error decoding answers: $e');
      return {};
    }
  }

  // Simple JSON encoding/decoding (replace with dart:convert in actual implementation)
  static String _jsonEncode(Map<String, dynamic> map) {
    // For now, use a simple format: key1:value1;key2:value2
    return map.entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  static Map<String, dynamic> _jsonDecode(String json) {
    final result = <String, dynamic>{};
    if (json.isEmpty) return result;
    
    final pairs = json.split(';');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }
    return result;
  }

  /// Create a copy with modified fields
  QuizAttempt copyWith({
    int? id,
    int? quizId,
    String? userId,
    DateTime? startedAt,
    DateTime? submittedAt,
    int? score,
    int? maxScore,
    double? percentage,
    bool? isPassed,
    Map<int, dynamic>? answers,
    int? attemptNumber,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      percentage: percentage ?? this.percentage,
      isPassed: isPassed ?? this.isPassed,
      answers: answers ?? this.answers,
      attemptNumber: attemptNumber ?? this.attemptNumber,
    );
  }

  /// Check if attempt is completed
  bool get isCompleted => submittedAt != null;

  /// Get duration of attempt
  Duration get duration {
    final endTime = submittedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  /// Get formatted duration
  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  String toString() {
    return 'QuizAttempt(id: $id, quizId: $quizId, userId: $userId, score: $score/$maxScore, isPassed: $isPassed)';
  }
}
