/// Modèle de données pour un utilisateur
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? bio;
  final String? photo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.bio,
    this.photo,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Convertit l'objet User en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'bio': bio,
      'photo': photo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  /// Crée un objet User à partir d'une Map SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      role: map['role'] as String,
      bio: map['bio'] as String?,
      photo: map['photo'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
      isActive: (map['isActive'] as int) == 1,
    );
  }

  /// Convertit l'objet User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'bio': bio,
      'photo': photo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Crée un objet User à partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      bio: json['bio'] as String?,
      photo: json['photo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Crée une copie de l'objet User avec des modifications
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? bio,
    String? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
