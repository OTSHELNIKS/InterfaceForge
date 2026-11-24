import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/app/router.dart';
import 'package:hikari/core/constants/app_constants.dart';
import 'package:hikari/core/theme/app_theme.dart';
import 'package:hikari/features/shell/app_shell.dart';

/// Корень приложения: тема, роутер и глобальная текстура.
class HikariApp extends ConsumerWidget {
  const HikariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final accent = ref.watch(appAccentProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.build(
        mode: ThemeMode.light,
        platformBrightness: Brightness.light,
        accent: accent,
      ),
      darkTheme: AppTheme.build(
        mode: ThemeMode.dark,
        platformBrightness: Brightness.dark,
        accent: accent,
      ),
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        return GlobalGrain(
          opacity: 0.016,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
