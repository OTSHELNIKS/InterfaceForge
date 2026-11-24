import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/data/models/device_info.dart';
import 'package:hikari/data/models/catalog_data.dart';

export 'package:hikari/data/models/catalog_data.dart';
export 'package:hikari/data/models/catalog_filters.dart';
export 'package:hikari/data/models/device_info.dart';
export 'package:hikari/data/models/hikari_collection.dart';
export 'package:hikari/data/models/hikari_item.dart';

/// Удобные расширения для каталога.
extension CatalogDataX on CatalogData {
  HikariItem? get wallpaperOfDay {
    final list = wallpapers;
    if (list.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return list[dayOfYear % list.length];
  }
}

extension DeviceInfoX on DeviceInfo {
  bool get isDesktop => platform.toLowerCase().contains('windows') || platform.toLowerCase().contains('mac') || platform.toLowerCase().contains('linux');
}
