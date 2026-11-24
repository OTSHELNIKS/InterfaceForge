import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:hikari/data/models/device_info.dart';

import 'staged_asset.dart';
import 'system_service_staging.dart'
    if (dart.library.io) 'system_service_staging_io.dart';

/// Мост к нативному слою: установка системных обоев и темы.
///
/// На вебе системный канал `hikari/system` отсутствует, поэтому методы
/// возвращают безопасные заглушки: тема применяется внутри приложения,
/// а попытка установить обои даёт понятное сообщение.
class SystemService {
  const SystemService();

  static const MethodChannel channel = MethodChannel('hikari/system');

  /// Информация об устройстве: платформа, версия ОС, модель.
  Future<DeviceInfo> deviceInfo() async {
    if (kIsWeb) return DeviceInfo.fallback;
    final raw = await channel.invokeMethod<Map<Object?, Object?>>('getDeviceInfo');
    if (raw == null) return DeviceInfo.fallback;
    return DeviceInfo.fromMap(raw);
  }

  /// Готовит ассет к передаче в нативный слой.
  Future<StagedAsset> stageAsset(String assetPath, {String? fileName}) =>
      stageAssetPlatform(assetPath, fileName: fileName);

  /// Устанавливает системные обои (рабочий стол + экран блокировки на Android).
  Future<bool> applyWallpaper(String filePath) async {
    if (kIsWeb) {
      throw MissingPluginException(
        'Установка системных обоев недоступна в веб-версии',
      );
    }
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
    if (kIsWeb) return const {};
    final result = await channel.invokeMethod<Map<Object?, Object?>>('applyTheme', {
      'dark': dark,
      'accent': accent,
      'themeId': themeId,
    });
    return result ?? const {};
  }

  /// Сбрасывает системную тему к значению по умолчанию (Windows).
  Future<bool> resetSystemTheme() async {
    if (kIsWeb) return false;
    final result = await channel.invokeMethod<bool>('resetSystemTheme');
    return result ?? false;
  }
}
