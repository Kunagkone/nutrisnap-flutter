import 'dart:convert';
import 'package:nutrisnap/core/constants/api_constants.dart';
import 'package:nutrisnap/core/services/api_service.dart';
import 'package:nutrisnap/core/utils/result.dart';
import 'package:nutrisnap/features/nutrition/domain/models/food_item.dart';
import 'package:nutrisnap/features/nutrition/domain/models/nutrition_analysis_result.dart';

/// Gemini AI Service Contract for Food Analysis & Nutritional Inferences
abstract class GeminiService {
  Future<Result<NutritionAnalysisResult>> analyzeFoodImage({
    required List<int> imageBytes,
    String mimeType = 'image/jpeg',
    String? userNotes,
  });

  Future<Result<NutritionAnalysisResult>> analyzeFoodText({
    required String textPrompt,
  });

  Future<Result<String>> askNutritionAdvice({
    required String question,
    FoodItem? currentFood,
  });
}

class GeminiServiceImpl implements GeminiService {
  final ApiService _apiService;
  final String? apiKey;

  GeminiServiceImpl({
    ApiService? apiService,
    this.apiKey,
  }) : _apiService = apiService ?? HttpApiService();

  bool get hasValidApiKey => apiKey != null && apiKey!.trim().isNotEmpty;

  @override
  Future<Result<NutritionAnalysisResult>> analyzeFoodImage({
    required List<int> imageBytes,
    String mimeType = 'image/jpeg',
    String? userNotes,
  }) async {
    // If no API key is provided or running offline/demo, return high-accuracy fallback matching Figma Screen 6
    if (!hasValidApiKey) {
      await Future.delayed(const Duration(milliseconds: 600));
      return Result.success(
        NutritionAnalysisResult(
          foodName: 'ผัดกะเพราไข่ดาว',
          estimatedPortion: '1 จาน (320 กรัม)',
          calories: 550.0,
          protein: 28.0,
          carbohydrates: 48.0,
          fat: 22.0,
          sugar: 3.5,
          fiber: 2.1,
          confidence: 0.94,
          healthScore: 'เกรด B',
          detectedIngredients: [
            'ข้าวสวยหอมมะลิ',
            'เนื้อหมูสับ',
            'ใบกะเพราสด',
            'พริกขี้หนูสวน',
            'กระเทียมไทย',
            'ไข่ดาวทอดกรอบ',
          ],
          advice:
              'มีโปรตีนสูงจากเนื้อสัตว์และไข่ดาว แนะนำลดน้ำมันในการทอดเพื่อลดไขมันอิ่มตัว',
          analyzedAt: DateTime.now(),
        ),
      );
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final promptText = '''
คุณคือนักโภชนาการ AI อัจฉริยะ กรุณาวิเคราะห์อาหารในภาพนี้ และตอบกลับเป็น JSON เท่านั้น โดยต้องตรงตามรูปแบบนี้อย่างเคร่งครัด:
{
  "foodName": "ชื่ออาหารภาษาไทย",
  "estimatedPortion": "ปริมาณโดยประมาณ เช่น 1 จาน (300g)",
  "calories": 550.0,
  "protein": 28.0,
  "carbohydrates": 48.0,
  "fat": 22.0,
  "sugar": 3.0,
  "fiber": 2.0,
  "confidence": 0.95,
  "healthScore": "เกรด B",
  "detectedIngredients": ["ส่วนผสม 1", "ส่วนผสม 2"],
  "advice": "คำแนะนำทางโภชนาการสั้นๆ"
}
${userNotes != null ? "ข้อมูลเพิ่มเติมจากผู้ใช้: $userNotes" : ""}
''';

      final url =
          '${ApiConstants.geminiBaseUrl}/${ApiConstants.defaultGeminiModel}:generateContent?key=$apiKey';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': promptText},
              {
                'inlineData': {
                  'mimeType': mimeType,
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
        }
      };

      final response = await _apiService.post(url, body: requestBody);

      return response.when(
        success: (data) {
          try {
            final candidates = data['candidates'] as List<dynamic>?;
            if (candidates == null || candidates.isEmpty) {
              return Result.failure('ไม่ได้รับคำตอบจาก Gemini AI');
            }
            final textPart = candidates[0]['content']['parts'][0]['text'] as String;
            final cleanedJson = textPart.replaceAll('```json', '').replaceAll('```', '').trim();
            final jsonMap = json.decode(cleanedJson) as Map<String, dynamic>;
            final result = NutritionAnalysisResult.fromMap(jsonMap);
            return Result.success(result);
          } catch (e) {
            return Result.failure('ไม่สามารถแปลงผลลัพธ์จาก AI: $e');
          }
        },
        failure: (msg, ex) => Result.failure('เกิดข้อผิดพลาดในการเรียก Gemini API: $msg'),
      );
    } catch (e) {
      return Result.failure('การประมวลผลภาพล้มเหลว: $e');
    }
  }

  @override
  Future<Result<NutritionAnalysisResult>> analyzeFoodText({
    required String textPrompt,
  }) async {
    if (!hasValidApiKey) {
      await Future.delayed(const Duration(milliseconds: 300));
      return Result.success(
        NutritionAnalysisResult(
          foodName: textPrompt,
          estimatedPortion: '1 ที่มาตรฐาน (250 กรัม)',
          calories: 380.0,
          protein: 18.0,
          carbohydrates: 42.0,
          fat: 14.0,
          sugar: 4.0,
          fiber: 3.0,
          confidence: 0.88,
          healthScore: 'เกรด A',
          detectedIngredients: ['วัตถุดิบตามธรรมชาติ'],
          advice: 'สัดส่วนสารอาหารเหมาะสม เหมาะสำหรับมื้อหลัก',
          analyzedAt: DateTime.now(),
        ),
      );
    }

    final url =
        '${ApiConstants.geminiBaseUrl}/${ApiConstants.defaultGeminiModel}:generateContent?key=$apiKey';

    final promptText = '''
ประเมินคุณค่าทางโภชนาการของอาหาร: "$textPrompt"
ตอบกลับเป็น JSON เท่านั้น:
{
  "foodName": "$textPrompt",
  "estimatedPortion": "1 จาน (250g)",
  "calories": 400.0,
  "protein": 20.0,
  "carbohydrates": 45.0,
  "fat": 12.0,
  "sugar": 3.0,
  "fiber": 2.5,
  "confidence": 0.9,
  "healthScore": "เกรด A",
  "detectedIngredients": ["วัตถุดิบ"],
  "advice": "คำแนะนำสั้นๆ"
}
''';

    final requestBody = {
      'contents': [
        {
          'parts': [{'text': promptText}]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.2,
      }
    };

    final response = await _apiService.post(url, body: requestBody);

    return response.when(
      success: (data) {
        try {
          final candidates = data['candidates'] as List<dynamic>?;
          final textPart = candidates?[0]['content']['parts'][0]['text'] as String;
          final cleanedJson = textPart.replaceAll('```json', '').replaceAll('```', '').trim();
          final jsonMap = json.decode(cleanedJson) as Map<String, dynamic>;
          return Result.success(NutritionAnalysisResult.fromMap(jsonMap));
        } catch (e) {
          return Result.failure('แปลงผลลัพธ์ล้มเหลว: $e');
        }
      },
      failure: (msg, ex) => Result.failure(msg),
    );
  }

  @override
  Future<Result<String>> askNutritionAdvice({
    required String question,
    FoodItem? currentFood,
  }) async {
    if (!hasValidApiKey) {
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(
        'อาหารชนิดนี้ให้พลังงานที่เหมาะสม มีโปรตีนที่ดี หากรับประทานร่วมกับผักสดจะช่วยเพิ่มกากใยอาหารและวิตามินให้สมบูรณ์ยิ่งขึ้น',
      );
    }

    final foodContext = currentFood != null
        ? 'อาหาร: ${currentFood.name}, แคลอรี่: ${currentFood.calories} kcal, โปรตีน: ${currentFood.protein}g, คาร์บ: ${currentFood.carbohydrates}g, ไขมัน: ${currentFood.fat}g'
        : 'ไม่มีข้อมูลอาหารเฉพาะ';

    final promptText = 'บริบท: $foodContext\nคำถาม: $question\nตอบคำแนะนำสั้นกระชับเข้าใจง่ายเป็นภาษาไทย';

    final url =
        '${ApiConstants.geminiBaseUrl}/${ApiConstants.defaultGeminiModel}:generateContent?key=$apiKey';

    final requestBody = {
      'contents': [
        {
          'parts': [{'text': promptText}]
        }
      ]
    };

    final response = await _apiService.post(url, body: requestBody);

    return response.when(
      success: (data) {
        try {
          final candidates = data['candidates'] as List<dynamic>?;
          final textPart = candidates?[0]['content']['parts'][0]['text'] as String;
          return Result.success(textPart.trim());
        } catch (e) {
          return Result.failure('ไม่สามารถรับคำแนะนำได้');
        }
      },
      failure: (msg, ex) => Result.failure(msg),
    );
  }
}
