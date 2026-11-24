import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/grain_overlay.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/core/widgets/sakura_branch.dart';

/// Светлый сгенерированный хедер: пейзаж с тории, мягкий градиент
/// для читаемого текста и плавный переход в бумажную область.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.onOpenCatalog,
    this.onOpenWallpaper,
    this.heroTitle = 'Красота',
  });

  final VoidCallback onOpenCatalog;
  final VoidCallback? onOpenWallpaper;
  final String heroTitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;
        final paper = Theme.of(context).scaffoldBackgroundColor;
        return wide ? _desktop(context, paper) : _mobile(context, paper);
      },
    );
  }

  Widget _desktop(BuildContext context, Color paper) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          height: 508,
          child: Stack(
            children: [
              Positioned.fill(child: _poster(context, paper)),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(56, 40, 340, 40),
                  child: _content(context, wide: true),
                ),
              ),
              Positioned(
                right: 42,
                top: 0,
                bottom: 0,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'HIKARI  ·  光  ·  2026',
                      style: AppText.label(
                        10,
                        color: paper.withValues(alpha: 0.28),
                        letterSpacing: 0.42,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobile(BuildContext context, Color paper) {
    return SizedBox(
      height: 492,
      child: Stack(
        children: [
          Positioned.fill(child: _poster(context, paper)),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 26),
                child: _content(context, wide: false),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 96,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [paper.withValues(alpha: 0), paper],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _poster(BuildContext context, Color paper) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Сгенерированное изображение вместо процедурно нарисованного постера.
        Image.asset(
          'assets/wallpapers/generated-hero.jpg',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stack) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [Color(0xFF241713), Color(0xFF100C0A)],
              ),
            ),
          ),
        ),
        // Мягкий градиент только слева: белый заголовок читается,
        // а само изображение остаётся светлым и детализированным.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF1E1917).withValues(alpha: 0.82),
                const Color(0xFF1E1917).withValues(alpha: 0.48),
                const Color(0xFF1E1917).withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.48, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF1E1917).withValues(alpha: 0.28),
              ],
              stops: const [0.55, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: GrainOverlay(opacity: 0.06),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, {required bool wide}) {
    // Поверх сгенерированного пейзажа текст всегда светлый, даже если
    // пользователь выбрал тёмную тему для остального интерфейса.
    const foreground = AppColors.card;
    final titleStyle = AppText.display(
      wide ? 66 : 42,
      color: foreground,
      height: 1.0,
      letterSpacing: -0.025,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            HikariLogo(size: wide ? 30 : 26, color: foreground),
            const Spacer(),
            if (wide)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: foreground.withValues(alpha: 0.22)),
                ),
                child: Text(
                  'v1.0 · 光',
                  style: AppText.label(
                    10,
                    color: foreground.withValues(alpha: 0.72),
                    letterSpacing: 0.22,
                  ),
                ),
              ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const GoldRule(width: 42),
            const SizedBox(width: 12),
            Text(
              'ЯПОНСКАЯ ЭСТЕТИКА · 2026',
              style: AppText.eyebrow(AppColors.gold.withValues(alpha: 0.95)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          wide ? '$heroTitle\nв простых вещах' : '$heroTitle\nв простых\nвещах',
          style: titleStyle,
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 420 : 320),
          child: Text(
            'Японские обои и темы, которые наполняют ваш день '
            'атмосферой гармонии. Каждый экран — маленькая галерея.',
            style: AppText.body(
              wide ? 15.5 : 14,
              color: foreground.withValues(alpha: 0.88),
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            FilledButton.icon(
              onPressed: onOpenCatalog,
              icon: const Icon(Icons.auto_awesome_rounded, size: 17),
              label: const Text('Открыть коллекции'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.vermilion,
                foregroundColor: AppColors.card,
              ),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: onOpenWallpaper,
              icon: const Icon(Icons.image_outlined, size: 17),
              label: const Text('Обои дня'),
              style: TextButton.styleFrom(
                foregroundColor: foreground.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
