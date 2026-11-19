class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.role = 'Pengguna',
  });

  final String id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final String role;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'created_at': createdAt.toIso8601String(),
    'role': role,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String? ?? 'Pengguna',
    );
  }
}
