import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisnap/core/services/firebase_auth_service.dart';
import 'package:nutrisnap/features/nutrition/data/repositories/nutrisnap_repository_impl.dart';
import 'package:nutrisnap/main.dart';

void main() {
  group('NutriSnap End-to-End Application Flow Integration Tests', () {
    testWidgets('Full flow: Splash -> Onboarding -> Scanner -> Detail Screen', (tester) async {
      // Configure 390x844 mobile viewport as specified in requirements
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final auth = FirebaseAuthServiceImpl();
      final repo = NutriSnapRepositoryImpl();

      await tester.pumpWidget(
        NutriSnapApp(
          authService: auth,
          repository: repo,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Splash Screen
      expect(find.text('เริ่มต้นใช้งาน'), findsOneWidget);
      expect(find.text('ปัญญาประดิษฐ์ด้านโภชนาการ'), findsOneWidget);

      // 2. Navigate to Onboarding
      final startBtn = find.text('เริ่มต้นใช้งาน');
      await tester.ensureVisible(startBtn);
      await tester.tap(startBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('วิเคราะห์สารอาหารอย่างชาญฉลาด'), findsOneWidget);
      expect(find.text('ฟีเจอร์ถัดไป'), findsOneWidget);

      // 3. Skip Onboarding to Main Shell
      final skipBtn = find.text('ข้าม');
      await tester.tap(skipBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 4. Main App Shell loaded (Default AI Camera)
      expect(find.text('กล้อง AI'), findsOneWidget);
      expect(find.text('Gemini 1.5 Flash Vision'), findsOneWidget);

      // 5. Navigate to Barcode Scanner
      final scannerTab = find.text('สแกนเนอร์');
      await tester.tap(scannerTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('ระบบตรวจจับบาร์โค้ดสด'), findsOneWidget);
      expect(find.text('8850188800123'), findsOneWidget);

      // 6. Tap "ดูข้อมูลโภชนาการฉบับเต็ม"
      final detailBtn = find.text('ดูข้อมูลโภชนาการฉบับเต็ม');
      await tester.tap(detailBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 7. Verify Nutrition Detail Screen
      expect(find.text('ข้อมูลโภชนาการฉบับเต็ม'), findsOneWidget);
      expect(find.text('น้ำมะพร้าวสดออร์แกนิก 100%'), findsWidgets);
      expect(find.text('สารอาหารหลัก (Macronutrients)'), findsOneWidget);
      expect(find.text('บันทึกลงสมุดบันทึกอาหารประจำวัน'), findsOneWidget);

      // 8. Tap Save to Log
      final saveBtn = find.text('บันทึกลงสมุดบันทึกอาหารประจำวัน');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('บันทึก "น้ำมะพร้าวสดออร์แกนิก 100%" ในบันทึกอาหารแล้ว'), findsOneWidget);
    });
  });
}
