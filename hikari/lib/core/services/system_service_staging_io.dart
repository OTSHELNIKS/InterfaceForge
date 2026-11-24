import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'staged_asset.dart';

/// Нативная реализация: копирует ассет во временную директорию и возвращает
/// путь к файлу для Win32/Android-канала `hikari/system`.
Future<StagedAsset> stageAssetPlatform(
  String assetPath, {
  String? fileName,
}) async {
  final data = await rootBundle.load(assetPath);
  final directory = await getTemporaryDirectory();
  final name = fileName ?? assetPath.split('/').last;
  final file = File('${directory.path}${Platform.pathSeparator}hikari_$name');
  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
  return StagedAsset(file.path);
}
