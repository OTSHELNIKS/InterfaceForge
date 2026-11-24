import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/features/catalog/widgets/favorite_button.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';

/// Карточка работы каталога — постер с постобработкой и быстрыми действиями.
class ItemCard extends ConsumerStatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.collectionName,
    required this.collectionJa,
    required this.collectionColor,
    this.onTap,
    this.borderRadius = 26,
  });

  final HikariItem item;
  final String collectionName;
  final String collectionJa;
  final Color collectionColor;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  ConsumerState<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<ItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(favoritesProvider).contains(widget.item.id);
    final radius = BorderRadius.circular(widget.borderRadius);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.018 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.sumi.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.55 : 0.14,
                ),
                blurRadius: _hovered ? 34 : 18,
                offset: Offset(0, _hovered ? 14 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              child: AspectRatio(
                aspectRatio: 0.72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _image(),
                    const _CardScrim(),
                    _topBar(isFavorite),
                    _footer(theme),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _image() {
    return Image.asset(
      widget.item.asset,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => Container(
        color: widget.item.primary.withValues(alpha: 0.35),
        child: Center(
          child: KanjiMark(size: 90, color: AppColors.paper, opacity: 0.3),
        ),
      ),
    );
  }

  Widget _topBar(bool isFavorite) {
    return Positioned(
      left: 12,
      right: 12,
      top: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeBadge(item: widget.item),
          const Spacer(),
          FavoriteButton(
            itemId: widget.item.id,
            light: true,
            size: 34,
          ),
        ],
      ),
    );
  }

  Widget _footer(ThemeData theme) {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 2,
            decoration: BoxDecoration(
              color: widget.collectionColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            widget.item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.display(17.5, color: AppColors.card, height: 1.15),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                widget.collectionJa,
                style: AppText.mincho(
                  10.5,
                  color: AppColors.sakura.withValues(alpha: 0.95),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '·',
                  style: AppText.body(10, color: AppColors.card.withValues(alpha: 0.55)),
                ),
              ),
              Text(
                widget.collectionName,
                style: AppText.body(
                  10,
                  color: AppColors.card.withValues(alpha: 0.62),
                  letterSpacing: 0.06,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardScrim extends StatelessWidget {
  const _CardScrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.28),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.68),
          ],
          stops: const [0.0, 0.30, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.item});

  final HikariItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isTheme ? AppColors.gold : AppColors.vermilionLight;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.isTheme ? Icons.palette_outlined : Icons.wallpaper_rounded,
                size: 11,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                item.type.label,
                style: AppText.label(9.5, color: AppColors.card, letterSpacing: 0.08),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
