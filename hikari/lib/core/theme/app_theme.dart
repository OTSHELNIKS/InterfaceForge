import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';

/// Темы приложения: светлая «васи» и тёмная «суми».
class AppTheme {
  AppTheme._();

  static ThemeData build({
    required ThemeMode mode,
    required Brightness platformBrightness,
    Color accent = AppColors.vermilion,
  }) {
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
    final scheme = _scheme(isDark ? Brightness.dark : Brightness.light, accent);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: AppText.sans,
    );

    final textTheme = _textTheme(isDark, accent).merge(base.textTheme);
    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: TextTheme(
        displayLarge: AppText.display(57, color: AppColors.card),
        displayMedium: AppText.display(45, color: AppColors.card),
        displaySmall: AppText.display(36, color: AppColors.card),
        headlineLarge: AppText.display(32, color: AppColors.card),
        headlineMedium: AppText.display(28, color: AppColors.card),
        headlineSmall: AppText.display(24, color: AppColors.card),
        titleLarge: AppText.display(22, color: AppColors.card),
        titleMedium: AppText.body(16, weight: FontWeight.w600, color: AppColors.card),
        titleSmall: AppText.body(14, weight: FontWeight.w600, color: AppColors.card),
        bodyLarge: AppText.body(16, color: AppColors.card),
        bodyMedium: AppText.body(14, color: AppColors.card),
        bodySmall: AppText.body(12, color: AppColors.card),
        labelLarge: AppText.label(14, color: AppColors.card),
        labelMedium: AppText.label(12, color: AppColors.card),
        labelSmall: AppText.label(11, color: AppColors.card),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: AppText.display(20, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.sumiCard : AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.hairlineDark : AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.sumiCard : AppColors.card,
        selectedColor: accent.withValues(alpha: isDark ? 0.22 : 0.12),
        disabledColor: scheme.surfaceContainerHighest,
        secondaryLabelStyle: AppText.label(12, color: scheme.onSurface),
        labelStyle: AppText.body(13, weight: FontWeight.w500, color: scheme.onSurface),
        side: BorderSide(
          color: isDark ? AppColors.hairlineDark : AppColors.hairline,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.sumiCard : AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: AppText.body(14, color: isDark ? AppColors.inkMutedDark : AppColors.inkMuted),
        labelStyle: AppText.body(14, color: isDark ? AppColors.inkMutedDark : AppColors.inkMuted),
        border: _border(isDark),
        enabledBorder: _border(isDark),
        focusedBorder: _border(isDark, accent),
        errorBorder: _border(isDark, scheme.error),
        focusedErrorBorder: _border(isDark, scheme.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.14),
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          AppText.label(10, color: scheme.onSurfaceVariant),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 22, color: accent);
          }
          return IconThemeData(size: 22, color: scheme.onSurfaceVariant);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.card,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 17),
          shape: const StadiumBorder(),
          textStyle: AppText.label(13, color: AppColors.card, letterSpacing: 0.08),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.sumiRaised : AppColors.card,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: AppText.label(12, color: scheme.onSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: AppText.label(12, color: accent),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          iconSize: 20,
          padding: const EdgeInsets.all(10),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.paperOnDark : AppColors.sumi,
        contentTextStyle: AppText.body(
          13.5,
          color: isDark ? AppColors.sumiDeep : AppColors.paper,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.sumiCard : AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: AppText.display(22, color: scheme.onSurface),
        contentTextStyle: AppText.body(14, color: scheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.sumiCard : AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.sumi,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: AppText.body(12, color: AppColors.paper),
        waitDuration: const Duration(milliseconds: 500),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: const {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: AppText.body(15, weight: FontWeight.w500, color: scheme.onSurface),
        subtitleTextStyle: AppText.body(12.5, color: scheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.sumiCard : AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.sumi.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: AppText.body(14, color: scheme.onSurface),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.card;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return null;
        }),
      ),
    );
  }

  static OutlineInputBorder _border(bool dark, [Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: color ?? (dark ? AppColors.hairlineDark : AppColors.hairline),
        width: color == null ? 1 : 1.4,
      ),
    );
  }

  static TextTheme _textTheme(bool dark, Color accent) {
    final ink = dark ? AppColors.paperOnDark : AppColors.sumi;
    final muted = dark ? AppColors.inkMutedDark : AppColors.inkMuted;
    return TextTheme(
      displayLarge: AppText.display(56, color: ink),
      displayMedium: AppText.display(44, color: ink),
      displaySmall: AppText.display(34, color: ink),
      headlineLarge: AppText.display(30, color: ink),
      headlineMedium: AppText.display(26, color: ink),
      headlineSmall: AppText.display(22, color: ink),
      titleLarge: AppText.display(20, color: ink),
      titleMedium: AppText.body(16, weight: FontWeight.w600, color: ink),
      titleSmall: AppText.body(14, weight: FontWeight.w600, color: ink),
      bodyLarge: AppText.body(16, color: ink),
      bodyMedium: AppText.body(14, color: ink),
      bodySmall: AppText.body(12.5, color: muted),
      labelLarge: AppText.label(13, color: ink),
      labelMedium: AppText.label(11, color: muted),
      labelSmall: AppText.label(10, color: muted),
    );
  }

  static ColorScheme _scheme(Brightness brightness, Color accent) {
    final dark = brightness == Brightness.dark;
    final primary = dark ? accent.withValues(alpha: 1) : accent;
    final onPrimary = dark ? AppColors.sumiDeep : AppColors.card;
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: accent.withValues(alpha: dark ? 0.26 : 0.12),
      onPrimaryContainer: dark ? AppColors.paperOnDark : AppColors.sumi,
      secondary: AppColors.gold,
      onSecondary: AppColors.sumi,
      secondaryContainer: AppColors.gold.withValues(alpha: dark ? 0.22 : 0.18),
      onSecondaryContainer: dark ? AppColors.paperOnDark : AppColors.sumi,
      tertiary: AppColors.sakura,
      onTertiary: AppColors.sumi,
      tertiaryContainer: AppColors.sakura.withValues(alpha: dark ? 0.2 : 0.3),
      onTertiaryContainer: dark ? AppColors.paperOnDark : AppColors.sumi,
      error: const Color(0xFFB3261E),
      onError: AppColors.card,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: dark ? AppColors.sumiDeep : AppColors.paper,
      onSurface: dark ? AppColors.paperOnDark : AppColors.sumi,
      surfaceDim: dark ? AppColors.sumiDeep : AppColors.paper,
      surfaceBright: dark ? AppColors.sumiRaised : AppColors.card,
      surfaceContainerLowest: dark ? const Color(0xFF0E0B09) : AppColors.card,
      surfaceContainerLow: dark ? AppColors.sumiDeep : AppColors.paper,
      surfaceContainer: dark ? AppColors.sumiCard : const Color(0xFFFBF6EE),
      surfaceContainerHigh: dark ? AppColors.sumiRaised : const Color(0xFFF3ECE2),
      surfaceContainerHighest: dark ? AppColors.sumiRaised : const Color(0xFFEDE4D8),
      onSurfaceVariant: dark ? AppColors.inkMutedDark : AppColors.inkMuted,
      outline: dark ? const Color(0xFF3C322C) : const Color(0xFFD8CBBE),
      outlineVariant: dark ? const Color(0xFF2B2320) : const Color(0xFFEAE0D4),
      inverseSurface: dark ? AppColors.paper : AppColors.sumi,
      onInverseSurface: dark ? AppColors.sumi : AppColors.paper,
      inversePrimary: dark ? accent : accent.withValues(alpha: 0.9),
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
  }
}
