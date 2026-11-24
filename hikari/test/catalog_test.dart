import 'package:flutter_test/flutter_test.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/catalog_filters.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/data/repositories/catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogData data;

  setUpAll(() async {
    data = await const CatalogRepository().load();
  });

  test('каталог содержит 16 работ и 4 коллекции', () {
    expect(data.items.length, 16);
    expect(data.collections.length, 4);
    expect(data.items.where((i) => i.isTheme).length, 8);
    expect(data.items.where((i) => !i.isTheme).length, 8);
  });

  test('поиск по тегу', () {
    final filters = const CatalogFilters(query: 'сакура');
    final result = filters.apply(data.items, data);
    expect(result, isNotEmpty);
    expect(result.every((i) => i.tags.contains('сакура')), isTrue);
  });

  test('поиск по названию без учёта регистра', () {
    final filters = const CatalogFilters(query: 'yozakura');
    final result = filters.apply(data.items, data);
    expect(result.map((e) => e.id), contains('yozakura'));
  });

  test('поиск по HEX-цвету', () {
    final filters = const CatalogFilters(query: '#C9362B');
    final result = filters.apply(data.items, data);
    expect(result, isNotEmpty);
    expect(
      result.every((i) => i.colors.any((c) =>
          c.toARGB32().toRadixString(16).toUpperCase().contains('C9362B'))),
      isTrue,
    );
  });

  test('фильтр по типу «тема»', () {
    final filters = const CatalogFilters(type: HikariItemType.theme);
    final result = filters.apply(data.items, data);
    expect(result.length, 8);
    expect(result.every((i) => i.isTheme), isTrue);
  });

  test('фильтр по коллекции', () {
    final filters = const CatalogFilters(collection: 'aoi');
    final result = filters.apply(data.items, data);
    expect(result.length, 4);
    expect(result.every((i) => i.collectionId == 'aoi'), isTrue);
  });

  test('сортировка по алфавиту', () {
    final filters = const CatalogFilters(sort: CatalogSort.alphabetical);
    final result = filters.apply(data.items, data);
    expect(result.first.title, 'Ai no Kawa');
  });

  test('сортировка по популярности', () {
    final filters = const CatalogFilters(sort: CatalogSort.popular);
    final result = filters.apply(data.items, data);
    expect(result.first.popularity, 96);
  });

  test('обои дня детерминированы', () {
    expect(data.wallpaperOfDay, isNotNull);
    expect(data.wallpaperOfDay!.isTheme, isFalse);
  });
}
