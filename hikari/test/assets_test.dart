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

  test('пиксельный макет главной доступен в бандле', () async {
    await rootBundle.load('assets/design/hikari-light-concept.png');
  });
}
