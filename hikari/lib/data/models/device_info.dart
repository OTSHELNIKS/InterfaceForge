import 'package:material_ui/material_ui.dart';

@immutable
class DeviceInfo {
  const DeviceInfo({
    required this.platform,
    required this.version,
    required this.model,
    required this.wallpaperSupported,
  });

  final String platform;
  final String version;
  final String model;
  final bool wallpaperSupported;

  factory DeviceInfo.fromMap(Map<Object?, Object?> map) {
    return DeviceInfo(
      platform: map['platform'] as String? ?? 'Неизвестно',
      version: map['version'] as String? ?? '—',
      model: map['model'] as String? ?? '—',
      wallpaperSupported: map['wallpaperSupported'] as bool? ?? false,
    );
  }

  static const DeviceInfo fallback = DeviceInfo(
    platform: 'Web',
    version: '—',
    model: 'Браузер',
    wallpaperSupported: false,
  );

  String get summary => '$platform $version';
}
