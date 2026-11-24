import 'package:material_ui/material_ui.dart';

enum HikariItemType { theme, wallpaper }

HikariItemType hikariItemTypeFromName(String value) {
  switch (value) {
    case 'theme':
      return HikariItemType.theme;
    case 'wallpaper':
      return HikariItemType.wallpaper;
    default:
      throw FormatException('Неизвестный тип работы: $value');
  }
}

extension HikariItemTypeX on HikariItemType {
  String get jsonName => switch (this) {
        HikariItemType.theme => 'theme',
        HikariItemType.wallpaper => 'wallpaper',
      };

  String get label => switch (this) {
        HikariItemType.theme => 'Тема',
        HikariItemType.wallpaper => 'Обои',
      };

  String get labelPlural => switch (this) {
        HikariItemType.theme => 'Темы',
        HikariItemType.wallpaper => 'Обои',
      };

  String get applyLabel => switch (this) {
        HikariItemType.theme => 'Применить тему',
        HikariItemType.wallpaper => 'Установить обои',
      };
}

/// Одна работа каталога: тема или обои.
@immutable
class HikariItem {
  const HikariItem({
    required this.id,
    required this.title,
    required this.titleJa,
    required this.type,
    required this.collectionId,
    required this.tags,
    required this.colors,
    required this.date,
    required this.popularity,
    required this.description,
    required this.asset,
    required this.assetLandscape,
  });

  final String id;
  final String title;
  final String titleJa;
  final HikariItemType type;
  final String collectionId;
  final List<String> tags;
  final List<Color> colors;
  final DateTime date;
  final int popularity;
  final String description;

  /// Портретный ассет (телефоны).
  final String asset;

  /// Альбомный ассет (рабочий стол).
  final String assetLandscape;

  bool get isTheme => type == HikariItemType.theme;

  Color get primary => colors.isNotEmpty ? colors.first : const Color(0xFFC9362B);

  Color get accent => colors.length > 1 ? colors[1] : primary;

  factory HikariItem.fromJson(Map<String, dynamic> json) {
    final rawColors = (json['colors'] as List).cast<String>();
    return HikariItem(
      id: json['id'] as String,
      title: json['title'] as String,
      titleJa: json['titleJa'] as String,
      type: hikariItemTypeFromName(json['type'] as String),
      collectionId: json['collection'] as String,
      tags: (json['tags'] as List).cast<String>(),
      colors: rawColors.map(_parseColor).toList(growable: false),
      date: DateTime.parse(json['date'] as String),
      popularity: json['popularity'] as int,
      description: json['description'] as String,
      asset: json['asset'] as String,
      assetLandscape: json['assetLandscape'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleJa': titleJa,
        'type': type.jsonName,
        'collection': collectionId,
        'tags': tags,
        'colors': colors.map(_colorToHex).toList(),
        'date': date.toIso8601String(),
        'popularity': popularity,
        'description': description,
        'asset': asset,
        'assetLandscape': assetLandscape,
      };

  /// Копия с заменой коллекции (используется в тестах).
  HikariItem copyWith({String? collectionId}) => HikariItem(
        id: id,
        title: title,
        titleJa: titleJa,
        type: type,
        collectionId: collectionId ?? this.collectionId,
        tags: tags,
        colors: colors,
        date: date,
        popularity: popularity,
        description: description,
        asset: asset,
        assetLandscape: assetLandscape,
      );

  static Color _parseColor(String value) {
    var hex = value.replaceAll('#', '').trim();
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static String _colorToHex(Color color) {
    final v = color.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      other is HikariItem &&
      other.id == id &&
      other.title == title &&
      other.collectionId == collectionId;

  @override
  int get hashCode => Object.hash(id, title, collectionId);
}
