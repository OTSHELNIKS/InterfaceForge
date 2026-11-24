import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('избранное добавляется и сохраняется', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(favoritesProvider), isEmpty);

    await container.read(favoritesProvider.notifier).toggle('hinomaru');
    expect(container.read(favoritesProvider), {'hinomaru'});
    expect(prefs.getStringList('hikari.favorites'), ['hinomaru']);

    await container.read(favoritesProvider.notifier).toggle('hinomaru');
    expect(container.read(favoritesProvider), isEmpty);
  });

  test('активная тема сохраняется', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await container.read(activeThemeIdProvider.notifier).set('ruri');
    expect(container.read(activeThemeIdProvider), 'ruri');
    expect(prefs.getString('hikari.activeTheme'), 'ruri');

    await container.read(activeThemeIdProvider.notifier).set(null);
    expect(container.read(activeThemeIdProvider), isNull);
  });

  test('режим темы сохраняется', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await container.read(themeModeProvider.notifier).set(ThemeMode.dark);
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(prefs.getString('hikari.themeMode'), 'dark');
  });

  test('тип работы корректно сериализуется', () {
    expect(HikariItemType.theme.jsonName, 'theme');
    expect(HikariItemType.wallpaper.label, 'Обои');
    expect(HikariItemType.theme.applyLabel, 'Применить тему');
  });
}
