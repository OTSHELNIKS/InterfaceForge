import 'package:flutter/services.dart';

import 'staged_asset.dart';

/// Веб-реализация подготовки ассета (используется, когда нет `dart:io`).
///
/// Проверяем, что ресурс действительно есть в бандле, и возвращаем его имя.
/// Установка системных обоев на вебе недоступна — `applyWallpaper` сообщит
/// об этом через `MissingPluginException`.
Future<StagedAsset> stageAssetPlatform(
  String assetPath, {
  String? fileName,
}) async {
  await rootBundle.load(assetPath);
  return StagedAsset(fileName ?? assetPath.split('/').last);
}
