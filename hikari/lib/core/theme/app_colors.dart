import 'package:material_ui/material_ui.dart';

/// Палитра Hikari — васи, суми, киноварь, сакура и золото.
class AppColors {
  AppColors._();

  /// Светлая бумага васи.
  static const Color paper = Color(0xFFF7F1E8);

  /// Цвет карточек — чуть теплее и светлее бумаги.
  static const Color card = Color(0xFFFFFCF8);

  /// Тушь суми — основной тёмный.
  static const Color sumi = Color(0xFF1E1917);

  /// Киноварь — главный акцент.
  static const Color vermilion = Color(0xFFC9362B);

  /// Светлый красный.
  static const Color vermilionLight = Color(0xFFF05A4A);

  /// Сакура.
  static const Color sakura = Color(0xFFEBA6B7);

  /// Золото.
  static const Color gold = Color(0xFFC9A227);

  /// Приглушённые чернила для второстепенного текста.
  static const Color inkMuted = Color(0xFF8C7F75);

  /// Тёмная тема: не чёрная, а тёплый угольный сумi — текст остаётся читаемым.
  static const Color sumiDeep = Color(0xFF241D19);
  static const Color sumiCard = Color(0xFF302721);
  static const Color sumiRaised = Color(0xFF3B3029);
  static const Color paperOnDark = Color(0xFFFFF8EE);
  static const Color inkMutedDark = Color(0xFFD6C4B4);

  /// Линии и разделители.
  static const Color hairline = Color(0x1F1E1917);
  static const Color hairlineDark = Color(0x33F7F1E8);

  /// Цвета типов работ.
  static const Color themeType = Color(0xFFC9A227);
  static const Color wallpaperType = Color(0xFFC9362B);

  /// Коллекции.
  static const Color akane = Color(0xFFC9362B);
  static const Color sakuraCollection = Color(0xFFEBA6B7);
  static const Color sumiCollection = Color(0xFF3B322C);
  static const Color aoiCollection = Color(0xFF2E4A73);

  /// Плавный переход от тёмного постера к бумаге.
  static const LinearGradient posterFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00F7F1E8), Color(0xFFF7F1E8)],
    stops: [0.0, 1.0],
  );

  static Color byName(String name) {
    switch (name) {
      case 'paper':
        return paper;
      case 'card':
        return card;
      case 'sumi':
        return sumi;
      case 'vermilion':
        return vermilion;
      case 'vermilionLight':
        return vermilionLight;
      case 'sakura':
        return sakura;
      case 'gold':
        return gold;
      case 'akane':
        return akane;
      case 'sumiCollection':
        return sumiCollection;
      case 'aoi':
        return aoiCollection;
      default:
        return vermilion;
    }
  }
}
