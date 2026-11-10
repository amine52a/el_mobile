/// Mentor profile model - Module 4
class MentorProfile {
  final int? id;
  final String userId; // UUID
  final String expertise; // Main area of expertise
  final String bio;
  final List<String> languages; // Languages spoken
  final List<String> availableDays; // Mon, Tue, Wed, etc.
  final String? availableTimeSlot; // e.g., "14:00-18:00"
  final int totalStudents;
  final double rating;
  final int totalSessions;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MentorProfile({
    this.id,
    required this.userId,
    required this.expertise,
    required this.bio,
    this.languages = const [],
    this.availableDays = const [],
    this.availableTimeSlot,
    this.totalStudents = 0,
    this.rating = 0.0,
    this.totalSessions = 0,
    this.isAvailable = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert MentorProfile to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'expertise': expertise,
      'bio': bio,
      'languages': languages.join(','),
      'availableDays': availableDays.join(','),
      'availableTimeSlot': availableTimeSlot,
      'totalStudents': totalStudents,
      'rating': rating,
      'totalSessions': totalSessions,
      'isAvailable': isAvailable ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create MentorProfile from Map
  factory MentorProfile.fromMap(Map<String, dynamic> map) {
    final languagesStr = map['languages'] as String?;
    final languages = languagesStr != null && languagesStr.isNotEmpty
        ? languagesStr.split(',')
        : <String>[];

    final daysStr = map['availableDays'] as String?;
    final availableDays =
        daysStr != null && daysStr.isNotEmpty ? daysStr.split(',') : <String>[];

    return MentorProfile(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      expertise: map['expertise'] as String,
      bio: map['bio'] as String,
      languages: languages,
      availableDays: availableDays,
      availableTimeSlot: map['availableTimeSlot'] as String?,
      totalStudents: map['totalStudents'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalSessions: map['totalSessions'] as int? ?? 0,
      isAvailable: (map['isAvailable'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  MentorProfile copyWith({
    int? id,
    String? userId,
    String? expertise,
    String? bio,
    List<String>? languages,
    List<String>? availableDays,
    String? availableTimeSlot,
    int? totalStudents,
    double? rating,
    int? totalSessions,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MentorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expertise: expertise ?? this.expertise,
      bio: bio ?? this.bio,
      languages: languages ?? this.languages,
      availableDays: availableDays ?? this.availableDays,
      availableTimeSlot: availableTimeSlot ?? this.availableTimeSlot,
      totalStudents: totalStudents ?? this.totalStudents,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted availability days
  String get formattedAvailability {
    if (availableDays.isEmpty) return 'Non spécifié';
    return availableDays.join(', ');
  }

  /// Get availability status badge text
  String get availabilityBadge {
    return isAvailable ? 'Disponible' : 'Indisponible';
  }
}
