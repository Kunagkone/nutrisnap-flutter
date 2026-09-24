import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutrisnap/core/services/firebase_auth_service.dart';
import 'package:nutrisnap/features/auth/presentation/providers/auth_provider.dart';
import 'package:nutrisnap/features/home/presentation/screens/main_shell_screen.dart';
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
        home: MainShellScreen(),
      ),
    );
  }

  group('MainShellScreen Widget Tests', () {
    testWidgets('renders bottom navigation with 4 tabs and switches', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check bottom navigation tabs
      expect(find.text('กล้อง AI'), findsOneWidget);
      expect(find.text('สแกนเนอร์'), findsOneWidget);
      expect(find.text('ประวัติ'), findsOneWidget);
      expect(find.text('โปรไฟล์'), findsOneWidget);

      // Switch to Scanner tab
      await tester.tap(find.text('สแกนเนอร์'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ระบบตรวจจับบาร์โค้ดสด'), findsOneWidget);

      // Switch to History tab
      await tester.tap(find.text('ประวัติ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ประวัติการสแกนและโภชนาการ'), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(find.text('โปรไฟล์'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('โปรไฟล์และตั้งค่า'), findsOneWidget);
      expect(find.text('Gemini API Integration'), findsOneWidget);
    });
  });
}
