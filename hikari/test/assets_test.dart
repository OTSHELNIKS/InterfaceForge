import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikari/data/repositories/catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('все ассеты из каталога доступны в бандле', () async {
    final data = await const CatalogRepository().load();
    expect(data.items, isNotEmpty);

    for (final item in data.items) {
      for (final path in <String>[item.asset, item.assetLandscape]) {
        // Бросит исключение, если ассет отсутствует или не объявлен в pubspec.
        await rootBundle.load(path);
      }
    }
  });

  test('графика собранного макета доступна в бандле', () async {
    for (final path in <String>[
      'assets/design/hero-clean.jpg',
      'assets/design/logo-bird.png',
      'assets/design/decor-blossom.png',
      'assets/design/decor-mountains.png',
      'assets/design/collection-1.jpg',
      'assets/design/work-01.jpg',
      'assets/design/work-16.jpg',
      'assets/design/detail-fuji.jpg',
      'assets/design/similar-1.jpg',
    ]) {
      await rootBundle.load(path);
    }
  });
}
