import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutrisnap/core/services/firebase_auth_service.dart';
import 'package:nutrisnap/features/auth/presentation/providers/auth_provider.dart';
import 'package:nutrisnap/features/camera/presentation/screens/ai_food_camera_screen.dart';
import 'package:nutrisnap/features/nutrition/data/repositories/nutrisnap_repository_impl.dart';
import 'package:nutrisnap/features/nutrition/presentation/providers/nutrition_provider.dart';

void main() {
  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: FirebaseAuthServiceImpl())),
        ChangeNotifierProvider(create: (_) => NutritionProvider(repository: NutriSnapRepositoryImpl())),
      ],
      child: const MaterialApp(
        home: AiFoodCameraScreen(),
      ),
    );
  }

  group('AiFoodCameraScreen Widget Tests', () {
    testWidgets('renders Figma Screen 6 camera interface', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Top model selector pill
      expect(find.text('Gemini 1.5 Flash Vision'), findsOneWidget);

      // Detection status pill
      expect(find.text('กำลังตรวจจับ: ผัดกะเพราไข่ดาว • พร้อมถ่าย'), findsOneWidget);

      // Lighting hint
      expect(find.text('แสงสว่างที่เพียงพอช่วยเพิ่มความแม่นยำในการคำนวณโภชนาการ'), findsOneWidget);

      // Camera controls
      expect(find.text('คลังภาพ'), findsOneWidget);
      expect(find.text('สลับกล้อง'), findsOneWidget);

      // Bottom sheet peek
      expect(find.text('สแกนสารอาหารสด'), findsOneWidget);
      expect(find.text('ประมาณการอัตโนมัติ: เปิดใช้งาน'), findsOneWidget);
    });

    testWidgets('tapping shutter button triggers analysis bottom sheet', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find the circular shutter button (by camera icon)
      final shutterIcon = find.byIcon(Icons.camera_alt_rounded);
      expect(shutterIcon, findsOneWidget);

      await tester.tap(shutterIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Analysis bottom sheet should appear
      expect(find.text('ผลวิเคราะห์ Gemini AI'), findsOneWidget);
      expect(find.text('ผัดกะเพราไข่ดาว'), findsOneWidget);
      expect(find.text('550 kcal'), findsOneWidget);
      expect(find.text('28g'), findsOneWidget); // protein
    });
  });
}
