import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/widgets/grain_overlay.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/core/widgets/sakura_branch.dart';

/// Бумажный фон приложения с лёгким тёплым светом и зерном.
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF14100E), Color(0xFF17110F), Color(0xFF120E0C)]
              : const [Color(0xFFF9F3EA), AppColors.paper, Color(0xFFF5EEE4)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.7, -0.5),
                    radius: 1.2,
                    colors: [
                      AppColors.gold.withValues(alpha: dark ? 0.045 : 0.09),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: GrainOverlay(opacity: 0.045),
          ),
          Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ],
      ),
    );
  }
}

/// Заголовок секции с надзаголовком и действием справа.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(24, 8, 24, 4),
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(eyebrow!, style: AppText.eyebrow(AppColors.gold)),
                  const SizedBox(height: 8),
                ],
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Стеклянная круглая кнопка для наложения поверх изображений.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.light = true,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool light;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fg = light ? AppColors.paper : AppColors.sumi;
    final button = ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: (light ? Colors.black : Colors.white).withValues(alpha: 0.28),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: 20, color: fg),
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Небольшой тег-«капсула».
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (color ?? theme.colorScheme.outline).withValues(alpha: 0.55),
        ),
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
      ),
      child: Text(
        label,
        style: AppText.body(
          12,
          color: theme.colorScheme.onSurfaceVariant,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Палитра темы/обоев — ряд цветных кругов.
class PaletteStrip extends StatelessWidget {
  const PaletteStrip({
    super.key,
    required this.colors,
    this.size = 34,
    this.showHex = false,
    this.onColorTap,
  });

  final List<Color> colors;
  final double size;
  final bool showHex;
  final void Function(Color color)? onColorTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in colors)
          _PaletteSwatch(
            color: color,
            size: size,
            showHex: showHex,
            onTap: onColorTap == null ? null : () => onColorTap!(color),
          ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.color,
    required this.size,
    required this.showHex,
    this.onTap,
  });

  final Color color;
  final double size;
  final bool showHex;
  final VoidCallback? onTap;

  String get _hex {
    final v = color.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final swatch = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
    if (!showHex) {
      return GestureDetector(onTap: onTap, child: swatch);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          swatch,
          const SizedBox(height: 7),
          Text(
            _hex,
            style: AppText.label(
              9.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

/// Пустое состояние с чернильной иллюстрацией.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.spa_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, compact ? 24 : 48, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: compact ? 120 : 168,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 0,
                    bottom: -12,
                    child: KanjiMark(
                      size: 150,
                      color: theme.colorScheme.onSurface,
                      opacity: 0.06,
                    ),
                  ),
                  Positioned.fill(
                    child: SakuraBranch(
                      ink: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      blossom: AppColors.sakura.withValues(alpha: 0.85),
                      opacity: 0.9,
                      density: 0.55,
                      animate: false,
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? AppColors.sumiRaised
                          : AppColors.card,
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sumi.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.body(
                  14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
