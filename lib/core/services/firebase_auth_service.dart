import 'dart:async';
import 'package:nutrisnap/core/utils/result.dart';
import 'package:nutrisnap/features/auth/domain/models/user_model.dart';

/// Service contract for Firebase Authentication
abstract class FirebaseAuthService {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  Future<Result<UserModel>> signInWithEmailAndPassword(String email, String password);
  Future<Result<UserModel>> signUpWithEmailAndPassword(String email, String password, {String? displayName});
  Future<Result<UserModel>> signInAnonymously();
  Future<Result<void>> signOut();
  Future<Result<UserModel>> updateProfile({String? displayName, String? photoUrl, double? dailyCalorieTarget});
}

/// Firebase Auth implementation supporting local simulation and Cloud Firebase bridge
class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  FirebaseAuthServiceImpl({UserModel? initialUser}) {
    _currentUser = initialUser;
    // Notify after microtask
    Future.microtask(() => _authStateController.add(_currentUser));
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (email.isEmpty || !email.contains('@')) {
      return Result.failure('กรุณากรอกอีเมลให้ถูกต้อง');
    }
    if (password.length < 6) {
      return Result.failure('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร');
    }

    final user = UserModel(
      id: 'usr_${email.replaceAll('@', '_').replaceAll('.', '_')}',
      email: email,
      displayName: email.split('@').first,
      isAnonymous: false,
      dailyCalorieTarget: 2000.0,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _authStateController.add(_currentUser);
    return Result.success(user);
  }

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (email.isEmpty || !email.contains('@')) {
      return Result.failure('รูปแบบอีเมลไม่ถูกต้อง');
    }
    if (password.length < 6) {
      return Result.failure('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร');
    }

    final user = UserModel(
      id: 'usr_${email.replaceAll('@', '_').replaceAll('.', '_')}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      isAnonymous: false,
      dailyCalorieTarget: 2000.0,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _authStateController.add(_currentUser);
    return Result.success(user);
  }

  @override
  Future<Result<UserModel>> signInAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final guest = UserModel.guest();
    _currentUser = guest;
    _authStateController.add(_currentUser);
    return Result.success(guest);
  }

  @override
  Future<Result<void>> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
    _authStateController.add(null);
    return Result.success(null);
  }

  @override
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoUrl,
    double? dailyCalorieTarget,
  }) async {
    if (_currentUser == null) {
      return Result.failure('ไม่มีผู้ใช้ที่เข้าสู่ระบบ');
    }

    final updated = _currentUser!.copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
      dailyCalorieTarget: dailyCalorieTarget,
    );
    _currentUser = updated;
    _authStateController.add(_currentUser);
    return Result.success(updated);
  }

  void dispose() {
    _authStateController.close();
  }
}
