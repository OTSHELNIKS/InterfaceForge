import 'package:hikari/data/models/hikari_collection.dart';
import 'package:hikari/data/models/hikari_item.dart';

/// Весь каталог: коллекции и работы.
class CatalogData {
  const CatalogData({
    required this.version,
    required this.collections,
    required this.items,
  });

  final int version;
  final List<HikariCollection> collections;
  final List<HikariItem> items;

  factory CatalogData.fromJson(Map<String, dynamic> json) {
    return CatalogData(
      version: json['version'] as int? ?? 1,
      collections: (json['collections'] as List)
          .map((e) => HikariCollection.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      items: (json['items'] as List)
          .map((e) => HikariItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  HikariCollection? collectionById(String id) {
    for (final c in collections) {
      if (c.id == id) return c;
    }
    return null;
  }

  HikariItem? itemById(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<HikariItem> get wallpapers =>
      items.where((i) => i.type == HikariItemType.wallpaper).toList(growable: false);

  List<HikariItem> get themes =>
      items.where((i) => i.type == HikariItemType.theme).toList(growable: false);

  /// Детерминированные «обои дня»: меняются раз в сутки.
  HikariItem? get wallpaperOfDay {
    final list = wallpapers;
    if (list.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return list[dayOfYear % list.length];
  }
}
