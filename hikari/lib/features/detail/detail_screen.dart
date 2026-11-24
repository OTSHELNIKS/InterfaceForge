import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/paper_background.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/core/widgets/sakura_branch.dart';

/// Экран работы: полноэкранное превью, палитра, теги и применение.
class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _busy = false;
  bool _applied = false;

  Future<void> _apply(HikariItem item, CatalogData data) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _applied = false;
    });
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(systemServiceProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    try {
      if (item.isTheme) {
        await ref.read(activeThemeIdProvider.notifier).set(item.id);
        await service.applyTheme(
          dark: dark,
          accent: _hex(item.accent),
          themeId: item.id,
        );
        if (!mounted) return;
        setState(() => _applied = true);
        messenger.showSnackBar(
          SnackBar(content: Text('Тема «${item.title}» применена')),
        );
      } else {
        final staged = await service.stageAsset(item.assetLandscape);
        final ok = await service.applyWallpaper(staged.path);
        if (!mounted) return;
        setState(() => _applied = ok);
        messenger.showSnackBar(
          SnackBar(
            content: Text(ok ? 'Обои «${item.title}» установлены' : 'Не удалось установить обои'),
          ),
        );
      }
    } on MissingPluginException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Системные обои доступны только в приложении для Windows и Android'),
        ),
      );
    } on PlatformException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось применить: ${error.message ?? error.code}')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось применить: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fullscreen(HikariItem item) async {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Закрыть',
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => FullscreenViewer(item: item),
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final data = catalog.asData?.value;
    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.6)),
      );
    }
    final item = data.itemById(widget.itemId);
    if (item == null) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.image_not_supported_outlined,
          title: 'Работа не найдена',
          message: 'Возможно, её убрали из каталога. Вернитесь в каталог и выберите другую.',
          actionLabel: 'В каталог',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: wide ? _desktop(context, item, data) : _mobile(context, item, data),
    );
  }

  Widget _mobile(BuildContext context, HikariItem item, CatalogData data) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          primary: true,
          expandedHeight: 548,
          toolbarHeight: 62,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leadingWidth: 66,
          leading: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Center(
              child: GlassIconButton(
                light: true,
                icon: Icons.arrow_back_rounded,
                tooltip: 'Назад',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          actions: [
            GlassIconButton(
              light: true,
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
              onPressed: () => _toggleFavorite(item),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              light: true,
              icon: Icons.fullscreen_rounded,
              tooltip: 'Полный экран',
              onPressed: () => _fullscreen(item),
            ),
            const SizedBox(width: 14),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            collapseMode: CollapseMode.parallax,
            background: _PreviewBackground(item: item),
          ),
        ),
        SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.28),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sumi.withValues(alpha: 0.14),
                        blurRadius: 30,
                        offset: const Offset(0, -12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                    child: _Info(
                      item: item,
                      data: data,
                      busy: _busy,
                      applied: _applied,
                      onApply: () => _apply(item, data),
                      onFullscreen: () => _fullscreen(item),
                      onToggleFavorite: () => _toggleFavorite(item),
                    ),
                  ),
                ),
              ),
            ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _desktop(BuildContext context, HikariItem item, CatalogData data) {
    final height = (MediaQuery.sizeOf(context).height - 64).clamp(520.0, 860.0);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _Preview(
                    item: item,
                    height: height,
                    radius: 32,
                    onBack: () => Navigator.of(context).maybePop(),
                    onFullscreen: () => _fullscreen(item),
                    onFavorite: () => _toggleFavorite(item),
                  ),
                ),
                const SizedBox(width: 44),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 12, bottom: 40),
                    child: _Info(
                      item: item,
                      data: data,
                      busy: _busy,
                      applied: _applied,
                      onApply: () => _apply(item, data),
                      onFullscreen: () => _fullscreen(item),
                      onToggleFavorite: () => _toggleFavorite(item),
                      wide: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(HikariItem item) {
    ref.read(favoritesProvider.notifier).toggle(item.id);
  }

  static String _hex(Color color) {
    final v = color.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({
    required this.item,
    required this.height,
    required this.radius,
    required this.onBack,
    required this.onFullscreen,
    required this.onFavorite,
  });

  final HikariItem item;
  final double height;
  final double radius;
  final VoidCallback onBack;
  final VoidCallback onFullscreen;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: _PreviewBackground(item: item, wide: true),
          ),
        ),
        Positioned(
          top: 14 + (radius == 0 ? MediaQuery.paddingOf(context).top : 0),
          left: 14,
          right: 14,
          child: Row(
            children: [
              GlassIconButton(
                light: true,
                icon: Icons.arrow_back_rounded,
                tooltip: 'Назад',
                onPressed: onBack,
              ),
              const Spacer(),
              GlassIconButton(
                light: true,
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                onPressed: onFavorite,
              ),
              const SizedBox(width: 8),
              GlassIconButton(
                light: true,
                icon: Icons.fullscreen_rounded,
                tooltip: 'Полный экран',
                onPressed: onFullscreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewBackground extends StatelessWidget {
  const _PreviewBackground({required this.item, this.wide = false});

  final HikariItem item;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          wide ? item.assetLandscape : item.asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => Container(
            color: item.primary,
            child: Center(
              child: KanjiMark(size: 160, color: AppColors.card, opacity: 0.35),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.42),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.58),
              ],
              stops: const [0.0, 0.22, 0.60, 1.0],
            ),
          ),
        ),
        Positioned(
          left: wide ? 28 : 22,
          right: wide ? 28 : 22,
          bottom: wide ? 28 : 24,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.titleJa,
                      style: AppText.mincho(18, color: AppColors.sakura),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 22,
                      height: 1,
                      color: AppColors.card.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.type.label.toUpperCase(),
                      style: AppText.label(
                        9.5,
                        color: AppColors.card.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(
                    wide ? 52 : 34,
                    color: AppColors.card,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Info extends ConsumerWidget {
  const _Info({
    required this.item,
    required this.data,
    required this.busy,
    required this.applied,
    required this.onApply,
    required this.onFullscreen,
    required this.onToggleFavorite,
    this.wide = false,
  });

  final HikariItem item;
  final CatalogData data;
  final bool busy;
  final bool applied;
  final VoidCallback onApply;
  final VoidCallback onFullscreen;
  final VoidCallback onToggleFavorite;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collection = data.collectionById(item.collectionId);
    final isFavorite = ref.watch(favoritesProvider).contains(item.id);
    final accent = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(
              icon: item.isTheme ? Icons.palette_outlined : Icons.wallpaper_rounded,
              label: item.type.label,
              color: item.isTheme ? AppColors.gold : AppColors.vermilionLight,
            ),
            if (collection != null)
              _MetaPill(
                dot: collection.color,
                label: '${collection.name} · ${collection.nameJa}',
                color: collection.color,
              ),
            _MetaPill(
              icon: Icons.favorite_rounded,
              label: '${item.popularity}',
              color: AppColors.sakura,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          item.title,
          style: AppText.display(wide ? 46 : 34, color: theme.colorScheme.onSurface, height: 1.02),
        ),
        const SizedBox(height: 6),
        Text(item.titleJa, style: AppText.mincho(17, color: AppColors.sakura)),
        const SizedBox(height: 18),
        Text(
          item.description,
          style: AppText.body(
            14.5,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 24),
        const GoldRule(width: 56),
        const SizedBox(height: 24),
        _SectionLabel('Палитра', accent),
        const SizedBox(height: 14),
        PaletteStrip(
          colors: item.colors,
          size: wide ? 40 : 36,
          showHex: true,
          onColorTap: (color) => _copyColor(context, color),
        ),
        const SizedBox(height: 26),
        _SectionLabel('Теги', accent),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in item.tags)
              TagChip(
                label: tag,
                color: collection?.color,
              ),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: accent),
              const SizedBox(width: 10),
              Text(
                _formatDate(item.date),
                style: AppText.body(12.5, color: theme.colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Icon(Icons.bolt_rounded, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                '${item.popularity} / 100',
                style: AppText.body(12.5, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: busy ? null : onApply,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.card,
                    ),
                  )
                : Icon(
                    item.isTheme
                        ? Icons.auto_awesome_rounded
                        : Icons.download_rounded,
                    size: 19,
                  ),
            label: Text(busy ? 'Применяем…' : item.type.applyLabel),
          ),
        ),
        if (applied) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 15, color: accent),
              const SizedBox(width: 7),
              Text(
                'Применено',
                style: AppText.body(12, color: accent, weight: FontWeight.w600),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  size: 17,
                ),
                label: Text(isFavorite ? 'В избранном' : 'В избранное'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.7),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onFullscreen,
              icon: const Icon(Icons.fullscreen_rounded, size: 17),
              label: const Text('Полный экран'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.7),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 14),
          Text(
            'В веб-предпросмотре установка системных обоев недоступна.',
            style: AppText.body(11.5, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  void _copyColor(BuildContext context, Color color) {
    final hex = '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$hex скопирован')),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    required this.color,
    this.icon,
    this.dot,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null)
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
            )
          else
            Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.body(
              11.5,
              weight: FontWeight.w600,
              color: Color.lerp(color, theme.colorScheme.onSurface, 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, this.accent);

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppText.eyebrow(accent, size: 10),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Полноэкранный просмотр с масштабированием.
class FullscreenViewer extends StatelessWidget {
  const FullscreenViewer({super.key, required this.item});

  final HikariItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.asset(
                  MediaQuery.sizeOf(context).width >= 900
                      ? item.assetLandscape
                      : item.asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14,
            right: 16,
            child: GlassIconButton(
              light: true,
              icon: Icons.close_rounded,
              tooltip: 'Закрыть',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 22,
            child: IgnorePointer(
              child: Column(
                children: [
                  Text(
                    item.title,
                    style: AppText.display(24, color: AppColors.card),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.titleJa,
                    style: AppText.mincho(13, color: AppColors.sakura),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Вспомогательный градиент для превью (используется в других экранах).
class PreviewScrim extends StatelessWidget {
  const PreviewScrim({super.key, this.dark = true});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ]
                : [
                    Colors.transparent,
                    Colors.transparent,
                  ],
          ),
        ),
      ),
    );
  }
}
