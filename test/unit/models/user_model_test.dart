import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisnap/features/auth/domain/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final now = DateTime(2026, 9, 24, 12, 0, 0);

    test('UserModel guest creates anonymous guest profile', () {
      final guest = UserModel.guest();
      expect(guest.isAnonymous, isTrue);
      expect(guest.displayName, 'ผู้ใช้ทั่วไป');
      expect(guest.dailyCalorieTarget, 2000.0);
    });

    test('toMap and fromMap should work correctly', () {
      final user = UserModel(
        id: 'usr_1',
        email: 'user@example.com',
        displayName: 'Somchai',
        photoUrl: 'https://example.com/photo.png',
        isAnonymous: false,
        dailyCalorieTarget: 2200.0,
        createdAt: now,
      );

      final map = user.toMap();
      final fromMap = UserModel.fromMap(map);

      expect(fromMap.id, user.id);
      expect(fromMap.email, user.email);
      expect(fromMap.displayName, user.displayName);
      expect(fromMap.dailyCalorieTarget, 2200.0);
      expect(fromMap.isAnonymous, isFalse);
    });

    test('copyWith updates specified fields', () {
      final user = UserModel.guest();
      final updated = user.copyWith(
        displayName: 'New Name',
        dailyCalorieTarget: 1800.0,
      );

      expect(updated.displayName, 'New Name');
      expect(updated.dailyCalorieTarget, 1800.0);
      expect(updated.isAnonymous, isTrue);
    });
  });
}
