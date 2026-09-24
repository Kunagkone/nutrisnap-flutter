import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisnap/core/database/cloud/firestore_food_repository.dart';
import 'package:nutrisnap/features/nutrition/domain/models/food_item.dart';

void main() {
  group('FirestoreFoodRepository Tests', () {
    late FirestoreFoodRepository repository;

    final sampleFood = FoodItem(
      id: 'cloud_item_1',
      barcode: '8850188800123',
      name: 'น้ำมะพร้าว',
      calories: 65,
      protein: 1.2,
      carbohydrates: 15,
      fat: 0.2,
      scannedAt: DateTime(2026, 9, 24),
    );

    setUp(() {
      repository = FirestoreFoodRepository(userId: 'test_user_456');
    });

    test('saveFoodItem and getFoodItemById work with cloud store', () async {
      final saveRes = await repository.saveFoodItem(sampleFood);
      expect(saveRes.isSuccess, isTrue);

      final getRes = await repository.getFoodItemById('cloud_item_1');
      expect(getRes.isSuccess, isTrue);
      expect(getRes.dataOrNull?.name, 'น้ำมะพร้าว');
    });

    test('getFoodItemByBarcode retrieves from cloud', () async {
      await repository.saveFoodItem(sampleFood);

      final getRes = await repository.getFoodItemByBarcode('8850188800123');
      expect(getRes.isSuccess, isTrue);
      expect(getRes.dataOrNull?.id, 'cloud_item_1');
    });

    test('getAllFoodItems and syncBatch work properly', () async {
      final item2 = sampleFood.copyWith(id: 'cloud_item_2', name: 'สลัดผัก');
      final syncRes = await repository.syncBatch([sampleFood, item2]);

      expect(syncRes.isSuccess, isTrue);
      expect(syncRes.dataOrNull, 2);

      final all = await repository.getAllFoodItems();
      expect(all.dataOrNull?.length, 2);
    });

    test('toggleFavorite and deleteFoodItem in cloud', () async {
      await repository.saveFoodItem(sampleFood);

      await repository.toggleFavorite('cloud_item_1');
      var item = await repository.getFoodItemById('cloud_item_1');
      expect(item.dataOrNull?.isFavorite, isTrue);

      await repository.deleteFoodItem('cloud_item_1');
      item = await repository.getFoodItemById('cloud_item_1');
      expect(item.dataOrNull, isNull);
    });

    test('clearAll clears cloud store', () async {
      await repository.saveFoodItem(sampleFood);
      await repository.clearAll();
      final all = await repository.getAllFoodItems();
      expect(all.dataOrNull?.isEmpty, isTrue);
    });
  });
}
