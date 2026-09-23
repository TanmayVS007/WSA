enum UserRole {
  wearableOwner,
  trustedContact,
  nearbyHelper,
}

class UserEntity {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? deviceId;
  final DateTime createdAt;

  const UserEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.deviceId,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? deviceId,
    DateTime? createdAt,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
