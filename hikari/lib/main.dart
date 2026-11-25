import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/app.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/features/home/design_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  // Миграция: раньше по умолчанию был «системный» режим, из-за которого
  // тёмная ОС внезапно делала интерфейс почти чёрным. Теперь база — светлая.
  if (prefs.getString('hikari.themeMode') == 'system') {
    await prefs.setString('hikari.themeMode', 'light');
  }

  // В выбранном макете несколько сердечек уже отмечены. Это обычное состояние
  // «Избранное», а не декоративная картинка: пользователь может его изменить.
  if (!prefs.containsKey('hikari.favorites')) {
    await prefs.setStringList('hikari.favorites', kDesignFeaturedFavorites);
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HikariApp(),
    ),
  );

  // Flutter Web по умолчанию не строит семантическое дерево из-за стоимости.
  // Включаем его сразу, чтобы тексты и элементы были доступны screen reader'ам,
  // браузерным инструментам и автоматизированным QA-проверкам.
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
}
