import 'food_item.dart';

/// Structured response model from Gemini AI Vision analysis.
class NutritionAnalysisResult {
  final String foodName;
  final String estimatedPortion;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double sugar;
  final double fiber;
  final double confidence; // 0.0 - 1.0
  final String healthScore; // 'เกรด A', 'เกรด B', etc.
  final List<String> detectedIngredients;
  final String advice;
  final DateTime analyzedAt;

  const NutritionAnalysisResult({
    required this.foodName,
    required this.estimatedPortion,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.sugar = 0.0,
    this.fiber = 0.0,
    required this.confidence,
    required this.healthScore,
    this.detectedIngredients = const [],
    this.advice = '',
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'estimatedPortion': estimatedPortion,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'sugar': sugar,
      'fiber': fiber,
      'confidence': confidence,
      'healthScore': healthScore,
      'detectedIngredients': detectedIngredients,
      'advice': advice,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory NutritionAnalysisResult.fromMap(Map<String, dynamic> map) {
    return NutritionAnalysisResult(
      foodName: map['foodName']?.toString() ?? 'อาหารที่ตรวจจับได้',
      estimatedPortion: map['estimatedPortion']?.toString() ?? '1 จาน (300g)',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbohydrates: (map['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.9,
      healthScore: map['healthScore']?.toString() ?? 'เกรด B',
      detectedIngredients: (map['detectedIngredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      advice: map['advice']?.toString() ?? '',
      analyzedAt: map['analyzedAt'] != null
          ? DateTime.tryParse(map['analyzedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts AI result into a persistent FoodItem entity
  FoodItem toFoodItem({String? customId}) {
    return FoodItem(
      id: customId ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
      name: foodName,
      brand: 'AI วิเคราะห์',
      servingSize: estimatedPortion,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      sugar: sugar,
      fiber: fiber,
      nutriScore: healthScore.replaceAll('เกรด ', '').trim(),
      scannedAt: analyzedAt,
      ingredients: detectedIngredients,
      source: 'gemini_vision',
    );
  }
}
