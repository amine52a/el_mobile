/// Mentorship session model - Module 4
class MentorshipSession {
  final int? id;
  final int requestId; // Links to the mentorship request
  final String studentId; // UUID
  final String mentorId; // UUID
  final DateTime scheduledTime;
  final int durationMinutes;
  final String topic;
  final String? meetingLink; // Zoom, Google Meet, etc.
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes; // Session notes from mentor
  final int? rating; // Student's rating (1-5)
  final DateTime createdAt;
  final DateTime? completedAt;

  MentorshipSession({
    this.id,
    required this.requestId,
    required this.studentId,
    required this.mentorId,
    required this.scheduledTime,
    this.durationMinutes = 60,
    required this.topic,
    this.meetingLink,
    this.status = 'scheduled',
    this.notes,
    this.rating,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert MentorshipSession to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'studentId': studentId,
      'mentorId': mentorId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'topic': topic,
      'meetingLink': meetingLink,
      'status': status,
      'notes': notes,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create MentorshipSession from Map
  factory MentorshipSession.fromMap(Map<String, dynamic> map) {
    return MentorshipSession(
      id: map['id'] as int?,
      requestId: map['requestId'] as int,
      studentId: map['studentId'] as String,
      mentorId: map['mentorId'] as String,
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      durationMinutes: map['durationMinutes'] as int? ?? 60,
      topic: map['topic'] as String,
      meetingLink: map['meetingLink'] as String?,
      status: map['status'] as String? ?? 'scheduled',
      notes: map['notes'] as String?,
      rating: map['rating'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  MentorshipSession copyWith({
    int? id,
    int? requestId,
    String? studentId,
    String? mentorId,
    DateTime? scheduledTime,
    int? durationMinutes,
    String? topic,
    String? meetingLink,
    String? status,
    String? notes,
    int? rating,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return MentorshipSession(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      studentId: studentId ?? this.studentId,
      mentorId: mentorId ?? this.mentorId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topic: topic ?? this.topic,
      meetingLink: meetingLink ?? this.meetingLink,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Get status badge text
  String get statusBadge {
    switch (status) {
      case 'scheduled':
        return 'Planifiée';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  /// Get status checks
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// Get formatted scheduled time
  String get formattedScheduledTime {
    final day = scheduledTime.day.toString().padLeft(2, '0');
    final month = scheduledTime.month.toString().padLeft(2, '0');
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${scheduledTime.year} à $hour:$minute';
  }

  /// Get formatted scheduled date (short)
  String get formattedDate {
    final day = scheduledTime.day.toString().padLeft(2, '0');
    final month = scheduledTime.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  /// Get formatted scheduled time (short)
  String get formattedTime {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if session is upcoming
  bool get isUpcoming {
    return isScheduled && scheduledTime.isAfter(DateTime.now());
  }

  /// Check if session is past
  bool get isPast {
    return scheduledTime.isBefore(DateTime.now());
  }
}
