import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hero_header.dart';
import 'package:hikari/core/widgets/paper_background.dart';
import 'package:hikari/core/widgets/page_container.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/features/catalog/widgets/item_grid.dart';
import 'package:hikari/features/home/widgets/collection_card.dart';
import 'package:hikari/features/home/widgets/wallpaper_of_day.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';

/// Главная: постерный хедер, обои дня, коллекции и популярное.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);

    return catalog.when(
      loading: () => const CatalogLoading(),
      error: (error, stack) => CatalogError(
        message: 'Не удалось прочитать каталог: $error',
        onRetry: () => ref.invalidate(catalogProvider),
      ),
      data: (data) => _build(context, data),
    );
  }

  Widget _build(BuildContext context, CatalogData data) {
    final wallpaper = data.wallpaperOfDay;
    final popular = [...data.items]..sort((a, b) => b.popularity.compareTo(a.popularity));

    return PageContainer(
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverToBoxAdapter(
            child: HeroHeader(
              onOpenCatalog: () => context.go('/catalog'),
              onOpenWallpaper: wallpaper == null
                  ? null
                  : () => context.push('/item/${wallpaper.id}'),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 6),
              eyebrow: 'ВЫБОР РЕДАКТОРА',
              title: 'Обои дня',
              trailing: TextButton(
                onPressed: () {
                  ref.read(catalogFiltersProvider.notifier)
                    ..setType(HikariItemType.wallpaper)
                    ..setCollection(null)
                    ..setQuery('');
                  context.go('/catalog');
                },
                child: const Text('Все обои'),
              ),
            ),
          ),
          if (wallpaper != null)
            SliverToBoxAdapter(
              child: WallpaperOfDayCard(
                item: wallpaper,
                data: data,
                onOpen: () => context.push('/item/${wallpaper.id}'),
                onApply: () => context.push('/item/${wallpaper.id}'),
              ),
            ),
          SliverToBoxAdapter(
            child: SectionHeader(
              padding: const EdgeInsets.fromLTRB(24, 38, 24, 14),
              eyebrow: 'КОЛЛЕКЦИИ',
              title: 'Четыре настроения',
            ),
          ),
          SliverToBoxAdapter(child: _CollectionsStrip(data: data)),
          SliverToBoxAdapter(
            child: SectionHeader(
              padding: const EdgeInsets.fromLTRB(24, 38, 24, 6),
              eyebrow: 'ПОПУЛЯРНОЕ',
              title: 'Самое востребованное',
              trailing: TextButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Весь каталог'),
              ),
            ),
          ),
          ItemGrid(
            items: popular.take(6).toList(growable: false),
            data: data,
            maxCrossAxisExtent: 310,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 108)),
        ],
      ),
    );
  }
}

class _CollectionsStrip extends ConsumerWidget {
  const _CollectionsStrip({required this.data});

  final CatalogData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 306,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: data.collections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final collection = data.collections[index];
          final count = data.items
              .where((item) => item.collectionId == collection.id)
              .length;
          return CollectionCard(
            collection: collection,
            count: count,
            onTap: () {
              ref.read(catalogFiltersProvider.notifier)
                ..setType(null)
                ..setCollection(collection.id)
                ..setQuery('');
              context.go('/catalog');
            },
          );
        },
      ),
    );
  }
}

/// Состояние загрузки каталога.
class CatalogLoading extends StatelessWidget {
  const CatalogLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KanjiMark(
            size: 96,
            color: theme.colorScheme.primary,
            opacity: 0.18,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Собираем свет…',
            style: AppText.body(13, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Состояние ошибки каталога.
class CatalogError extends StatelessWidget {
  const CatalogError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 34, color: AppColors.vermilion),
            const SizedBox(height: 16),
            Text('Каталог не загрузился', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body(13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
