import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/app.dart';
import 'package:hikari/app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> launch(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HikariApp(),
    ));
    await tester.pumpAndSettle();
  }

  for (final width in <double>[320, 390, 768, 1223]) {
    testWidgets('home reflows at $width', (tester) async {
      await launch(tester, Size(width, 844));
      expect(find.text('Красота\nв простых вещах'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('desktop navigation, sidebar and detail', (tester) async {
    await launch(tester, const Size(1223, 844));
    await tester.tap(find.byTooltip('Свернуть меню'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Развернуть меню'), findsOneWidget);
    expect(find.byTooltip('Каталог превью'), findsNothing);
    await tester.tap(find.byTooltip('Развернуть меню'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Каталог превью'));
    await tester.pumpAndSettle();
    expect(find.text('Каталог'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey<String>('work-akane-no-sora')));
    await tester.pumpAndSettle();
    expect(find.text('Скачать превью'), findsOneWidget);
    expect(find.text('Превью JPEG · 173 × 99 пикселей'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallpaper format and favorites reflect the chosen original', (tester) async {
    await launch(tester, const Size(1223, 844));
    await tester.tap(find.text('Обои').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('wallpaper-akane-no-sora')));
    await tester.pumpAndSettle();
    expect(find.text('Скачать обои'), findsOneWidget);
    await tester.tap(find.text('Телефон · 1080 × 1920'));
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Телефон · 1080 × 1920')).selected, isTrue);
    await tester.tap(find.byTooltip('Добавить обои в избранное'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Избранное').first);
    await tester.pumpAndSettle();
    expect(find.text('Akane no Sora'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallpaper catalog keeps filters on return', (tester) async {
    await launch(tester, const Size(1223, 844));
    await tester.tap(find.text('Обои').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Для телефона'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'сакура');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Somei-yoshino'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('wallpaper-somei-yoshino')));
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Телефон · 1080 × 1920')).selected, isTrue);
    await tester.tap(find.text('Назад к списку'));
    await tester.pumpAndSettle();
    expect(find.text('Somei-yoshino'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Для телефона')).selected, isTrue);
    expect(find.text('Akane no Sora'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile drawer opens and navigates', (tester) async {
    await launch(tester, const Size(390, 844));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Коллекции').last);
    await tester.pumpAndSettle();
    expect(find.text('Четыре настроения японской эстетики. Выберите подборку, чтобы увидеть её работы.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile navigation, search and favorites', (tester) async {
    await launch(tester, const Size(390, 844));
    await tester.tap(find.byTooltip('Каталог'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'сакура');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Весеннее отражение'), findsOneWidget);
    expect(find.text('Утро в Киото'), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey<String>('work-somei-yoshino')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Добавить в избранное').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Удалить из избранного'), findsOneWidget);
    await tester.tap(find.byTooltip('Избранное'));
    await tester.pumpAndSettle();
    expect(find.text('Весеннее отражение'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
