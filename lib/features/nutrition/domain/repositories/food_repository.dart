import '../../../../core/utils/result.dart';
import '../models/food_item.dart';

/// Abstract contract for Food Data Repository (implemented by Hive and Firestore)
abstract class FoodRepository {
  Future<Result<void>> saveFoodItem(FoodItem item);
  Future<Result<FoodItem?>> getFoodItemById(String id);
  Future<Result<FoodItem?>> getFoodItemByBarcode(String barcode);
  Future<Result<List<FoodItem>>> getAllFoodItems();
  Future<Result<List<FoodItem>>> getRecentScans({int limit = 20});
  Future<Result<void>> deleteFoodItem(String id);
  Future<Result<void>> toggleFavorite(String id);
  Future<Result<void>> clearAll();
}
