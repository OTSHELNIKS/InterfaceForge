import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Зернистая плёнка поверх поверхностей — эффект бумаги васи.
class GrainOverlay extends StatefulWidget {
  const GrainOverlay({
    super.key,
    this.opacity = 0.05,
    this.blendMode = BlendMode.overlay,
    this.tileSize = 220,
  });

  final double opacity;
  final BlendMode blendMode;
  final double tileSize;

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load('assets/textures/grain.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() => _image = frame.image);
    } catch (_) {
      // Текстура необязательна — просто рисуем без неё.
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GrainPainter(
            image: _image,
            opacity: widget.opacity,
            blendMode: widget.blendMode,
            tileSize: widget.tileSize,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter({
    required this.image,
    required this.opacity,
    required this.blendMode,
    required this.tileSize,
  });

  final ui.Image? image;
  final double opacity;
  final BlendMode blendMode;
  final double tileSize;

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img == null) return;
    final paint = Paint()
      ..blendMode = blendMode
      ..filterQuality = FilterQuality.medium
      ..color = Colors.white.withValues(alpha: opacity);

    final tile = tileSize;
    for (double y = 0; y < size.height; y += tile) {
      for (double x = 0; x < size.width; x += tile) {
        final src = Rect.fromLTWH(
          0,
          0,
          img.width.toDouble(),
          img.height.toDouble(),
        );
        final dst = Rect.fromLTWH(x, y, tile, tile);
        canvas.drawImageRect(img, src, dst, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.opacity != opacity ||
        oldDelegate.blendMode != blendMode ||
        oldDelegate.tileSize != tileSize;
  }
}
