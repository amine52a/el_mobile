import 'package:uuid/uuid.dart';

/// Modèle pour une offre de stage (Module 5)
class Internship {
  final String id;
  final String title;
  final String company;
  final String description;
  final String domain;
  final String location;
  final String duration; // "3 mois", "6 mois", etc.
  final String internshipType; // Obligatoire, Final, Optionnel
  final List<String> requiredSkills;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime applicationDeadline;
  final String recruiterId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.domain,
    required this.location,
    required this.duration,
    required this.internshipType,
    required this.requiredSkills,
    required this.startDate,
    required this.endDate,
    required this.applicationDeadline,
    required this.recruiterId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Créer une nouvelle offre de stage
  factory Internship.create({
    required String title,
    required String company,
    required String description,
    required String domain,
    required String location,
    required String duration,
    required String internshipType,
    required List<String> requiredSkills,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime applicationDeadline,
    required String recruiterId,
  }) {
    return Internship(
      id: const Uuid().v4(),
      title: title,
      company: company,
      description: description,
      domain: domain,
      location: location,
      duration: duration,
      internshipType: internshipType,
      requiredSkills: requiredSkills,
      startDate: startDate,
      endDate: endDate,
      applicationDeadline: applicationDeadline,
      recruiterId: recruiterId,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Convertir depuis la base de données
  factory Internship.fromMap(Map<String, dynamic> map) {
    return Internship(
      id: map['id'] as String,
      title: map['title'] as String,
      company: map['company'] as String,
      description: map['description'] as String,
      domain: map['domain'] as String,
      location: map['location'] as String,
      duration: map['duration'] as String,
      internshipType: map['internshipType'] as String,
      requiredSkills: map['requiredSkills'] != null
          ? (map['requiredSkills'] as String).split(',')
          : [],
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      applicationDeadline: DateTime.parse(map['applicationDeadline'] as String),
      recruiterId: map['recruiterId'] as String,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convertir vers la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'description': description,
      'domain': domain,
      'location': location,
      'duration': duration,
      'internshipType': internshipType,
      'requiredSkills': requiredSkills.join(','),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'recruiterId': recruiterId,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Copier avec modification
  Internship copyWith({
    String? title,
    String? company,
    String? description,
    String? domain,
    String? location,
    String? duration,
    String? internshipType,
    List<String>? requiredSkills,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? applicationDeadline,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Internship(
      id: id,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      internshipType: internshipType ?? this.internshipType,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      recruiterId: recruiterId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Vérifier si la date limite est dépassée
  bool get isExpired => DateTime.now().isAfter(applicationDeadline);

  /// Vérifier si le stage est disponible
  bool get isAvailable => isActive && !isExpired;

  /// Jours restants avant la date limite
  int get daysUntilDeadline {
    final difference = applicationDeadline.difference(DateTime.now());
    return difference.inDays;
  }

  @override
  String toString() {
    return 'Internship(id: $id, title: $title, company: $company, domain: $domain, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Internship && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
