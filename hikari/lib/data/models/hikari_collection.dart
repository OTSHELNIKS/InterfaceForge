import 'package:material_ui/material_ui.dart';

@immutable
class HikariCollection {
  const HikariCollection({
    required this.id,
    required this.name,
    required this.nameJa,
    required this.description,
    required this.color,
  });

  final String id;
  final String name;
  final String nameJa;
  final String description;
  final Color color;

  factory HikariCollection.fromJson(Map<String, dynamic> json) {
    return HikariCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      nameJa: json['nameJa'] as String,
      description: json['description'] as String,
      color: _color(json['color'] as String),
    );
  }

  static Color _color(String value) {
    var hex = value.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
