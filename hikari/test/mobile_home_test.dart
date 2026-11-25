import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> openHome(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();
  }

  for (final width in <double>[320, 390, 768]) {
    testWidgets('mobile layout reflows at $width pixels', (tester) async {
      await openHome(tester, Size(width, 844));
      expect(find.text('Красота\nв простых вещах'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.ensureVisible(find.text('Каталог'));
      await tester.pumpAndSettle();
      expect(find.text('Утро в Киото'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('search, detail, favorite and resolution work on mobile', (tester) async {
    await openHome(tester, const Size(390, 844));
    await tester.enterText(find.byType(TextField), 'сакура');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Весеннее отражение'));
    await tester.pumpAndSettle();
    expect(find.text('Утро в Киото'), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('mobile-work-somei-yoshino')));
    await tester.pumpAndSettle();
    expect(find.text('Доступные разрешения'), findsOneWidget);
    await tester.ensureVisible(find.text('Mobile (1080 × 1920)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile (1080 × 1920)'));
    await tester.pumpAndSettle();
    final choice = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Mobile (1080 × 1920)'));
    expect(choice.selected, isTrue);
    await tester.ensureVisible(find.byTooltip('Добавить в избранное').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Добавить в избранное').last);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Удалить из избранного'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
