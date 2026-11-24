import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';

/// Чернильная ветвь сакуры: живопись без растровых ассетов.
class SakuraBranch extends StatefulWidget {
  const SakuraBranch({
    super.key,
    this.ink = AppColors.paper,
    this.blossom = AppColors.sakura,
    this.gold = AppColors.gold,
    this.opacity = 1,
    this.animate = true,
    this.density = 1,
    this.flip = false,
  });

  final Color ink;
  final Color blossom;
  final Color gold;
  final double opacity;
  final bool animate;
  final double density;
  final bool flip;

  @override
  State<SakuraBranch> createState() => _SakuraBranchState();
}

class _SakuraBranchState extends State<SakuraBranch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant SakuraBranch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SakuraBranchPainter(
              ink: widget.ink,
              blossom: widget.blossom,
              gold: widget.gold,
              opacity: widget.opacity,
              phase: _controller.value,
              density: widget.density,
              flip: widget.flip,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SakuraBranchPainter extends CustomPainter {
  const _SakuraBranchPainter({
    required this.ink,
    required this.blossom,
    required this.gold,
    required this.opacity,
    required this.phase,
    required this.density,
    required this.flip,
  });

  final Color ink;
  final Color blossom;
  final Color gold;
  final double opacity;
  final double phase;
  final double density;
  final bool flip;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    if (flip) canvas.scale(-1, 1);
    canvas.translate(-size.width / 2, -size.height / 2);

    final sway = math.sin(phase * math.pi * 2) * 0.006;
    canvas.translate(size.width * 0.5, size.height);
    canvas.rotate(sway);
    canvas.translate(-size.width * 0.5, -size.height);

    final w = size.width;
    final h = size.height;

    final main = Path()
      ..moveTo(-w * 0.06, h * 0.66)
      ..cubicTo(w * 0.10, h * 0.62, w * 0.20, h * 0.46, w * 0.34, h * 0.41)
      ..cubicTo(w * 0.48, h * 0.36, w * 0.57, h * 0.25, w * 0.71, h * 0.22)
      ..cubicTo(w * 0.80, h * 0.20, w * 0.87, h * 0.14, w * 0.94, h * 0.08);

    final branchPaint = Paint()
      ..color = ink.withValues(alpha: 0.92 * opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    _drawTapered(canvas, main, w * 0.0105, w * 0.0016, branchPaint);

    final twigs = <Path>[
      Path()
        ..moveTo(w * 0.30, h * 0.43)
        ..cubicTo(w * 0.29, h * 0.30, w * 0.31, h * 0.20, w * 0.30, h * 0.08),
      Path()
        ..moveTo(w * 0.45, h * 0.37)
        ..cubicTo(w * 0.42, h * 0.27, w * 0.40, h * 0.18, w * 0.38, h * 0.10),
      Path()
        ..moveTo(w * 0.58, h * 0.28)
        ..cubicTo(w * 0.60, h * 0.17, w * 0.63, h * 0.10, w * 0.66, h * 0.02),
      Path()
        ..moveTo(w * 0.63, h * 0.26)
        ..cubicTo(w * 0.69, h * 0.30, w * 0.73, h * 0.36, w * 0.76, h * 0.42),
      Path()
        ..moveTo(w * 0.79, h * 0.20)
        ..cubicTo(w * 0.83, h * 0.24, w * 0.86, h * 0.29, w * 0.88, h * 0.34),
    ];

    for (var i = 0; i < twigs.length; i++) {
      _drawTapered(
        canvas,
        twigs[i],
        w * (0.0042 - i * 0.0004),
        w * 0.0010,
        branchPaint,
      );
    }

    // Соцветия.
    final clusters = <_Cluster>[
      _Cluster(w * 0.30, h * 0.08, 1.15, 0.0),
      _Cluster(w * 0.375, h * 0.10, 0.95, 0.7),
      _Cluster(w * 0.655, h * 0.03, 1.25, 1.2),
      _Cluster(w * 0.755, h * 0.425, 0.9, 2.1),
      _Cluster(w * 0.875, h * 0.345, 0.8, 2.9),
      _Cluster(w * 0.50, h * 0.345, 0.75, 3.6),
      _Cluster(w * 0.94, h * 0.09, 0.85, 4.4),
    ];

    for (final cluster in clusters) {
      final count = (4 * density).round().clamp(2, 7);
      for (var i = 0; i < count; i++) {
        final angle = cluster.seed + i * 2.39996;
        final radius = (cluster.scale * w * 0.016) * (0.75 + 0.35 * ((i * 37) % 10) / 10);
        final ox = math.cos(angle) * radius * 1.7;
        final oy = math.sin(angle) * radius * 1.25;
        final petalR = w * 0.016 * cluster.scale * (0.8 + 0.3 * ((i * 53) % 10) / 10);
        _drawBlossom(
          canvas,
          Offset(cluster.x + ox, cluster.y + oy),
          petalR,
          rotation: angle * 0.6 + math.sin(phase * 6.28 + i) * 0.05,
          alpha: 0.82 + 0.18 * ((i * 29) % 10) / 10,
        );
      }
      // Несколько бутонов.
      _drawBud(canvas, Offset(cluster.x - w * 0.012, cluster.y + w * 0.018), w * 0.009);
    }

    // Падающие лепестки.
    final petalCount = (9 * density).round();
    for (var i = 0; i < petalCount; i++) {
      final seed = (i * 97) % 100 / 100;
      final t = (phase * 0.6 + seed) % 1.0;
      final x = w * (0.15 + 0.75 * ((i * 61) % 100) / 100) + math.sin(t * 6.28 + i) * w * 0.02;
      final y = h * (-0.1 + t * 1.25);
      _drawPetal(
        canvas,
        Offset(x, y),
        w * 0.0095,
        rotation: t * 6.28 * 0.8 + i,
        alpha: 0.35 + 0.35 * math.sin(t * math.pi),
      );
    }

    canvas.restore();
  }

  void _drawTapered(
    Canvas canvas,
    Path path,
    double startWidth,
    double endWidth,
    Paint paint,
  ) {
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      if (length <= 0) continue;
      final step = math.max(0.7, startWidth * 0.22);
      for (double d = 0; d <= length; d += step) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;
        final t = d / length;
        // Небольшая неровность кисти.
        final wobble = 1 + 0.10 * math.sin(d * 0.09) + 0.06 * math.sin(d * 0.31 + 1.7);
        final radius = (startWidth + (endWidth - startWidth) * t) * wobble / 2;
        canvas.drawCircle(tangent.position, radius, paint);
      }
    }
  }

  void _drawBlossom(
    Canvas canvas,
    Offset center,
    double radius, {
    double rotation = 0,
    double alpha = 1,
  }) {
    final glow = Paint()
      ..color = blossom.withValues(alpha: 0.10 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawCircle(center, radius * 2.0, glow);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    for (var i = 0; i < 5; i++) {
      final petal = Path()
        ..moveTo(0, 0)
        ..cubicTo(-radius * 0.95, -radius * 0.35, -radius * 0.55, -radius * 1.18, 0, -radius * 1.3)
        ..cubicTo(radius * 0.55, -radius * 1.18, radius * 0.95, -radius * 0.35, 0, 0);
      final shade = Paint()
        ..color = Color.lerp(blossom, Colors.white, i.isEven ? 0.18 : 0.02)!
            .withValues(alpha: alpha * opacity * 0.92)
        ..isAntiAlias = true;
      canvas.drawPath(petal, shade);
      canvas.rotate(math.pi * 2 / 5);
    }
    // Сердцевина и тычинки.
    final heart = Paint()
      ..color = const Color(0xFFF7D9A8).withValues(alpha: 0.9 * opacity)
      ..isAntiAlias = true;
    canvas.drawCircle(Offset.zero, radius * 0.20, heart);
    final stamen = Paint()
      ..color = gold.withValues(alpha: 0.75 * opacity)
      ..strokeWidth = math.max(0.6, radius * 0.055)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final a = i * math.pi * 2 / 7 + 0.3;
      canvas.drawLine(
        Offset.zero,
        Offset(math.cos(a) * radius * 0.48, math.sin(a) * radius * 0.48),
        stamen,
      );
      canvas.drawCircle(
        Offset(math.cos(a) * radius * 0.48, math.sin(a) * radius * 0.48),
        radius * 0.06,
        stamen,
      );
    }
    canvas.restore();
  }

  void _drawBud(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = blossom.withValues(alpha: 0.85 * opacity)
      ..isAntiAlias = true;
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 1.5, height: radius * 2.1), paint);
    final tip = Paint()
      ..color = ink.withValues(alpha: 0.5 * opacity);
    canvas.drawCircle(center + Offset(radius * 0.5, -radius * 0.8), radius * 0.32, tip);
  }

  void _drawPetal(
    Canvas canvas,
    Offset center,
    double radius, {
    double rotation = 0,
    double alpha = 1,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-radius * 0.9, -radius * 0.4, -radius * 0.4, -radius * 1.1, 0, -radius * 1.15)
      ..cubicTo(radius * 0.4, -radius * 1.1, radius * 0.9, -radius * 0.4, 0, 0);
    canvas.drawPath(
      path,
      Paint()
        ..color = blossom.withValues(alpha: alpha * opacity)
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SakuraBranchPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.ink != ink ||
        oldDelegate.blossom != blossom ||
        oldDelegate.opacity != opacity ||
        oldDelegate.density != density;
  }
}

class _Cluster {
  const _Cluster(this.x, this.y, this.scale, this.seed);

  final double x;
  final double y;
  final double scale;
  final double seed;
}

/// Утилита для отрисовки мягкого свечения.
class SoftGlow extends StatelessWidget {
  const SoftGlow({
    super.key,
    required this.child,
    this.color = AppColors.vermilion,
    this.blur = 60,
    this.opacity = 0.35,
  });

  final Widget child;
  final Color color;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blur,
            spreadRadius: blur * 0.18,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Декоративный диск солнца с мягким свечением.
class SunDisc extends StatelessWidget {
  const SunDisc({
    super.key,
    this.size = 200,
    this.color = AppColors.vermilion,
    this.coreColor = AppColors.vermilionLight,
  });

  final double size;
  final Color color;
  final Color coreColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.28, -0.32),
              radius: 1.05,
              colors: [
                Color.lerp(coreColor, Colors.white, 0.35)!,
                coreColor,
                color,
                Color.lerp(color, AppColors.sumi, 0.18)!,
              ],
              stops: const [0.0, 0.42, 0.82, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.38),
                blurRadius: size * 0.34,
                spreadRadius: size * 0.04,
              ),
              BoxShadow(
                color: coreColor.withValues(alpha: 0.18),
                blurRadius: size * 0.7,
                spreadRadius: size * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Тонкая золотая линия с градиентом.
class GoldRule extends StatelessWidget {
  const GoldRule({super.key, this.width = 64, this.color = AppColors.gold});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Утилита для подписи с засечками под золотой линией.
class VerticalKanjiLabel extends StatelessWidget {
  const VerticalKanjiLabel({
    super.key,
    required this.text,
    this.color = AppColors.paper,
    this.size = 12,
  });

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final char in text.split(''))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              char,
              style: TextStyle(
                fontFamily: 'ShipporiMincho',
                fontSize: size,
                color: color,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

/// Вспомогательный painter для мягкого пятна света (используется в фонах).
class GlowPainter extends CustomPainter {
  const GlowPainter({
    required this.color,
    required this.center,
    required this.radius,
    this.opacity = 0.4,
  });

  final Color color;
  final Offset center;
  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.35),
          color.withValues(alpha: 0),
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant GlowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.opacity != opacity;
  }
}
