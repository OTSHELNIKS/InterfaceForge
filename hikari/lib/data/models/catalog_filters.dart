import 'package:material_ui/material_ui.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/hikari_item.dart';

enum CatalogSort {
  newest,
  popular,
  alphabetical;

  String get label => switch (this) {
        CatalogSort.newest => 'Сначала новые',
        CatalogSort.popular => 'По популярности',
        CatalogSort.alphabetical => 'По алфавиту',
      };

  IconData get icon => switch (this) {
        CatalogSort.newest => Icons.schedule_rounded,
        CatalogSort.popular => Icons.local_fire_department_rounded,
        CatalogSort.alphabetical => Icons.sort_by_alpha_rounded,
      };
}

@immutable
class CatalogFilters {
  const CatalogFilters({
    this.query = '',
    this.type,
    this.collection,
    this.sort = CatalogSort.newest,
  });

  final String query;
  final HikariItemType? type;
  final String? collection;
  final CatalogSort sort;

  bool get isEmpty => query.trim().isEmpty && type == null && collection == null;

  CatalogFilters copyWith({
    String? query,
    Object? type = _unset,
    Object? collection = _unset,
    CatalogSort? sort,
  }) {
    return CatalogFilters(
      query: query ?? this.query,
      type: identical(type, _unset) ? this.type : type as HikariItemType?,
      collection: identical(collection, _unset) ? this.collection : collection as String?,
      sort: sort ?? this.sort,
    );
  }

  CatalogFilters clear() => const CatalogFilters();

  /// Применяет поиск, фильтры и сортировку к списку работ.
  List<HikariItem> apply(List<HikariItem> source, CatalogData data) {
    final normalized = _normalize(query);
    var result = source.where((item) {
      if (type != null && item.type != type) return false;
      if (collection != null && item.collectionId != collection) return false;
      if (normalized.isEmpty) return true;
      return _matches(item, normalized, data);
    }).toList();

    switch (sort) {
      case CatalogSort.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
      case CatalogSort.popular:
        result.sort((a, b) => b.popularity.compareTo(a.popularity));
      case CatalogSort.alphabetical:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return result;
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  static bool _matches(HikariItem item, String q, CatalogData data) {
    if (item.title.toLowerCase().contains(q)) return true;
    if (item.titleJa.toLowerCase().contains(q)) return true;
    if (item.description.toLowerCase().contains(q)) return true;
    if (item.type.label.toLowerCase().contains(q)) return true;
    final collection = data.collectionById(item.collectionId);
    if (collection != null) {
      if (collection.name.toLowerCase().contains(q)) return true;
      if (collection.nameJa.toLowerCase().contains(q)) return true;
    }
    for (final tag in item.tags) {
      if (tag.toLowerCase().contains(q)) return true;
    }
    // Поиск по цвету: «#C9362B», «c9362b», «c936».
    final hexQuery = q.replaceAll('#', '').trim();
    if (hexQuery.length >= 2 && RegExp(r'^[0-9a-f]+$').hasMatch(hexQuery)) {
      for (final color in item.colors) {
        final hex = _hex(color);
        if (hex.contains(hexQuery)) return true;
      }
    }
    return false;
  }

  static String _hex(Color color) {
    final v = color.toARGB32() & 0xFFFFFF;
    return v.toRadixString(16).padLeft(6, '0');
  }
}

const Object _unset = Object();
