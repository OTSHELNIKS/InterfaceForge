import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/widgets/paper_background.dart';

/// Кнопка «в избранное» с тактильной анимацией.
class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({
    super.key,
    required this.itemId,
    this.light = false,
    this.size = 40,
  });

  final String itemId;
  final bool light;
  final double size;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  double _scale = 1;

  Future<void> _toggle() async {
    setState(() => _scale = 0.72);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    setState(() => _scale = 1);
    await ref.read(favoritesProvider.notifier).toggle(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesProvider).contains(widget.itemId);

    return Semantics(
      button: true,
      toggled: isFavorite,
      label: isFavorite ? 'Убрать из избранного' : 'В избранное',
      child: Tooltip(
        message: isFavorite ? 'Убрать из избранного' : 'В избранное',
        child: GlassIconButton(
          light: widget.light,
          size: widget.size,
          onPressed: _toggle,
          icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
        ).animateScale(_scale),
      ),
    );
  }
}

extension _ScaleX on Widget {
  Widget animateScale(double scale) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: scale),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(scale: value, child: child!),
      child: this,
    );
  }
}
