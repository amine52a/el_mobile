/// Mentorship request model - Module 4
class MentorshipRequest {
  final int? id;
  final String studentId; // UUID
  final String mentorId; // UUID
  final String topic; // What student needs help with
  final String message; // Student's message to mentor
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? respondedAt;

  MentorshipRequest({
    this.id,
    required this.studentId,
    required this.mentorId,
    required this.topic,
    required this.message,
    this.status = 'pending',
    DateTime? createdAt,
    this.respondedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert MentorshipRequest to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'mentorId': mentorId,
      'topic': topic,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  /// Create MentorshipRequest from Map
  factory MentorshipRequest.fromMap(Map<String, dynamic> map) {
    return MentorshipRequest(
      id: map['id'] as int?,
      studentId: map['studentId'] as String,
      mentorId: map['mentorId'] as String,
      topic: map['topic'] as String,
      message: map['message'] as String,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  MentorshipRequest copyWith({
    int? id,
    String? studentId,
    String? mentorId,
    String? topic,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return MentorshipRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      mentorId: mentorId ?? this.mentorId,
      topic: topic ?? this.topic,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  /// Get status badge text
  String get statusBadge {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Refusée';
      default:
        return 'Inconnu';
    }
  }

  /// Get status color (for UI)
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  /// Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? "s" : ""}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}
