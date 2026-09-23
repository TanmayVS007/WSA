import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists && doc.data() != null) {
        return _mapDocToUserEntity(doc.id, doc.data()!, firebaseUser);
      }
    } catch (_) {
      // Fallback to basic Firebase user if Firestore document is unavailable
    }

    return UserEntity(
      userId: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      role: UserRole.wearableOwner,
      deviceId: 'wsb_esp32_78a1',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed: User data not found.');
      }

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists && doc.data() != null) {
        return _mapDocToUserEntity(doc.id, doc.data()!, firebaseUser);
      }

      return UserEntity(
        userId: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? email,
        phone: firebaseUser.phoneNumber ?? '',
        role: UserRole.wearableOwner,
        deviceId: 'wsb_esp32_78a1',
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed: User not created.');
      }

      await firebaseUser.updateDisplayName(name);

      final now = DateTime.now();
      final deviceId = role == UserRole.wearableOwner ? 'wsb_esp32_78a1' : null;

      final userData = {
        'userId': firebaseUser.uid,
        'name': name,
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role.name,
        'deviceId': deviceId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

      return UserEntity(
        userId: firebaseUser.uid,
        name: name,
        email: email.trim(),
        phone: phone.trim(),
        role: role,
        deviceId: deviceId,
        createdAt: now,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  UserEntity _mapDocToUserEntity(
    String docId,
    Map<String, dynamic> data,
    User firebaseUser,
  ) {
    UserRole role = UserRole.wearableOwner;
    final roleStr = data['role'] as String?;
    if (roleStr == UserRole.trustedContact.name) {
      role = UserRole.trustedContact;
    } else if (roleStr == UserRole.nearbyHelper.name) {
      role = UserRole.nearbyHelper;
    }

    DateTime createdAt = DateTime.now();
    final ts = data['createdAt'];
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    }

    return UserEntity(
      userId: docId,
      name: (data['name'] as String?) ?? firebaseUser.displayName ?? 'User',
      email: (data['email'] as String?) ?? firebaseUser.email ?? '',
      phone: (data['phone'] as String?) ?? firebaseUser.phoneNumber ?? '',
      role: role,
      deviceId: data['deviceId'] as String?,
      createdAt: createdAt,
    );
  }

  String _mapAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify and try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'network-request-failed':
        return 'Network connection error. Check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
