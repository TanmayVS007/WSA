import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserEntity? _currentUser = UserEntity(
    userId: 'usr_owner_demo',
    name: 'Ananya Sharma',
    email: 'ananya@example.com',
    phone: '+91 98765 43210',
    role: UserRole.wearableOwner,
    deviceId: 'wsb_esp32_78a1',
    createdAt: DateTime(2026, 8, 15),
  );

  @override
  Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserEntity(
      userId: 'usr_owner_demo',
      name: 'Ananya Sharma',
      email: email,
      phone: '+91 98765 43210',
      role: UserRole.wearableOwner,
      deviceId: 'wsb_esp32_78a1',
      createdAt: DateTime(2026, 8, 15),
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserEntity(
      userId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      deviceId: role == UserRole.wearableOwner ? 'wsb_esp32_78a1' : null,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
