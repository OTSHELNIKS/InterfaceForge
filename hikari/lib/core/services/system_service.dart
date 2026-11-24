import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hikari/data/models/device_info.dart';
import 'package:path_provider/path_provider.dart';

/// Мост к нативному слою: установка системных обоев и темы.
class SystemService {
  const SystemService();

  static const MethodChannel channel = MethodChannel('hikari/system');

  /// Информация об устройстве: платформа, версия ОС, модель.
  Future<DeviceInfo> deviceInfo() async {
    final raw = await channel.invokeMethod<Map<Object?, Object?>>('getDeviceInfo');
    if (raw == null) return DeviceInfo.fallback;
    return DeviceInfo.fromMap(raw);
  }

  /// Копирует ассет в кеш и возвращает путь к файлу для нативного слоя.
  Future<File> stageAsset(String assetPath, {String? fileName}) async {
    final data = await rootBundle.load(assetPath);
    final directory = await getTemporaryDirectory();
    final name = fileName ?? assetPath.split('/').last;
    final file = File('${directory.path}${Platform.pathSeparator}hikari_$name');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }

  /// Устанавливает системные обои (рабочий стол + экран блокировки на Android).
  Future<bool> applyWallpaper(String filePath) async {
    final result = await channel.invokeMethod<bool>('applyWallpaper', filePath);
    return result ?? false;
  }

  /// Применяет тему: на Windows синхронизирует светлую/тёмную тему системы,
  /// на Android — включает тёмный режим приложения.
  Future<Map<Object?, Object?>> applyTheme({
    required bool dark,
    required String accent,
    required String themeId,
  }) async {
    final result = await channel.invokeMethod<Map<Object?, Object?>>('applyTheme', {
      'dark': dark,
      'accent': accent,
      'themeId': themeId,
    });
    return result ?? const {};
  }

  /// Сбрасывает системную тему к значению по умолчанию (Windows).
  Future<bool> resetSystemTheme() async {
    final result = await channel.invokeMethod<bool>('resetSystemTheme');
    return result ?? false;
  }
}
