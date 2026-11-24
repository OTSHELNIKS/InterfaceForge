import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/core/services/system_service.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/catalog_filters.dart';
import 'package:hikari/data/models/device_info.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/data/repositories/catalog_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences подменяются в `main`, чтобы провайдеры были тестируемыми.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences не инициализированы');
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return const CatalogRepository();
});

final catalogProvider = FutureProvider<CatalogData>((ref) {
  ref.keepAlive();
  return ref.watch(catalogRepositoryProvider).load();
});

final systemServiceProvider = Provider<SystemService>((ref) {
  return const SystemService();
});

final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  ref.keepAlive();
  try {
    return await ref.watch(systemServiceProvider).deviceInfo();
  } catch (_) {
    return DeviceInfo.fallback;
  }
});

/// Режим оформления: системный / светлый / тёмный.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'hikari.themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Идентификатор применённой темы (null — фирменная палитра Hikari).
class ActiveThemeNotifier extends Notifier<String?> {
  static const String _key = 'hikari.activeTheme';

  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key);
  }

  Future<void> set(String? id) async {
    state = id;
    final prefs = ref.read(sharedPreferencesProvider);
    if (id == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, id);
    }
  }
}

final activeThemeIdProvider =
    NotifierProvider<ActiveThemeNotifier, String?>(ActiveThemeNotifier.new);

/// Полная применённая тема (или null).
final activeThemeProvider = Provider<HikariItem?>((ref) {
  final id = ref.watch(activeThemeIdProvider);
  if (id == null) return null;
  final data = ref.watch(catalogProvider).asData?.value;
  return data?.itemById(id);
});

/// Акцент приложения: цвет активной темы или фирменная киноварь.
final appAccentProvider = Provider<Color>((ref) {
  final active = ref.watch(activeThemeProvider);
  return active?.accent ?? AppColors.vermilion;
});

/// Избранное.
class FavoritesNotifier extends Notifier<Set<String>> {
  static const String _key = 'hikari.favorites';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return {...?prefs.getStringList(_key)};
  }

  bool has(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    await _persist(next);
  }

  Future<void> add(String id) async {
    if (state.contains(id)) return;
    final next = {...state, id};
    state = next;
    await _persist(next);
  }

  Future<void> remove(String id) async {
    if (!state.contains(id)) return;
    final next = {...state}..remove(id);
    state = next;
    await _persist(next);
  }

  Future<void> clear() async {
    state = <String>{};
    await _persist(<String>{});
  }

  Future<void> _persist(Set<String> value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(_key, value.toList(growable: false));
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Фильтры и поиск каталога.
class CatalogFiltersNotifier extends Notifier<CatalogFilters> {
  @override
  CatalogFilters build() => const CatalogFilters();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setType(HikariItemType? type) => state = state.copyWith(type: type);

  void setCollection(String? collection) =>
      state = state.copyWith(collection: collection);

  void setSort(CatalogSort sort) => state = state.copyWith(sort: sort);

  void reset() => state = const CatalogFilters();
}

final catalogFiltersProvider =
    NotifierProvider<CatalogFiltersNotifier, CatalogFilters>(CatalogFiltersNotifier.new);

/// Отфильтрованный и отсортированный список.
final filteredItemsProvider = Provider<AsyncValue<List<HikariItem>>>((ref) {
  final catalog = ref.watch(catalogProvider);
  final filters = ref.watch(catalogFiltersProvider);
  return catalog.whenData((data) => filters.apply(data.items, data));
});

/// Обои дня — детерминированно меняются каждый день.
final wallpaperOfDayProvider = Provider<AsyncValue<HikariItem?>>((ref) {
  return ref.watch(catalogProvider).whenData((data) => data.wallpaperOfDay);
});

/// Избранные работы в порядке каталога.
final favoriteItemsProvider = Provider<AsyncValue<List<HikariItem>>>((ref) {
  final ids = ref.watch(favoritesProvider);
  return ref.watch(catalogProvider).whenData((data) {
    return data.items.where((item) => ids.contains(item.id)).toList(growable: false);
  });
});
