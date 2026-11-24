import 'package:material_ui/material_ui.dart';

/// Типографика Hikari: серифы для заголовков, кисть для подписи,
/// Mincho — для японских иероглифов.
class AppText {
  AppText._();

  static const String sans = 'Inter';
  static const String serifFamily = 'PlayfairDisplay';
  static const String brushFamily = 'CaveatBrush';
  static const String kanjiFamily = 'YujiSyuku';
  static const String minchoFamily = 'ShipporiMincho';

  static const List<String> serifFallback = [minchoFamily, 'Georgia', 'serif'];

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 1.02,
    double letterSpacing = -0.02,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.45,
    double letterSpacing = 0.01,
  }) {
    return TextStyle(
      fontFamily: sans,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle label(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 0.14,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: sans,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle brush(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0.02,
  }) {
    return TextStyle(
      fontFamily: brushFamily,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: 1.0,
      color: color,
    );
  }

  static TextStyle kanji(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.0,
  }) {
    return TextStyle(
      fontFamily: kanjiFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  static TextStyle mincho(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0.08,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: minchoFamily,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  /// Надзаголовок: капслок с широким трекингом.
  static TextStyle eyebrow(Color color, {double size = 11}) {
    return label(size, color: color, letterSpacing: 0.26);
  }
}
