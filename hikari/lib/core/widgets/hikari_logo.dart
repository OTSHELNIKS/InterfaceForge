import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';

/// Фирменный знак: кистевое 光 + подпись Hikari (Hi — киноварью).
class HikariLogo extends StatelessWidget {
  const HikariLogo({
    super.key,
    this.size = 34,
    this.color = AppColors.sumi,
    this.accent = AppColors.vermilion,
    this.showKanji = true,
    this.glow = false,
  });

  final double size;
  final Color color;
  final Color accent;
  final bool showKanji;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final wordmark = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Hi', style: AppText.brush(size, color: accent)),
          TextSpan(text: 'kari', style: AppText.brush(size, color: color)),
        ],
      ),
      textAlign: TextAlign.center,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showKanji) ...[
          Text(
            '光',
            style: AppText.kanji(size * 1.25, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 10),
        ],
        if (glow)
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => LinearGradient(
              colors: [color, accent, color],
            ).createShader(rect),
            child: wordmark,
          )
        else
          wordmark,
      ],
    );

    if (!glow) return content;
    return Semantics(
      label: 'Hikari',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 34,
              spreadRadius: 2,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// Отдельный знак 光 — для водяных знаков и пустых состояний.
class KanjiMark extends StatelessWidget {
  const KanjiMark({
    super.key,
    this.size = 200,
    this.color = AppColors.sumi,
    this.opacity = 1,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Text(
          '光',
          style: AppText.kanji(size, color: color),
        ),
      ),
    );
  }
}
