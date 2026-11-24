import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/page_container.dart';
import 'package:hikari/core/widgets/paper_background.dart';
import 'package:hikari/features/catalog/widgets/item_grid.dart';
import 'package:hikari/features/home/home_screen.dart';
import 'package:hikari/core/widgets/sakura_branch.dart';

/// Избранное: сохранённые работы и быстрый доступ к ним.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final favorites = ref.watch(favoriteItemsProvider);

    return catalog.when(
      loading: () => const CatalogLoading(),
      error: (error, stack) => CatalogError(
        message: 'Не удалось прочитать каталог: $error',
        onRetry: () => ref.invalidate(catalogProvider),
      ),
      data: (data) => PageContainer(
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.paddingOf(context).top + 18),
            ),
            SliverToBoxAdapter(
              child: _FavoritesHeader(
                count: favorites.asData?.value.length ?? 0,
                onClear: () => ref.read(favoritesProvider.notifier).clear(),
              ),
            ),
            favorites.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 1.6)),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: CatalogError(
                  message: 'Ошибка: $error',
                  onRetry: () => ref.invalidate(catalogProvider),
                ),
              ),
              data: (items) => items.isEmpty
                  ? SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.favorite_outline_rounded,
                        title: 'Пока пусто',
                        message:
                            'Отмечайте работы сердцем — они появятся здесь и будут ждать вас.',
                        actionLabel: 'Перейти в каталог',
                        onAction: () => context.go('/catalog'),
                      ),
                    )
                  : ItemGrid(items: items, data: data),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ),
      ),
    );
  }
}

class _FavoritesHeader extends ConsumerWidget {
  const _FavoritesHeader({required this.count, required this.onClear});

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GoldRule(width: 34),
                    const SizedBox(width: 12),
                    Text('ИЗБРАННОЕ · 桜', style: AppText.eyebrow(AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Избранное',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width >= 880 ? 44 : 34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count == 0
                      ? 'Ваша личная коллекция'
                      : '$count ${_plural(count)} в вашей коллекции',
                  style: AppText.body(
                    13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('Очистить'),
            ),
        ],
      ),
    );
  }
}

String _plural(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return 'работа';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return 'работы';
  return 'работ';
}
