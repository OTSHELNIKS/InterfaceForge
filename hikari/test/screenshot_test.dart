import 'dart:io';
import 'dart:convert';
import 'package:hikari/data/models/catalog_data.dart';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikari/app/app.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/app/router.dart';
import 'package:hikari/features/catalog/widgets/item_card.dart';
import 'package:hikari/core/widgets/hero_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Скриншоты для визуальной проверки дизайна.
/// Запуск: flutter test test/screenshot_test.dart
Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  await _desktop('desktop_home', (tester) async {});
  await _desktop('desktop_catalog', (tester) async {
    await tester.tap(find.text('Каталог').hitTestable().first);
    await _waitFor(tester, find.byType(ItemCard));
  });
  await _desktop('desktop_detail', (tester) async {
    await tester.tap(find.text('Каталог').hitTestable().first);
    await _waitFor(tester, find.byType(ItemCard));
    await tester.tap(find.byType(ItemCard).hitTestable().first);
    await tester.pump(const Duration(milliseconds: 900));
  });
  await _desktop('desktop_settings', (tester) async {
    await tester.tap(find.text('Настройки').hitTestable().first);
    await tester.pump(const Duration(milliseconds: 900));
  });

  await _mobile('mobile_home', (tester) async {});
  await _mobile('mobile_catalog', (tester) async {
    await tester.tap(find.text('Каталог').hitTestable().first);
    await _waitFor(tester, find.byType(ItemCard));
  });
  await _mobile('mobile_detail', (tester) async {
    await tester.tap(find.text('Каталог').hitTestable().first);
    await _waitFor(tester, find.byType(ItemCard));
    await tester.tap(find.byType(ItemCard).hitTestable().first);
    await tester.pump(const Duration(milliseconds: 900));
  });
  await _mobile('mobile_settings', (tester) async {
    await tester.tap(find.text('Настройки').hitTestable().first);
    await tester.pump(const Duration(milliseconds: 900));
  });
}

Future<void> _desktop(String name, Future<void> Function(WidgetTester) action) async {
  testWidgets('screenshot $name', (tester) async {
    await _pump(tester, const Size(1440, 900));
    await action(tester);
    await _capture(tester, name);
  });
}

Future<void> _mobile(String name, Future<void> Function(WidgetTester) action) async {
  testWidgets('screenshot $name', (tester) async {
    await _pump(tester, const Size(430, 932));
    await action(tester);
    await _capture(tester, name);
  });
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogProvider.overrideWith((ref) async => CatalogData.fromJson(jsonDecode(File('assets/catalog/catalog.json').readAsStringSync()) as Map<String, dynamic>)),
      ],
      child: const RepaintBoundary(
        key: Key('screenshot-root'),
        child: HikariApp(),
      ),
    ),
  );
  final container = ProviderScope.containerOf(tester.element(find.byType(HikariApp)));
  container.read(routerProvider).go('/home');
  await tester.pump(const Duration(milliseconds: 120));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 900)));
  await tester.pump(const Duration(milliseconds: 300));
  await _waitFor(tester, find.byType(HeroHeader));
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 80; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('screenshot-root')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('preview/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<void> _loadFonts() async {
  final fonts = <String, List<String>>{
    'Inter': [
      'Inter-Regular-subset.ttf',
      'Inter-Medium-subset.ttf',
      'Inter-SemiBold-subset.ttf',
      'Inter-Bold-subset.ttf',
    ],
    'PlayfairDisplay': [
      'PlayfairDisplay-Regular-subset.ttf',
      'PlayfairDisplay-SemiBold-subset.ttf',
      'PlayfairDisplay-Bold-subset.ttf',
    ],
    'CaveatBrush': ['CaveatBrush-Regular-subset.ttf'],
    'YujiSyuku': ['YujiSyuku-Regular-subset.ttf'],
    'ShipporiMincho': [
      'ShipporiMincho-Regular-subset.ttf',
      'ShipporiMincho-SemiBold-subset.ttf',
    ],
  };
  for (final entry in fonts.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/fonts/$file'));
    }
    await loader.load();
  }
}
