import 'package:uuid/uuid.dart';

/// Modèle pour une candidature à un stage (Module 5)
class InternshipApplication {
  final String id;
  final String internshipId;
  final String studentId;
  final String status; // pending, accepted, rejected
  final String? coverLetter;
  final DateTime appliedAt;

  InternshipApplication({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.status,
    this.coverLetter,
    required this.appliedAt,
  });

  /// Créer une nouvelle candidature
  factory InternshipApplication.create({
    required String internshipId,
    required String studentId,
    String? coverLetter,
  }) {
    return InternshipApplication(
      id: const Uuid().v4(),
      internshipId: internshipId,
      studentId: studentId,
      status: 'pending',
      coverLetter: coverLetter,
      appliedAt: DateTime.now(),
    );
  }

  /// Convertir depuis la base de données
  factory InternshipApplication.fromMap(Map<String, dynamic> map) {
    return InternshipApplication(
      id: map['id'] as String,
      internshipId: map['internshipId'] as String,
      studentId: map['studentId'] as String,
      status: map['status'] as String,
      coverLetter: map['coverLetter'] as String?,
      appliedAt: DateTime.parse(map['appliedAt'] as String),
    );
  }

  /// Convertir vers la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'internshipId': internshipId,
      'studentId': studentId,
      'status': status,
      'coverLetter': coverLetter,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  /// Copier avec modification
  InternshipApplication copyWith({
    String? status,
    String? coverLetter,
  }) {
    return InternshipApplication(
      id: id,
      internshipId: internshipId,
      studentId: studentId,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      appliedAt: appliedAt,
    );
  }

  /// Vérifier si la candidature est en attente
  bool get isPending => status == 'pending';

  /// Vérifier si la candidature est acceptée
  bool get isAccepted => status == 'accepted';

  /// Vérifier si la candidature est rejetée
  bool get isRejected => status == 'rejected';

  /// Obtenir le label du statut en français
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Refusée';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'InternshipApplication(id: $id, internshipId: $internshipId, studentId: $studentId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InternshipApplication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
