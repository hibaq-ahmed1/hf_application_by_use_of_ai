enum UserRole { seeker, owner, admin }

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String password;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.password,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.seeker:
        return 'House Seeker';
      case UserRole.owner:
        return 'Owner / Agent';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
