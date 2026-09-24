import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrisnap/core/database/local/hive_food_repository.dart';
import 'package:nutrisnap/features/nutrition/domain/models/food_item.dart';

class MockHiveBox extends Mock implements Box<Map> {}

void main() {
  group('HiveFoodRepository Tests', () {
    late MockHiveBox mockBox;
    late HiveFoodRepository repository;
    final Map<dynamic, Map> memoryStore = {};

    final sampleFood = FoodItem(
      id: 'food_1',
      barcode: '8850188800123',
      name: 'น้ำมะพร้าวสด',
      calories: 65,
      protein: 1.2,
      carbohydrates: 15,
      fat: 0.2,
      scannedAt: DateTime(2026, 9, 24),
    );

    setUp(() {
      mockBox = MockHiveBox();
      memoryStore.clear();

      when(() => mockBox.put(any(), any())).thenAnswer((inv) async {
        final key = inv.positionalArguments[0];
        final val = inv.positionalArguments[1] as Map;
        memoryStore[key] = val;
      });

      when(() => mockBox.get(any())).thenAnswer((inv) {
        final key = inv.positionalArguments[0];
        return memoryStore[key];
      });

      when(() => mockBox.delete(any())).thenAnswer((inv) async {
        final key = inv.positionalArguments[0];
        memoryStore.remove(key);
      });

      when(() => mockBox.values).thenAnswer((_) => memoryStore.values);
      when(() => mockBox.clear()).thenAnswer((_) async {
        memoryStore.clear();
        return 0;
      });

      repository = HiveFoodRepository(box: mockBox);
    });

    test('saveFoodItem saves to Hive box', () async {
      final res = await repository.saveFoodItem(sampleFood);
      expect(res.isSuccess, isTrue);
      expect(memoryStore.containsKey('food_1'), isTrue);
    });

    test('getFoodItemById retrieves item by ID', () async {
      await repository.saveFoodItem(sampleFood);

      final res = await repository.getFoodItemById('food_1');
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.name, 'น้ำมะพร้าวสด');
    });

    test('getFoodItemByBarcode retrieves item matching barcode', () async {
      await repository.saveFoodItem(sampleFood);

      final res = await repository.getFoodItemByBarcode('8850188800123');
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.barcode, '8850188800123');
    });

    test('getAllFoodItems and getRecentScans return sorted items', () async {
      final food2 = sampleFood.copyWith(
        id: 'food_2',
        name: 'ข้าวผัด',
        scannedAt: DateTime(2026, 9, 24, 13, 0),
      );
      await repository.saveFoodItem(sampleFood);
      await repository.saveFoodItem(food2);

      final all = await repository.getAllFoodItems();
      expect(all.isSuccess, isTrue);
      expect(all.dataOrNull?.length, 2);
      expect(all.dataOrNull?.first.name, 'ข้าวผัด'); // newer first

      final recent = await repository.getRecentScans(limit: 1);
      expect(recent.dataOrNull?.length, 1);
      expect(recent.dataOrNull?.first.id, 'food_2');
    });

    test('toggleFavorite flips favorite state', () async {
      await repository.saveFoodItem(sampleFood);
      expect(memoryStore['food_1']?['isFavorite'], isFalse);

      await repository.toggleFavorite('food_1');
      expect(memoryStore['food_1']?['isFavorite'], isTrue);
    });

    test('deleteFoodItem removes item', () async {
      await repository.saveFoodItem(sampleFood);
      expect(memoryStore.containsKey('food_1'), isTrue);

      await repository.deleteFoodItem('food_1');
      expect(memoryStore.containsKey('food_1'), isFalse);
    });

    test('clearAll clears box', () async {
      await repository.saveFoodItem(sampleFood);
      expect(memoryStore.isNotEmpty, isTrue);

      await repository.clearAll();
      expect(memoryStore.isEmpty, isTrue);
    });
  });
}
