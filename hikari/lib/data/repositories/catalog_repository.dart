import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hikari/data/models/catalog_data.dart';

/// Загружает каталог из `assets/catalog/catalog.json`.
class CatalogRepository {
  const CatalogRepository();

  static const String assetPath = 'assets/catalog/catalog.json';

  Future<CatalogData> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Каталог должен быть JSON-объектом');
    }
    return CatalogData.fromJson(decoded);
  }
}
